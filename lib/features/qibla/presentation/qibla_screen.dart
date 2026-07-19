import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/qibla_provider.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bearingAsync = ref.watch(qiblaBearingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).qiblaTitle)),
      body: bearingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CenteredMessage(
          icon: Icons.location_off,
          message: error.toString(),
        ),
        data: (bearing) {
          if (!isCompassSupported) {
            return _StaticBearingFallback(bearing: bearing);
          }
          return _CompassView(bearing: bearing);
        },
      ),
    );
  }
}

class _CompassView extends ConsumerWidget {
  const _CompassView({required this.bearing});

  final double bearing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compassAsync = ref.watch(compassEventProvider);

    return compassAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _StaticBearingFallback(bearing: bearing),
      data: (event) {
        final heading = event.heading;
        if (heading == null) {
          return _StaticBearingFallback(bearing: bearing);
        }

        final needsCalibration = event.accuracy == null || event.accuracy!.abs() > 15;
        final relativeAngle = ((bearing - heading) * pi / 180);

        final colorScheme = Theme.of(context).colorScheme;
        final facingQibla = relativeAngle.abs() < 0.05;

        return Column(
          children: [
            if (needsCalibration)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.explore_off, color: colorScheme.onErrorContainer, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).qiblaCalibrate,
                          style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CompassDial(headingDegrees: heading, bearingDegrees: bearing, facingQibla: facingQibla),
                    const SizedBox(height: 32),
                    Text(
                      '${bearing.toStringAsFixed(1)}°',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: colorScheme.primary, fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      facingQibla ? AppLocalizations.of(context).qiblaFacing : AppLocalizations.of(context).qiblaRotate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.headingDegrees, required this.bearingDegrees, required this.facingQibla});

  final double headingDegrees;
  final double bearingDegrees;
  final bool facingQibla;

  static const _size = 280.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fixed pointer showing where the top of the phone is facing.
          Align(
            alignment: Alignment.topCenter,
            child: Icon(Icons.arrow_drop_up, size: 40, color: colorScheme.primary),
          ),
          AnimatedRotation(
            turns: -headingDegrees / 360,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: facingQibla ? colorScheme.primary : colorScheme.outlineVariant, width: facingQibla ? 2 : 1),
                color: colorScheme.surface,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: _size - 40,
                    height: _size - 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorScheme.outlineVariant)),
                  ),
                  const _CardinalLabel(label: 'N', angleDegrees: 0),
                  const _CardinalLabel(label: 'E', angleDegrees: 90),
                  const _CardinalLabel(label: 'S', angleDegrees: 180),
                  const _CardinalLabel(label: 'W', angleDegrees: 270),
                  _AngleMarker(
                    angleDegrees: bearingDegrees,
                    radius: _size / 2 - 34,
                    child: Icon(Icons.mosque, color: colorScheme.primary, size: 30),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardinalLabel extends StatelessWidget {
  const _CardinalLabel({required this.label, required this.angleDegrees});

  final String label;
  final double angleDegrees;

  @override
  Widget build(BuildContext context) {
    return _AngleMarker(
      angleDegrees: angleDegrees,
      radius: _CompassDial._size / 2 - 16,
      child: Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

/// Positions [child] on the circle of the given [radius], at [angleDegrees]
/// measured clockwise from the top (12 o'clock = 0°).
class _AngleMarker extends StatelessWidget {
  const _AngleMarker({required this.angleDegrees, required this.radius, required this.child});

  final double angleDegrees;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radians = (angleDegrees - 90) * pi / 180;
    return Transform.translate(
      offset: Offset(radius * cos(radians), radius * sin(radians)),
      child: child,
    );
  }
}

class _StaticBearingFallback extends StatelessWidget {
  const _StaticBearingFallback({required this.bearing});

  final double bearing;

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      icon: Icons.explore_off_outlined,
      message: AppLocalizations.of(context).qiblaNoCompass(bearing.toStringAsFixed(1)),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
