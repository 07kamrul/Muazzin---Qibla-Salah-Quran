import 'package:adhan/adhan.dart' as adhan;

enum PrayerEntry { fajr, shuruq, dhuhr, asr, maghrib, isha, tahajjud, ishraq, duha }

class PrayerTimesModel {
  const PrayerTimesModel({
    required this.date,
    required this.locationKey,
    required this.fajr,
    required this.shuruq,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.tahajjud,
    required this.ishraq,
    required this.duha,
  });

  final DateTime date;
  final String locationKey;
  final DateTime fajr;
  final DateTime shuruq;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime tahajjud;
  final DateTime ishraq;
  final DateTime duha;

  // ── Factory from adhan-dart ───────────────────────────────────────────────

  factory PrayerTimesModel.fromAdhan(
    adhan.PrayerTimes times,
    DateTime date,
    String locationKey,
  ) {
    final fajr    = times.fajr!;
    final shuruq  = times.sunrise!;
    final dhuhr   = times.dhuhr!;
    final asr     = times.asr!;
    final maghrib = times.maghrib!;
    final isha    = times.isha!;

    // Tahajjud: last 1/3 of night (between Isha and next Fajr)
    final nextFajr  = fajr.add(const Duration(hours: 24));
    final nightLen  = nextFajr.difference(isha);
    final tahajjud  = isha.add(Duration(seconds: (nightLen.inSeconds * 2 ~/ 3)));

    // Ishraq: 20 min after sunrise
    final ishraq = shuruq.add(const Duration(minutes: 20));

    // Duha: 45 min after sunrise
    final duha = shuruq.add(const Duration(minutes: 45));

    return PrayerTimesModel(
      date:        date,
      locationKey: locationKey,
      fajr:        fajr,
      shuruq:      shuruq,
      dhuhr:       dhuhr,
      asr:         asr,
      maghrib:     maghrib,
      isha:        isha,
      tahajjud:    tahajjud,
      ishraq:      ishraq,
      duha:        duha,
    );
  }

  // ── Next / current prayer ─────────────────────────────────────────────────

  /// Returns the next upcoming prayer (fajr–isha only) after [now].
  MapEntry<PrayerEntry, DateTime> getNextPrayer(DateTime now) {
    final ordered = _mainPrayers;
    for (final entry in ordered) {
      if (entry.value.isAfter(now)) return entry;
    }
    // After Isha: next Fajr is tomorrow — return Fajr offset by 1 day
    return MapEntry(PrayerEntry.fajr, fajr.add(const Duration(days: 1)));
  }

  /// Returns the current active prayer window, or null if between prayers.
  PrayerEntry? getCurrentPrayer(DateTime now) {
    final list = _mainPrayers;
    for (var i = 0; i < list.length - 1; i++) {
      if (now.isAfter(list[i].value) && now.isBefore(list[i + 1].value)) {
        return list[i].key;
      }
    }
    if (now.isAfter(list.last.value)) return list.last.key;
    return null;
  }

  List<MapEntry<PrayerEntry, DateTime>> get _mainPrayers => [
    MapEntry(PrayerEntry.fajr,    fajr),
    MapEntry(PrayerEntry.shuruq,  shuruq),
    MapEntry(PrayerEntry.dhuhr,   dhuhr),
    MapEntry(PrayerEntry.asr,     asr),
    MapEntry(PrayerEntry.maghrib, maghrib),
    MapEntry(PrayerEntry.isha,    isha),
  ];

  /// Returns all prayer entries as an ordered list (fajr → isha).
  List<MapEntry<PrayerEntry, DateTime>> toList() => List.unmodifiable(_mainPrayers);

  // ── JSON ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'date':         date.toIso8601String(),
    'location_key': locationKey,
    'fajr':         fajr.toIso8601String(),
    'shuruq':       shuruq.toIso8601String(),
    'dhuhr':        dhuhr.toIso8601String(),
    'asr':          asr.toIso8601String(),
    'maghrib':      maghrib.toIso8601String(),
    'isha':         isha.toIso8601String(),
    'tahajjud':     tahajjud.toIso8601String(),
    'ishraq':       ishraq.toIso8601String(),
    'duha':         duha.toIso8601String(),
  };

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) =>
      PrayerTimesModel(
        date:        DateTime.parse(json['date'] as String),
        locationKey: json['location_key'] as String,
        fajr:        DateTime.parse(json['fajr'] as String),
        shuruq:      DateTime.parse(json['shuruq'] as String),
        dhuhr:       DateTime.parse(json['dhuhr'] as String),
        asr:         DateTime.parse(json['asr'] as String),
        maghrib:     DateTime.parse(json['maghrib'] as String),
        isha:        DateTime.parse(json['isha'] as String),
        tahajjud:    DateTime.parse(json['tahajjud'] as String),
        ishraq:      DateTime.parse(json['ishraq'] as String),
        duha:        DateTime.parse(json['duha'] as String),
      );
}
