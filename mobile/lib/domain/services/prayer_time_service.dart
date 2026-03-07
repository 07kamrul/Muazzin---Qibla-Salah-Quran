import 'package:adhan/adhan.dart' as adhan;

import '../../data/models/prayer_times_model.dart';

/// Prayer time calculation service using adhan-dart.
///
/// Uses Hanafi / University of Islamic Sciences, Karachi method:
/// - Fajr angle : 18°
/// - Isha angle : 18°
/// - Asr madhab : Hanafi (shadow = 2× object height)
class PrayerTimeService {
  PrayerTimeService._();
  static final PrayerTimeService instance = PrayerTimeService._();

  // ── Calculation parameters ────────────────────────────────────────────────

  adhan.CalculationParameters get _params {
    final p = adhan.CalculationMethod.karachi.getParameters();
    p.madhab = adhan.Madhab.hanafi;
    return p;
  }

  // ── Single-day calculation ────────────────────────────────────────────────

  /// Calculates prayer times for [lat]/[lng] on [date].
  PrayerTimesModel calculateForDate(double lat, double lng, DateTime date) {
    final coordinates = adhan.Coordinates(lat, lng);
    final dateComponents = adhan.DateComponents(date.year, date.month, date.day);
    final times = adhan.PrayerTimes(coordinates, dateComponents, _params);

    final locationKey = '${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';
    return PrayerTimesModel.fromAdhan(times, date, locationKey);
  }

  // ── Multi-day range ───────────────────────────────────────────────────────

  /// Calculates prayer times for [days] days starting from [startDate].
  List<PrayerTimesModel> calculateRange(
    double lat,
    double lng,
    DateTime startDate,
    int days,
  ) {
    return List.generate(days, (i) {
      final date = startDate.add(Duration(days: i));
      return calculateForDate(lat, lng, date);
    });
  }

  // ── Next prayer / countdown ───────────────────────────────────────────────

  /// Returns the next upcoming prayer entry after [now].
  MapEntry<PrayerEntry, DateTime> getNextPrayer(
    PrayerTimesModel times,
    DateTime now,
  ) =>
      times.getNextPrayer(now);

  /// Returns the currently active prayer window, or null if between prayers.
  PrayerEntry? getCurrentPrayer(PrayerTimesModel times, DateTime now) =>
      times.getCurrentPrayer(now);

  /// Returns the [Duration] until [prayerTime] from [now].
  Duration getCountdown(DateTime prayerTime, DateTime now) {
    final diff = prayerTime.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }
}
