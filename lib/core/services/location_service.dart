import 'dart:math';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceException implements Exception {
  LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A coordinate to calculate prayer times for, optionally labeled with the
/// resolved city/region name.
class CalculationLocation {
  const CalculationLocation({required this.latitude, required this.longitude, this.cityLabel});

  final double latitude;
  final double longitude;
  final String? cityLabel;
}

/// A well-known metro area whose official prayer time tables publish a
/// single reference point for the whole urban agglomeration (city + nearby
/// sister cities/suburbs), rather than per-neighborhood coordinates.
class _MetroAnchor {
  const _MetroAnchor(this.label, this.latitude, this.longitude, this.radiusKm);

  final String label;
  final double latitude;
  final double longitude;
  final double radiusKm;
}

/// Anyone whose resolved location falls within [_MetroAnchor.radiusKm] of
/// one of these gets snapped to that single reference point, matching how
/// official sources publish times for the metro area as a whole rather than
/// per-city-within-the-metro-area.
const _metroAnchors = [
  // Greater Cairo: Cairo, Giza, and Qalyubia governorates form one
  // contiguous urban area; Egyptian official tables (Dar Al-Iftaa etc.)
  // publish one "Cairo" time for all of it rather than per-governorate.
  _MetroAnchor('Cairo', 30.0444, 31.2357, 40),
];

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  double toRad(double deg) => deg * pi / 180;

  final dLat = toRad(lat2 - lat1);
  final dLon = toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRad(lat1)) * cos(toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

/// Wraps geolocator to fetch the device's current GPS position,
/// handling service/permission checks with clear error messages.
class LocationService {
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled. Please enable GPS to calculate prayer times.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'Location permission denied. Prayer times need your location to be accurate.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission permanently denied. Enable it from app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  /// Snaps a raw GPS [position] to the coordinate an official prayer time
  /// table would actually use.
  ///
  /// Official tables are published per city (or per metro area), not per
  /// exact GPS coordinate — two people a few km apart can otherwise get
  /// prayer times that drift a minute or more apart purely from GPS jitter
  /// or from being geocoded to two different, officially-merged cities
  /// (e.g. Cairo/Giza). Resolution order:
  ///   1. Snap to a known [_metroAnchors] reference point if within range.
  ///   2. Otherwise reverse-geocode to a locality and geocode that name
  ///      back to a coordinate, removing city-level GPS jitter.
  ///   3. Otherwise fall back to the raw GPS coordinate.
  Future<CalculationLocation> resolveCalculationLocation(Position position) async {
    final fallback = CalculationLocation(latitude: position.latitude, longitude: position.longitude);

    for (final anchor in _metroAnchors) {
      final distanceKm = _haversineKm(position.latitude, position.longitude, anchor.latitude, anchor.longitude);
      if (distanceKm <= anchor.radiusKm) {
        return CalculationLocation(latitude: anchor.latitude, longitude: anchor.longitude, cityLabel: anchor.label);
      }
    }

    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isEmpty) return fallback;

      final place = placemarks.first;
      final cityQuery = [place.locality, place.administrativeArea, place.country]
          .where((part) => part != null && part.trim().isNotEmpty)
          .join(', ');
      if (cityQuery.isEmpty) return fallback;

      final matches = await locationFromAddress(cityQuery);
      if (matches.isEmpty) return fallback;

      final city = matches.first;
      return CalculationLocation(latitude: city.latitude, longitude: city.longitude, cityLabel: cityQuery);
    } catch (_) {
      return fallback;
    }
  }
}
