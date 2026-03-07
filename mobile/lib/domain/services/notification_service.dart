import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/constants/app_config.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/prayer_times_model.dart';
import '../../data/models/user_settings_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── IDs ───────────────────────────────────────────────────────────────────
  static const int _hadithNotifId  = 9000;
  static const int _sehriBase      = 9100;
  static const int _iftarId        = 9200;
  static const _prayerIdBase = {
    'fajr': 100, 'shuruq': 200, 'dhuhr': 300,
    'asr': 400, 'maghrib': 500, 'isha': 600,
  };

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS     = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );
    await _setupAndroidChannel();
  }

  Future<void> _setupAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'muazzin_azan',
      'Azan Notifications',
      description: 'Prayer time and Azan alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ── Prayer notifications ──────────────────────────────────────────────────

  Future<void> schedulePrayerNotifications(
    PrayerTimesModel times,
    UserSettingsModel settings,
  ) async {
    final lang  = settings.language;
    final notif = settings.notifications;
    final now   = DateTime.now();

    final schedule = [
      (PrayerEntry.fajr,    times.fajr,    notif.fajr),
      (PrayerEntry.shuruq,  times.shuruq,  notif.shuruq),
      (PrayerEntry.dhuhr,   times.dhuhr,   notif.dhuhr),
      (PrayerEntry.asr,     times.asr,     notif.asr),
      (PrayerEntry.maghrib, times.maghrib, notif.maghrib),
      (PrayerEntry.isha,    times.isha,    notif.isha),
    ];

    for (final (prayer, time, enabled) in schedule) {
      if (!enabled || time.isBefore(now)) continue;

      final content = _prayerContent(prayer, lang);
      final baseId  = _prayerIdBase[prayer.name] ?? 0;

      // Main azan notification
      await _scheduleAt(
        id:    baseId,
        title: content['title']!,
        body:  content['body']!,
        time:  time,
      );

      // Pre-alert notification
      if (notif.preAlertMinutes > 0) {
        final preTime = time.subtract(Duration(minutes: notif.preAlertMinutes));
        if (preTime.isAfter(now)) {
          final preContent = _preAlertContent(prayer, notif.preAlertMinutes, lang);
          await _scheduleAt(
            id:    baseId + 50,
            title: preContent['title']!,
            body:  preContent['body']!,
            time:  preTime,
          );
        }
      }
    }
  }

  // ── Hadith notification ───────────────────────────────────────────────────

  Future<void> scheduleHadithNotification(HadithModel hadith, String lang) async {
    final now     = DateTime.now();
    final target  = DateTime(now.year, now.month, now.day, AppConfig.hadithNotificationHour);
    final when    = target.isBefore(now) ? target.add(const Duration(days: 1)) : target;

    final preview = hadith.banglaTranslation.length > 80
        ? '${hadith.banglaTranslation.substring(0, 80)}…'
        : hadith.banglaTranslation;

    await _scheduleAt(
      id:    _hadithNotifId,
      title: lang == 'bn' ? 'আজকের হাদিস' : "Today's Hadith",
      body:  preview,
      time:  when,
    );
  }

  // ── Sehri / Iftar ─────────────────────────────────────────────────────────

  Future<void> scheduleSehriAlerts(DateTime sehriTime, String lang) async {
    final now = DateTime.now();
    for (var i = 0; i < AppConfig.sehriAlertMinutes.length; i++) {
      final mins   = AppConfig.sehriAlertMinutes[i];
      final target = sehriTime.subtract(Duration(minutes: mins));
      if (target.isAfter(now)) {
        await _scheduleAt(
          id:    _sehriBase + i,
          title: lang == 'bn' ? 'সেহরির সময় শেষ হচ্ছে' : 'Sehri ending soon',
          body:  lang == 'bn'
              ? '$mins মিনিট বাকি'
              : '$mins minutes remaining',
          time:  target,
        );
      }
    }
  }

  Future<void> scheduleIftarAlert(DateTime maghribTime, String lang) async {
    if (maghribTime.isAfter(DateTime.now())) {
      await _scheduleAt(
        id:    _iftarId,
        title: lang == 'bn' ? '🌙 ইফতারের সময় হয়েছে' : '🌙 Iftar time',
        body:  lang == 'bn' ? 'আল্লাহুম্মা লাকা সুমতু...' : 'Time to break your fast',
        time:  maghribTime,
      );
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  Future<void> cancelPrayerNotifications(PrayerEntry prayer) async {
    final base = _prayerIdBase[prayer.name] ?? 0;
    await _plugin.cancel(base);
    await _plugin.cancel(base + 50);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _scheduleAt({
    required int    id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(time),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'muazzin_azan',
          'Azan Notifications',
          channelDescription: 'Prayer time alerts',
          importance: Importance.max,
          priority:   Priority.high,
          playSound:  true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ignore: non_constant_identifier_names
  dynamic _toTZDateTime(DateTime dt) => dt; // timezone package not required

  Map<String, String> _prayerContent(PrayerEntry prayer, String lang) {
    if (lang == 'bn') {
      return switch (prayer) {
        PrayerEntry.fajr    => {'title': 'ফজরের আযান', 'body': 'ফজরের নামাযের সময় হয়েছে'},
        PrayerEntry.shuruq  => {'title': 'সূর্যোদয়', 'body': 'সূর্য উদিত হয়েছে'},
        PrayerEntry.dhuhr   => {'title': 'যোহরের আযান', 'body': 'যোহরের নামাযের সময় হয়েছে'},
        PrayerEntry.asr     => {'title': 'আসরের আযান', 'body': 'আসরের নামাযের সময় হয়েছে'},
        PrayerEntry.maghrib => {'title': 'মাগরিবের আযান', 'body': 'মাগরিবের নামাযের সময় হয়েছে'},
        PrayerEntry.isha    => {'title': 'ইশার আযান', 'body': 'ইশার নামাযের সময় হয়েছে'},
        _                   => {'title': 'নামাযের সময়', 'body': 'নামাযের সময় হয়েছে'},
      };
    }
    return switch (prayer) {
      PrayerEntry.fajr    => {'title': 'Fajr Prayer', 'body': "It's time for Fajr prayer"},
      PrayerEntry.shuruq  => {'title': 'Sunrise', 'body': 'The sun has risen'},
      PrayerEntry.dhuhr   => {'title': 'Dhuhr Prayer', 'body': "It's time for Dhuhr prayer"},
      PrayerEntry.asr     => {'title': 'Asr Prayer', 'body': "It's time for Asr prayer"},
      PrayerEntry.maghrib => {'title': 'Maghrib Prayer', 'body': "It's time for Maghrib prayer"},
      PrayerEntry.isha    => {'title': 'Isha Prayer', 'body': "It's time for Isha prayer"},
      _                   => {'title': 'Prayer Time', 'body': "It's time to pray"},
    };
  }

  Map<String, String> _preAlertContent(PrayerEntry prayer, int mins, String lang) {
    if (lang == 'bn') {
      return {'title': 'নামাযের রিমাইন্ডার', 'body': '${mins} মিনিট পরে নামাযের সময়'};
    }
    return {'title': 'Prayer Reminder', 'body': 'Prayer in $mins minutes'};
  }
}
