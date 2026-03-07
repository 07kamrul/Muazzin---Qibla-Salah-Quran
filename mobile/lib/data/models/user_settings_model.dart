class NotificationSettingsModel {
  const NotificationSettingsModel({
    this.fajr          = true,
    this.shuruq        = false,
    this.dhuhr         = true,
    this.asr           = true,
    this.maghrib       = true,
    this.isha          = true,
    this.preAlertMinutes = 10,
    this.sehriAlert    = true,
    this.iftarAlert    = true,
    this.hadithAlert   = true,
    this.jamatAlert    = false,
  });

  final bool fajr;
  final bool shuruq;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  final int  preAlertMinutes; // 0 | 5 | 10 | 15 | 30
  final bool sehriAlert;
  final bool iftarAlert;
  final bool hadithAlert;
  final bool jamatAlert;

  NotificationSettingsModel copyWith({
    bool? fajr, bool? shuruq, bool? dhuhr, bool? asr,
    bool? maghrib, bool? isha, int? preAlertMinutes,
    bool? sehriAlert, bool? iftarAlert, bool? hadithAlert, bool? jamatAlert,
  }) => NotificationSettingsModel(
    fajr:           fajr           ?? this.fajr,
    shuruq:         shuruq         ?? this.shuruq,
    dhuhr:          dhuhr          ?? this.dhuhr,
    asr:            asr            ?? this.asr,
    maghrib:        maghrib        ?? this.maghrib,
    isha:           isha           ?? this.isha,
    preAlertMinutes: preAlertMinutes ?? this.preAlertMinutes,
    sehriAlert:     sehriAlert     ?? this.sehriAlert,
    iftarAlert:     iftarAlert     ?? this.iftarAlert,
    hadithAlert:    hadithAlert    ?? this.hadithAlert,
    jamatAlert:     jamatAlert     ?? this.jamatAlert,
  );

  Map<String, dynamic> toJson() => {
    'fajr':            fajr,
    'shuruq':          shuruq,
    'dhuhr':           dhuhr,
    'asr':             asr,
    'maghrib':         maghrib,
    'isha':            isha,
    'pre_alert_minutes': preAlertMinutes,
    'sehri_alert':     sehriAlert,
    'iftar_alert':     iftarAlert,
    'hadith_alert':    hadithAlert,
    'jamat_alert':     jamatAlert,
  };

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      NotificationSettingsModel(
        fajr:           json['fajr']              as bool? ?? true,
        shuruq:         json['shuruq']            as bool? ?? false,
        dhuhr:          json['dhuhr']             as bool? ?? true,
        asr:            json['asr']               as bool? ?? true,
        maghrib:        json['maghrib']           as bool? ?? true,
        isha:           json['isha']              as bool? ?? true,
        preAlertMinutes: json['pre_alert_minutes'] as int? ?? 10,
        sehriAlert:     json['sehri_alert']       as bool? ?? true,
        iftarAlert:     json['iftar_alert']       as bool? ?? true,
        hadithAlert:    json['hadith_alert']      as bool? ?? true,
        jamatAlert:     json['jamat_alert']       as bool? ?? false,
      );
}

class UserSettingsModel {
  const UserSettingsModel({
    required this.language,
    required this.calculationMethod,
    required this.theme,
    required this.azanSound,
    required this.notifications,
    required this.ramadanMode,
    required this.fontSize,
    required this.quranDisplayMode,
    this.pinnedMosqueId,
  });

  final String                   language;          // 'bn' | 'en'
  final String                   calculationMethod; // 'karachi'
  final String                   theme;             // 'light' | 'dark' | 'auto'
  final String                   azanSound;         // 'mishary' | 'makkah' | 'madinah'
  final NotificationSettingsModel notifications;
  final bool                     ramadanMode;
  final String                   fontSize;          // 'small' | 'medium' | 'large'
  final String                   quranDisplayMode;  // 'arabic' | 'arabic_bn' | 'arabic_en' | 'all'
  final String?                  pinnedMosqueId;

  /// Sensible defaults aligned with the requirements doc.
  static const UserSettingsModel _defaults = UserSettingsModel(
    language:          'bn',
    calculationMethod: 'karachi',
    theme:             'auto',
    azanSound:         'mishary',
    notifications:     NotificationSettingsModel(),
    ramadanMode:       false,
    fontSize:          'medium',
    quranDisplayMode:  'arabic_bn',
  );

  factory UserSettingsModel.defaults() => _defaults;

  UserSettingsModel copyWith({
    String?                   language,
    String?                   calculationMethod,
    String?                   theme,
    String?                   azanSound,
    NotificationSettingsModel? notifications,
    bool?                     ramadanMode,
    String?                   fontSize,
    String?                   quranDisplayMode,
    String?                   pinnedMosqueId,
  }) => UserSettingsModel(
    language:          language          ?? this.language,
    calculationMethod: calculationMethod ?? this.calculationMethod,
    theme:             theme             ?? this.theme,
    azanSound:         azanSound         ?? this.azanSound,
    notifications:     notifications     ?? this.notifications,
    ramadanMode:       ramadanMode       ?? this.ramadanMode,
    fontSize:          fontSize          ?? this.fontSize,
    quranDisplayMode:  quranDisplayMode  ?? this.quranDisplayMode,
    pinnedMosqueId:    pinnedMosqueId    ?? this.pinnedMosqueId,
  );

  Map<String, dynamic> toJson() => {
    'language':           language,
    'calculation_method': calculationMethod,
    'theme':              theme,
    'azan_sound':         azanSound,
    'notifications':      notifications.toJson(),
    'ramadan_mode':       ramadanMode,
    'font_size':          fontSize,
    'quran_display_mode': quranDisplayMode,
    'pinned_mosque_id':   pinnedMosqueId,
  };

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      UserSettingsModel(
        language:          json['language']           as String? ?? 'bn',
        calculationMethod: json['calculation_method'] as String? ?? 'karachi',
        theme:             json['theme']              as String? ?? 'auto',
        azanSound:         json['azan_sound']         as String? ?? 'mishary',
        notifications:     json['notifications'] != null
            ? NotificationSettingsModel.fromJson(
                json['notifications'] as Map<String, dynamic>)
            : const NotificationSettingsModel(),
        ramadanMode:       json['ramadan_mode']       as bool?   ?? false,
        fontSize:          json['font_size']          as String? ?? 'medium',
        quranDisplayMode:  json['quran_display_mode'] as String? ?? 'arabic_bn',
        pinnedMosqueId:    json['pinned_mosque_id']   as String?,
      );
}
