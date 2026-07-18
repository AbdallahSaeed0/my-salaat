import 'package:adhan_dart/adhan_dart.dart' show Coordinates, Qibla;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prayer_times/application/prayer_times_provider.dart';

/// The Qibla bearing (degrees from true north) for the device's precise
/// current GPS position — unlike prayer time calculation this must use the
/// exact location, not a metro-area anchor, since a few km can noticeably
/// change the bearing.
final qiblaBearingProvider = FutureProvider<double>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  return Qibla.qibla(Coordinates(position.latitude, position.longitude));
});

/// True if a magnetometer-backed compass stream is expected on this
/// platform. Web has no compass; flutter_compass returns an empty stream.
bool get isCompassSupported => !kIsWeb;

/// Live compass heading events, or an empty stream where unsupported.
final compassEventProvider = StreamProvider<CompassEvent>((ref) {
  final events = FlutterCompass.events;
  return events ?? const Stream.empty();
});
