import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/models/prayer_times_model.dart';
import '../../domain/services/prayer_time_service.dart';
import 'location_provider.dart';

/// Today's prayer times — auto-recalculates when location changes.
final prayerTimesProvider =
    FutureProvider.autoDispose<PrayerTimesModel>((ref) async {
  final locAsync = ref.watch(locationProvider);
  return locAsync.when(
    loading: () => throw StateError('location loading'),
    error:   (e, _) => throw e,
    data: (loc) async {
      final today    = DateTime.now();
      final cacheKey = loc.locationKey;

      // Try SQLite cache first
      final cached = await DatabaseHelper.instance
          .getCachedPrayerTimes(cacheKey, today);
      if (cached != null) return cached;

      // Calculate locally with adhan-dart
      final times = PrayerTimeService.instance.calculateForDate(
        loc.latitude, loc.longitude, today,
      );

      // Cache 30 days ahead in background
      Future.microtask(() async {
        final range = PrayerTimeService.instance.calculateRange(
          loc.latitude, loc.longitude, today, 30,
        );
        await DatabaseHelper.instance.cachePrayerTimes(cacheKey, range);
      });

      return times;
    },
  );
});

/// Next prayer — derived from today's times.
final nextPrayerProvider =
    Provider.autoDispose<AsyncValue<MapEntry<PrayerEntry, DateTime>>>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  return timesAsync.whenData(
    (times) => times.getNextPrayer(DateTime.now()),
  );
});

/// Live countdown stream — ticks every second.
final countdownProvider = StreamProvider.autoDispose<Duration>((ref) {
  final nextAsync = ref.watch(nextPrayerProvider);
  return nextAsync.when(
    loading: () => Stream.value(Duration.zero),
    error:   (_, __) => Stream.value(Duration.zero),
    data: (next) async* {
      while (true) {
        final remaining = next.value.difference(DateTime.now());
        yield remaining.isNegative ? Duration.zero : remaining;
        await Future.delayed(const Duration(seconds: 1));
      }
    },
  );
});
