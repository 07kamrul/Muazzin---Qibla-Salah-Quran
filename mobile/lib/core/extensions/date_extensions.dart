/// Date/time convenience extensions for Muazzin.
extension DateTimeX on DateTime {
  /// Returns "23.81_90.41" — used as a SQLite cache key for prayer times.
  String toLocationKey(double lat, double lng) =>
      '${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';

  /// Returns `true` if this and [other] share the same calendar date.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns "HH:MM" string in local time.
  String toTimeString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Returns midnight (00:00:00) at the start of this date.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns midnight (00:00:00) at the start of the next day.
  DateTime get nextMidnight => DateTime(year, month, day + 1);

  /// Returns the 1-based day-of-year (1–366).
  int get dayOfYear {
    final start = DateTime(year);
    return difference(start).inDays + 1;
  }

  /// Returns `true` if this timestamp is older than [hours] hours from now.
  bool isOlderThan(int hours) =>
      DateTime.now().difference(this).inHours >= hours;
}
