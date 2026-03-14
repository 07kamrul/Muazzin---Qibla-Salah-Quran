import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/prayer_times_model.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isBn     = settings.language == 'bn';

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'সেটিংস' : 'Settings'),
      ),
      body: ListView(
        children: [
          // ── General ───────────────────────────────────────────────────────
          _SectionHeader(title: isBn ? 'সাধারণ' : 'General'),

          // Language
          _SettingsTile(
            icon: Icons.language,
            title: isBn ? 'ভাষা' : 'Language',
            subtitle: isBn ? 'বাংলা / English' : 'Bangla / English',
            trailing: DropdownButton<String>(
              value: settings.language,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => notifier.setLanguage(v!),
            ),
          ),

          // Theme
          _SettingsTile(
            icon: Icons.palette,
            title: isBn ? 'থিম' : 'Theme',
            trailing: DropdownButton<String>(
              value: settings.theme,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: 'light',
                  child: Text(isBn ? 'আলো' : 'Light'),
                ),
                DropdownMenuItem(
                  value: 'dark',
                  child: Text(isBn ? 'অন্ধকার' : 'Dark'),
                ),
                DropdownMenuItem(
                  value: 'auto',
                  child: Text(isBn ? 'স্বয়ংক্রিয়' : 'Auto'),
                ),
              ],
              onChanged: (v) => notifier.setTheme(v!),
            ),
          ),

          // ── Prayer Times ─────────────────────────────────────────────────
          _SectionHeader(title: isBn ? 'নামাজের সময়' : 'Prayer Times'),

          // Calculation method
          _SettingsTile(
            icon: Icons.calculate,
            title: isBn ? 'হিসাব পদ্ধতি' : 'Calculation Method',
            trailing: DropdownButton<String>(
              value: settings.calculationMethod,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'karachi', child: Text('Karachi (Hanafi)')),
                DropdownMenuItem(value: 'isna', child: Text('ISNA')),
                DropdownMenuItem(value: 'mwl', child: Text('MWL')),
              ],
              onChanged: (v) => notifier.setCalculationMethod(v!),
            ),
          ),

          // ── Azan ─────────────────────────────────────────────────────────
          _SectionHeader(title: isBn ? 'আজান' : 'Azan'),

          // Azan sound
          _SettingsTile(
            icon: Icons.music_note,
            title: isBn ? 'আজানের সুর' : 'Azan Sound',
            trailing: DropdownButton<String>(
              value: settings.azanSound,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: 'mishary',
                  child: Text(isBn ? 'শেখ মিশারি' : 'Sheikh Mishary'),
                ),
                DropdownMenuItem(
                  value: 'madinah',
                  child: Text(isBn ? 'মদিনা আজান' : 'Madinah Azan'),
                ),
                DropdownMenuItem(
                  value: 'makkah',
                  child: Text(isBn ? 'মক্কা আজান' : 'Makkah Azan'),
                ),
              ],
              onChanged: (v) => notifier.setAzanSound(v!),
            ),
          ),

          // Pre-alert timing
          _SettingsTile(
            icon: Icons.timer,
            title: isBn ? 'আগাম সতর্কতা' : 'Pre-alert Timing',
            trailing: DropdownButton<int>(
              value: settings.notifications.preAlertMinutes,
              underline: const SizedBox.shrink(),
              items: [0, 5, 10, 15, 30].map((m) => DropdownMenuItem(
                value: m,
                child: Text(m == 0
                    ? (isBn ? 'বন্ধ' : 'Off')
                    : '$m ${isBn ? 'মিনিট' : 'min'}'),
              )).toList(),
              onChanged: (v) => notifier.setPreAlertMinutes(v!),
            ),
          ),

          // ── Notifications ─────────────────────────────────────────────────
          _SectionHeader(title: isBn ? 'নোটিফিকেশন' : 'Notifications'),

          _NotifSwitch(
            icon: Icons.brightness_3,
            title: isBn ? 'ফজর' : 'Fajr',
            value: settings.notifications.fajr,
            onChanged: (v) => notifier.togglePrayerNotification(PrayerEntry.fajr, v),
          ),
          _NotifSwitch(
            icon: Icons.wb_sunny,
            title: isBn ? 'যোহর' : 'Dhuhr',
            value: settings.notifications.dhuhr,
            onChanged: (v) => notifier.togglePrayerNotification(PrayerEntry.dhuhr, v),
          ),
          _NotifSwitch(
            icon: Icons.wb_sunny_outlined,
            title: isBn ? 'আসর' : 'Asr',
            value: settings.notifications.asr,
            onChanged: (v) => notifier.togglePrayerNotification(PrayerEntry.asr, v),
          ),
          _NotifSwitch(
            icon: Icons.nights_stay,
            title: isBn ? 'মাগরিব' : 'Maghrib',
            value: settings.notifications.maghrib,
            onChanged: (v) => notifier.togglePrayerNotification(PrayerEntry.maghrib, v),
          ),
          _NotifSwitch(
            icon: Icons.dark_mode,
            title: isBn ? 'ইশা' : 'Isha',
            value: settings.notifications.isha,
            onChanged: (v) => notifier.togglePrayerNotification(PrayerEntry.isha, v),
          ),
          _NotifSwitch(
            icon: Icons.auto_awesome,
            title: isBn ? 'দৈনিক হাদিস' : 'Daily Hadith',
            value: settings.notifications.hadithAlert,
            onChanged: (v) => notifier.toggleHadithAlert(v),
          ),

          // ── Ramadan ───────────────────────────────────────────────────────
          _SectionHeader(title: isBn ? 'রমজান' : 'Ramadan'),

          _NotifSwitch(
            icon: Icons.restaurant,
            title: isBn ? 'সেহরির সতর্কতা' : 'Sehri Alert',
            value: settings.notifications.sehriAlert,
            onChanged: (v) => notifier.toggleSehriAlert(v),
          ),
          _NotifSwitch(
            icon: Icons.nightlight_round,
            title: isBn ? 'ইফতারের সতর্কতা' : 'Iftar Alert',
            value: settings.notifications.iftarAlert,
            onChanged: (v) => notifier.toggleIftarAlert(v),
          ),

          // ── Quran Reader ─────────────────────────────────────────────────
          _SectionHeader(title: isBn ? 'কুরআন প্রদর্শন' : 'Quran Display'),

          _SettingsTile(
            icon: Icons.menu_book,
            title: isBn ? 'অনুবাদ দেখান' : 'Show Translation',
            trailing: DropdownButton<String>(
              value: settings.quranDisplayMode,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: 'arabic_only',
                  child: Text(isBn ? 'শুধু আরবি' : 'Arabic Only'),
                ),
                DropdownMenuItem(
                  value: 'arabic_bn',
                  child: Text(isBn ? 'আরবি + বাংলা' : 'Arabic + Bangla'),
                ),
                DropdownMenuItem(
                  value: 'arabic_en',
                  child: Text(isBn ? 'আরবি + ইংরেজি' : 'Arabic + English'),
                ),
                DropdownMenuItem(
                  value: 'all',
                  child: Text(isBn ? 'সব দেখান' : 'Show All'),
                ),
              ],
              onChanged: (v) => notifier.setQuranDisplayMode(v!),
            ),
          ),

          // Font size
          _SettingsTile(
            icon: Icons.text_fields,
            title: isBn ? 'ফন্ট সাইজ' : 'Font Size',
            trailing: DropdownButton<String>(
              value: settings.fontSize,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(value: 'small',  child: Text(isBn ? 'ছোট' : 'Small')),
                DropdownMenuItem(value: 'medium', child: Text(isBn ? 'মাঝারি' : 'Medium')),
                DropdownMenuItem(value: 'large',  child: Text(isBn ? 'বড়' : 'Large')),
              ],
              onChanged: (v) => notifier.setFontSize(v!),
            ),
          ),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader(title: isBn ? 'অ্যাপ সম্পর্কে' : 'About'),

          _SettingsTile(
            icon: Icons.info_outline,
            title: isBn ? 'সংস্করণ' : 'Version',
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: isBn ? 'গোপনীয়তা নীতি' : 'Privacy Policy',
            onTap: () {/* launch URL */},
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: isBn ? 'অ্যাপ রেট করুন' : 'Rate App',
            onTap: () {/* launch store */},
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData  icon;
  final String    title;
  final String?   subtitle;
  final Widget?   trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen, size: 22),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _NotifSwitch extends StatelessWidget {
  const _NotifSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String   title;
  final bool     value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primaryGreen, size: 22),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryGreen,
    );
  }
}
