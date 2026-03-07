import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/hijri_calendar.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../providers/location_provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/settings_provider.dart';

// ── Ramadan calendar entry ─────────────────────────────────────────────────

class RamadanDay {
  const RamadanDay({
    required this.day,
    required this.gregorianDate,
    required this.sehriTime,
    required this.iftarTime,
  });

  final int      day;
  final DateTime gregorianDate;
  final DateTime sehriTime;
  final DateTime iftarTime;
}

// ── Provider ─────────────────────────────────────────────────────────────────

final ramadanCalendarProvider = FutureProvider<List<RamadanDay>>((ref) async {
  final locAsync = ref.watch(locationProvider);
  final loc      = locAsync.valueOrNull;
  if (loc == null) return [];

  final settings = ref.watch(settingsProvider);
  final cached   = await DatabaseHelper.instance.getRamadanCalendar();
  if (cached.isNotEmpty) {
    return cached.map((row) => RamadanDay(
      day:          row['day'] as int,
      gregorianDate: DateTime.parse(row['gregorian_date'] as String),
      sehriTime:    DateTime.parse(row['sehri_time'] as String),
      iftarTime:    DateTime.parse(row['iftar_time'] as String),
    )).toList();
  }

  // Calculate 30 days of Ramadan
  final hijri = HijriCalendarUtil.fromGregorian(DateTime.now());
  // Estimate Ramadan 1st: this is simplified; production would use proper Hijri lib
  final now     = DateTime.now();
  final ramadan = <RamadanDay>[];

  for (var i = 0; i < 30; i++) {
    final date      = now.add(Duration(days: i));
    final prayerTimes = await ref
        .read(prayerTimeServiceProvider)
        .calculateForDate(date, loc, settings.calculationMethod);

    // Sehri = 10 min before Fajr
    final sehri = prayerTimes.fajr.subtract(const Duration(minutes: 10));
    // Iftar = Maghrib
    final iftar = prayerTimes.maghrib;

    ramadan.add(RamadanDay(
      day:          i + 1,
      gregorianDate: date,
      sehriTime:    sehri,
      iftarTime:    iftar,
    ));
  }

  // Cache in DB
  await DatabaseHelper.instance.cacheRamadanCalendar(
    ramadan.map((r) => {
      'day':           r.day,
      'gregorian_date': r.gregorianDate.toIso8601String(),
      'sehri_time':    r.sehriTime.toIso8601String(),
      'iftar_time':    r.iftarTime.toIso8601String(),
    }).toList(),
  );

  return ramadan;
});

// ── Screen ────────────────────────────────────────────────────────────────────

class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang         = ref.watch(settingsProvider).language;
    final isBn         = lang == 'bn';
    final calendarAsync = ref.watch(ramadanCalendarProvider);
    final today        = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'রমজান' : 'Ramadan'),
      ),
      body: calendarAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (days) {
          if (days.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    isBn
                        ? 'রমজানের সময়সূচি পাওয়া যায়নি'
                        : 'Ramadan schedule unavailable',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    isBn ? 'অবস্থান চালু করুন' : 'Enable location',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          // Find today's entry
          final todayEntry = days.where((d) =>
              d.gregorianDate.day == today.day &&
              d.gregorianDate.month == today.month).firstOrNull;

          return CustomScrollView(
            slivers: [
              // Today's card
              SliverToBoxAdapter(
                child: _TodayCard(
                  day: todayEntry,
                  isBn: isBn,
                  today: today,
                ),
              ),

              // Taraweeh reminder
              SliverToBoxAdapter(
                child: _TaraweehBanner(isBn: isBn),
              ),

              // Calendar header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    isBn ? '৩০ দিনের সময়সূচি' : '30-Day Schedule',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),

              // Calendar list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final d = days[i];
                    final isToday = d.gregorianDate.day == today.day &&
                        d.gregorianDate.month == today.month;
                    return _CalendarRow(
                      day: d,
                      isBn: isBn,
                      isToday: isToday,
                    );
                  },
                  childCount: days.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

// ── Today card ────────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.day,
    required this.isBn,
    required this.today,
  });

  final RamadanDay? day;
  final bool        isBn;
  final DateTime    today;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌙', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                isBn ? 'রমজান মোবারক' : 'Ramadan Mubarak',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (day != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TimeDisplay(
                    icon: '🌅',
                    label: isBn ? 'সেহরি' : 'Sehri',
                    time: Formatting.formatTime(day!.sehriTime, isBn),
                    subtitleColor: Colors.white70,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white24,
                ),
                Expanded(
                  child: _TimeDisplay(
                    icon: '🌇',
                    label: isBn ? 'ইফতার' : 'Iftar',
                    time: Formatting.formatTime(day!.iftarTime, isBn),
                    subtitleColor: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Countdown to Iftar
            _IftarCountdown(iftarTime: day!.iftarTime, isBn: isBn),
          ],
        ],
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay({
    required this.icon,
    required this.label,
    required this.time,
    required this.subtitleColor,
  });

  final String icon;
  final String label;
  final String time;
  final Color  subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: subtitleColor, fontSize: 12)),
        Text(time, style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        )),
      ],
    );
  }
}

class _IftarCountdown extends StatelessWidget {
  const _IftarCountdown({required this.iftarTime, required this.isBn});

  final DateTime iftarTime;
  final bool     isBn;

  @override
  Widget build(BuildContext context) {
    final now      = DateTime.now();
    final diff     = iftarTime.difference(now);

    if (diff.isNegative) {
      return Text(
        isBn ? 'ইফতার হয়ে গেছে' : 'Iftar time has passed',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      );
    }

    final countdown = Formatting.formatCountdownHMS(diff, isBn);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${isBn ? 'ইফতার পর্যন্ত:' : 'Until Iftar:'} $countdown',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

// ── Taraweeh banner ───────────────────────────────────────────────────────────

class _TaraweehBanner extends StatelessWidget {
  const _TaraweehBanner({required this.isBn});

  final bool isBn;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'তারাবিহ নামাজ' : 'Taraweeh Prayer',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                Text(
                  isBn
                      ? 'ইশার পরে ২০ রাকাত তারাবিহ পড়ুন'
                      : 'Pray 20 rakaat Taraweeh after Isha',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Calendar row ──────────────────────────────────────────────────────────────

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({
    required this.day,
    required this.isBn,
    required this.isToday,
  });

  final RamadanDay day;
  final bool       isBn;
  final bool       isToday;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final passed = DateTime.now().isAfter(day.iftarTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primaryGreen.withOpacity(0.1)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppColors.primaryGreen, width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          // Day number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.primaryGreen
                  : passed
                      ? Colors.grey.withOpacity(0.15)
                      : AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isBn
                    ? Formatting.toBanglaDigits(day.day)
                    : '${day.day}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isToday ? Colors.white : AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Gregorian date
          Expanded(
            flex: 2,
            child: Text(
              '${_dayName(day.gregorianDate.weekday, isBn)}, '
              '${isBn ? Formatting.toBanglaDigits(day.gregorianDate.day) : day.gregorianDate.day} '
              '${_monthName(day.gregorianDate.month, isBn)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isToday ? FontWeight.w600 : null,
              ),
            ),
          ),

          // Sehri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isBn ? 'সেহরি' : 'Sehri',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  Formatting.formatTime(day.sehriTime, isBn),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Iftar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isBn ? 'ইফতার' : 'Iftar',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  Formatting.formatTime(day.iftarTime, isBn),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isToday ? AppColors.primaryGreen : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday, bool isBn) {
    const bn = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return isBn ? bn[weekday - 1] : en[weekday - 1];
  }

  String _monthName(int month, bool isBn) {
    const bn = ['জান', 'ফেব', 'মার', 'এপ্র', 'মে', 'জুন',
                 'জুল', 'আগ', 'সেপ', 'অক্ট', 'নভ', 'ডিস'];
    const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return isBn ? bn[month - 1] : en[month - 1];
  }
}
