import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/preferences_helper.dart';
import '../../data/models/prayer_times_model.dart';
import '../../data/models/user_settings_model.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettingsModel>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<UserSettingsModel> {
  SettingsNotifier() : super(UserSettingsModel.defaults()) {
    _load();
  }

  Future<void> _load() async {
    final s = await PreferencesHelper.instance.loadSettings();
    state = s;
  }

  Future<void> _save() =>
      PreferencesHelper.instance.saveSettings(state);

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    _save();
  }

  void setTheme(String theme) {
    state = state.copyWith(theme: theme);
    _save();
  }

  void setCalculationMethod(String method) {
    state = state.copyWith(calculationMethod: method);
    _save();
  }

  void setAzanSound(String sound) {
    state = state.copyWith(azanSound: sound);
    _save();
  }

  void togglePrayerNotification(PrayerEntry prayer, bool value) {
    final n = state.notifications;
    final updated = switch (prayer) {
      PrayerEntry.fajr    => n.copyWith(fajr: value),
      PrayerEntry.shuruq  => n.copyWith(shuruq: value),
      PrayerEntry.dhuhr   => n.copyWith(dhuhr: value),
      PrayerEntry.asr     => n.copyWith(asr: value),
      PrayerEntry.maghrib => n.copyWith(maghrib: value),
      PrayerEntry.isha    => n.copyWith(isha: value),
      _                   => n,
    };
    state = state.copyWith(notifications: updated);
    _save();
  }

  void setPreAlertMinutes(int minutes) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(preAlertMinutes: minutes),
    );
    _save();
  }

  void toggleRamadanMode() {
    state = state.copyWith(ramadanMode: !state.ramadanMode);
    _save();
  }

  void setPinnedMosque(String? id) {
    state = state.copyWith(pinnedMosqueId: id);
    _save();
  }

  void toggleHadithAlert(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(hadithAlert: value),
    );
    _save();
  }

  void toggleSehriAlert(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(sehriAlert: value),
    );
    _save();
  }

  void toggleIftarAlert(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(iftarAlert: value),
    );
    _save();
  }

  void setFontSize(String size) {
    state = state.copyWith(fontSize: size);
    _save();
  }

  void setQuranDisplayMode(String mode) {
    state = state.copyWith(quranDisplayMode: mode);
    _save();
  }
}
