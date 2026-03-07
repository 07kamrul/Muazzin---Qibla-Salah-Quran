import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/qibla_service.dart';
import 'location_provider.dart';

/// Qibla bearing — computed once from current location.
final qiblaBearingProvider = Provider.autoDispose<double?>((ref) {
  final locAsync = ref.watch(locationProvider);
  return locAsync.whenOrNull(
    data: (loc) => QiblaService.instance.getQiblaBearing(
      loc.latitude, loc.longitude,
    ),
  );
});

/// Live compass heading stream from device magnetometer (degrees from magnetic north).
final compassHeadingProvider = StreamProvider.autoDispose<double>((ref) {
  return FlutterCompass.events!.map((event) => event.heading ?? 0.0);
});

/// Combined Qibla state: bearing, current heading, alignment, deviation.
final qiblaStateProvider = Provider.autoDispose<
    ({double bearing, double heading, bool isAligned, double deviation})?>(
  (ref) {
    final bearing  = ref.watch(qiblaBearingProvider);
    final headingA = ref.watch(compassHeadingProvider);

    if (bearing == null) return null;
    final heading = headingA.whenOrNull(data: (h) => h) ?? 0.0;

    return (
      bearing:   bearing,
      heading:   heading,
      isAligned: QiblaService.instance.isAlignedWithQibla(heading, bearing),
      deviation: QiblaService.instance.getDeviation(heading, bearing),
    );
  },
);
