import 'package:intl/intl.dart';

/// Formatting utilities for Muazzin.
class Formatting {
  Formatting._();

  static const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  // ── Digit conversion ──────────────────────────────────────────────────────

  /// Converts ASCII digits 0–9 in [s] to Bangla digits ০–৯.
  static String toBanglaDigits(String s) => s.split('').map((c) {
    final d = int.tryParse(c);
    return d != null ? _bnDigits[d] : c;
  }).join();

  // ── Time ──────────────────────────────────────────────────────────────────

  /// Formats [dt] as "৫:৩০ পূর্বাহ্ন" (bn) or "5:30 AM" (en).
  static String formatTime(DateTime dt, String lang, {bool use12h = true}) {
    final pattern = use12h ? 'h:mm a' : 'HH:mm';
    String formatted = DateFormat(pattern, lang == 'bn' ? 'bn' : 'en').format(dt);

    if (lang == 'bn') {
      formatted = formatted
          .replaceAll('AM', 'পূর্বাহ্ন')
          .replaceAll('PM', 'অপরাহ্ন')
          .replaceAll('am', 'পূর্বাহ্ন')
          .replaceAll('pm', 'অপরাহ্ন');
      formatted = toBanglaDigits(formatted);
    }
    return formatted;
  }

  // ── Date ──────────────────────────────────────────────────────────────────

  /// Formats [dt] as "৬ মার্চ ২০২৬" (bn) or "6 March 2026" (en).
  static String formatDate(DateTime dt, String lang) {
    final pattern = 'd MMMM yyyy';
    String formatted =
        DateFormat(pattern, lang == 'bn' ? 'bn' : 'en').format(dt);
    if (lang == 'bn') formatted = toBanglaDigits(formatted);
    return formatted;
  }

  // ── Countdown ─────────────────────────────────────────────────────────────

  /// Returns "২ ঘণ্টা ১৫ মিনিট ৩০ সেকেন্ড" (bn) or "2h 15m 30s" (en).
  static String formatCountdown(Duration d, String lang) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;

    if (lang == 'bn') {
      final parts = <String>[];
      if (h > 0) parts.add('${toBanglaDigits(h.toString())} ঘণ্টা');
      if (m > 0) parts.add('${toBanglaDigits(m.toString())} মিনিট');
      if (s > 0 || parts.isEmpty) parts.add('${toBanglaDigits(s.toString())} সেকেন্ড');
      return parts.join(' ');
    } else {
      final parts = <String>[];
      if (h > 0) parts.add('${h}h');
      if (m > 0) parts.add('${m}m');
      if (s > 0 || parts.isEmpty) parts.add('${s}s');
      return parts.join(' ');
    }
  }

  /// Returns countdown as HH:MM:SS string with optional Bangla digits.
  static String formatCountdownHMS(Duration d, String lang) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final result = '$h:$m:$s';
    return lang == 'bn' ? toBanglaDigits(result) : result;
  }

  // ── Distance ─────────────────────────────────────────────────────────────

  /// Returns "১.২ কিমি" (bn) or "1.2 km" (en).
  static String formatDistance(double km, String lang) {
    final value = km < 1
        ? '${(km * 1000).round()}${lang == 'bn' ? ' মি' : ' m'}'
        : '${km.toStringAsFixed(1)}${lang == 'bn' ? ' কিমি' : ' km'}';
    return lang == 'bn' ? toBanglaDigits(value) : value;
  }

  // ── Prayer names ──────────────────────────────────────────────────────────

  static String prayerNameBn(String key) => switch (key.toLowerCase()) {
    'fajr'     => 'ফজর',
    'shuruq'   => 'সূর্যোদয়',
    'dhuhr'    => 'যোহর',
    'asr'      => 'আসর',
    'maghrib'  => 'মাগরিব',
    'isha'     => 'ইশা',
    'tahajjud' => 'তাহাজ্জুদ',
    'ishraq'   => 'ইশরাক',
    'duha'     => 'চাশত',
    _          => key,
  };

  static String prayerNameEn(String key) => switch (key.toLowerCase()) {
    'fajr'     => 'Fajr',
    'shuruq'   => 'Sunrise',
    'dhuhr'    => 'Dhuhr',
    'asr'      => 'Asr',
    'maghrib'  => 'Maghrib',
    'isha'     => 'Isha',
    'tahajjud' => 'Tahajjud',
    'ishraq'   => 'Ishraq',
    'duha'     => 'Duha',
    _          => key,
  };
}
