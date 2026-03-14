import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../providers/settings_provider.dart';

class MuazzinBottomNavBar extends ConsumerWidget {
  const MuazzinBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang  = ref.watch(settingsProvider).language;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      _NavItem(
        icon: Icons.access_time_rounded,
        labelBn: 'নামাজ', labelEn: 'Prayer',
      ),
      _NavItem(
        icon: Icons.explore_rounded,
        labelBn: 'কিবলা', labelEn: 'Qibla',
      ),
      _NavItem(
        icon: Icons.location_on_rounded,
        labelBn: 'মসজিদ', labelEn: 'Mosque',
      ),
      _NavItem(
        icon: Icons.menu_book_rounded,
        labelBn: 'কোরআন', labelEn: 'Quran',
      ),
      _NavItem(
        icon: Icons.settings_rounded,
        labelBn: 'সেটিংস', labelEn: 'Settings',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.sky1,
      selectedItemColor:   AppColors.goldWarm,
      unselectedItemColor: AppColors.sandMid,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: items.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: lang == 'bn' ? item.labelBn : item.labelEn,
      )).toList(),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.labelBn,
    required this.labelEn,
  });
  final IconData icon;
  final String   labelBn;
  final String   labelEn;
}
