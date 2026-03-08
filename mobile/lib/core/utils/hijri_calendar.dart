// Pure-Dart Hijri calendar — no external package required.
// Uses the standard tabular Islamic calendar algorithm (JDN-based).

/// Minimal drop-in for the hijri package's HijriCalendar.fromDate() API.
class HijriCalendar {
  HijriCalendar._(this.hYear, this.hMonth, this.hDay);

  final int hYear;
  final int hMonth;
  final int hDay;

  /// Convert a Gregorian [DateTime] to the corresponding Hijri date.
  factory HijriCalendar.fromDate(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    final h   = _jdnToHijri(jdn);
    return HijriCalendar._(h.$1, h.$2, h.$3);
  }

  // ── Algorithms ─────────────────────────────────────────────────────────────

  /// Gregorian → Julian Day Number (proleptic Gregorian calendar).
  static int _gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  /// Julian Day Number → Hijri (tabular Islamic calendar).
  /// Algorithm from E.G. Richards, "Mapping Time" (Oxford University Press).
  static (int year, int month, int day) _jdnToHijri(int jdn) {
    int l = jdn - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final year  = 30 * n + j - 30;
    final month = (24 * l) ~/ 709;
    final day   = l - (709 * month) ~/ 24;
    return (year, month, day);
  }
}

// ── Public model & utilities ─────────────────────────────────────────────────

/// Hijri date model returned by [HijriCalendarUtil].
class HijriDate {
  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNameBn,
    required this.monthNameEn,
    required this.monthNameArabic,
  });

  final int    day;
  final int    month;
  final int    year;
  final String monthNameBn;
  final String monthNameEn;
  final String monthNameArabic;

  @override
  String toString() => '$day $monthNameBn $year';
}

/// Utilities for Hijri ↔ Gregorian conversion.
class HijriCalendarUtil {
  HijriCalendarUtil._();

  // ── Month name tables ─────────────────────────────────────────────────────

  static const List<String> monthsBn = [
    'মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউল আখির',
    'জুমাদাল উলা', 'জুমাদাল আখিরা', 'রজব', 'শাবান',
    'রমজান', 'শাওয়াল', 'যুলকাদা', 'যুলহিজ্জা',
  ];

  static const List<String> monthsEn = [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Ula', 'Jumada al-Akhira', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  static const List<String> monthsAr = [
    'مُحَرَّم', 'صَفَر', 'رَبِيع الأَوَّل', 'رَبِيع الآخِر',
    'جُمَادَى الأُولَى', 'جُمَادَى الآخِرَة', 'رَجَب', 'شَعْبَان',
    'رَمَضَان', 'شَوَّال', 'ذُو القَعْدَة', 'ذُو الحِجَّة',
  ];

  // ── Conversion ────────────────────────────────────────────────────────────

  /// Converts a Gregorian [date] to [HijriDate].
  static HijriDate fromGregorian(DateTime date) {
    final h = HijriCalendar.fromDate(date);
    final m = h.hMonth; // 1-indexed
    return HijriDate(
      day:             h.hDay,
      month:           m,
      year:            h.hYear,
      monthNameBn:     monthsBn[m - 1],
      monthNameEn:     monthsEn[m - 1],
      monthNameArabic: monthsAr[m - 1],
    );
  }

  // ── Checks ────────────────────────────────────────────────────────────────

  /// Returns `true` if [date] falls within Hijri month of Ramadan (9).
  static bool isRamadan(DateTime date) {
    final h = HijriCalendar.fromDate(date);
    return h.hMonth == 9;
  }

  /// Returns `true` if [date] falls in the last 10 nights of Ramadan
  /// (Hijri month 9, days 21–30).
  static bool isLastTenNightsRamadan(DateTime date) {
    final h = HijriCalendar.fromDate(date);
    return h.hMonth == 9 && h.hDay >= 21;
  }

  // ── Formatting ────────────────────────────────────────────────────────────

  /// Returns a formatted Hijri date string.
  ///
  /// [lang] = `'bn'` → "১৫ রমজান ১৪৪৬"
  /// [lang] = `'en'` → "15 Ramadan 1446"
  static String formatHijri(DateTime date, String lang) {
    final h    = fromGregorian(date);
    final day  = lang == 'bn' ? _toBn(h.day.toString()) : h.day.toString();
    final year = lang == 'bn' ? _toBn(h.year.toString()) : h.year.toString();
    final month = lang == 'bn' ? h.monthNameBn : h.monthNameEn;
    return '$day $month $year';
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static String _toBn(String s) {
    const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return s.split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? digits[d] : c;
    }).join();
  }
}
