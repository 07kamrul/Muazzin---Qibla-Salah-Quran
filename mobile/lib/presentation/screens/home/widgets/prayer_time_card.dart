import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatting.dart';
import '../../../../data/models/prayer_times_model.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    required this.prayer,
    required this.time,
    required this.isCurrent,
    required this.isNext,
    required this.isPast,
    required this.lang,
    super.key,
  });

  final PrayerEntry prayer;
  final DateTime    time;
  final bool        isCurrent;
  final bool        isNext;
  final bool        isPast;
  final String      lang;

  @override
  Widget build(BuildContext context) {
    final name  = lang == 'bn'
        ? Formatting.prayerNameBn(prayer.name)
        : Formatting.prayerNameEn(prayer.name);
    final timeStr = Formatting.formatTime(time, lang);
    final color   = AppColors.forPrayer(prayer.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.domeGlow : AppColors.sky2,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: isNext ? color : Colors.transparent, width: 4),
          top:    const BorderSide(color: AppColors.goldBd),
          right:  const BorderSide(color: AppColors.goldBd),
          bottom: const BorderSide(color: AppColors.goldBd),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: _PrayerIcon(color: color, prayer: prayer),
        title: Text(
          name,
          style: TextStyle(
            fontFamily: 'NotoSansBengali',
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isPast && !isCurrent ? AppColors.sandMid : AppColors.marble,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldWarm,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lang == 'bn' ? 'এখন' : 'Now',
                  style: const TextStyle(
                    fontFamily: 'NotoSansBengali',
                    color: AppColors.sky0,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (isPast && !isCurrent)
              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.domePale),
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 15,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? AppColors.goldWarm : AppColors.sand,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerIcon extends StatelessWidget {
  const _PrayerIcon({required this.color, required this.prayer});
  final Color       color;
  final PrayerEntry prayer;

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
    child: Icon(_iconFor(prayer), color: color, size: 18),
  );

  IconData _iconFor(PrayerEntry p) => switch (p) {
    PrayerEntry.fajr    => Icons.dark_mode_rounded,
    PrayerEntry.shuruq  => Icons.wb_twilight_rounded,
    PrayerEntry.dhuhr   => Icons.wb_sunny_rounded,
    PrayerEntry.asr     => Icons.filter_drama_rounded,
    PrayerEntry.maghrib => Icons.wb_twilight_rounded,
    PrayerEntry.isha    => Icons.nights_stay_rounded,
    _                   => Icons.access_time_rounded,
  };
}
