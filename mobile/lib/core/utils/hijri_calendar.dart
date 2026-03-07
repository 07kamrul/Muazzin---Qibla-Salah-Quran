import 'package:hijri/hijri_calendar.dart';

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
      day:            h.hDay,
      month:          m,
      year:           h.hYear,
      monthNameBn:    monthsBn[m - 1],
      monthNameEn:    monthsEn[m - 1],
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
