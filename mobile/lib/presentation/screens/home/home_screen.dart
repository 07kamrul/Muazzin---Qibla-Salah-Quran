import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/hijri_calendar.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../providers/location_provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/haramain_atoms.dart';
import 'widgets/countdown_timer.dart';
import 'widgets/hadith_card.dart';
import 'widgets/prayer_time_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings   = ref.watch(settingsProvider);
    final lang       = settings.language;
    final timesAsync = ref.watch(prayerTimesProvider);
    final locAsync   = ref.watch(locationProvider);
    final nextAsync  = ref.watch(nextPrayerProvider);
    final countdown  = ref.watch(countdownProvider);

    final today = DateTime.now();
    final isRam = HijriCalendarUtil.isRamadan(today);

    return Scaffold(
      backgroundColor: AppColors.sky0,
      appBar: AppBar(
        backgroundColor: AppColors.sky1,
        foregroundColor: AppColors.marble,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang == 'bn' ? 'মুয়াজ্জিন' : 'Muazzin',
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.marble,
              ),
            ),
            Text(
              '${HijriCalendarUtil.formatHijri(today, lang)}  •  ${Formatting.formatDate(today, lang)}',
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.sand,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.goldWarm),
            tooltip: lang == 'bn' ? 'অবস্থান আপডেট' : 'Refresh location',
            onPressed: () => ref.read(locationProvider.notifier).refresh(),
          ),
          if (isRam)
            IconButton(
              icon: const Icon(Icons.nightlight_round, color: AppColors.goldWarm),
              tooltip: lang == 'bn' ? 'রমজান' : 'Ramadan',
              onPressed: () => Navigator.of(context).pushNamed('/ramadan'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.goldBd),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.goldWarm,
        backgroundColor: AppColors.sky2,
        onRefresh: () => ref.read(locationProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Location banner
            SliverToBoxAdapter(
              child: locAsync.when(
                loading: _locationShimmer,
                error: (e, _) => _locationError(e.toString(), lang),
                data: (loc) => _LocationBanner(loc: '${loc.district}, ${loc.division}'),
              ),
            ),

            // Starfield decoration
            const SliverToBoxAdapter(child: SizedBox.shrink()),

            // Next prayer countdown
            SliverToBoxAdapter(
              child: nextAsync.when(
                loading: _countdownShimmer,
                error: (_, __) => const SizedBox.shrink(),
                data: (next) => _NextPrayerCard(
                  prayerName: lang == 'bn'
                      ? Formatting.prayerNameBn(next.key.name)
                      : Formatting.prayerNameEn(next.key.name),
                  countdown: countdown.when(
                    loading: () => Duration.zero,
                    error: (_, __) => Duration.zero,
                    data: (d) => d,
                  ),
                  lang: lang,
                ),
              ),
            ),

            // Ramadan banner
            if (isRam || settings.ramadanMode)
              SliverToBoxAdapter(child: _RamadanBanner(lang: lang)),

            // Prayer times list
            timesAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _prayerShimmer(),
                  childCount: 6,
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Text(e.toString(),
                      style: const TextStyle(color: AppColors.marble)),
                ),
              ),
              data: (times) {
                final now     = DateTime.now();
                final current = times.getCurrentPrayer(now);
                final next    = times.getNextPrayer(now);

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final entry = times.toList()[i];
                      return PrayerTimeCard(
                        prayer:    entry.key,
                        time:      entry.value,
                        isCurrent: current == entry.key,
                        isNext:    next.key == entry.key && current != entry.key,
                        isPast:    entry.value.isBefore(now),
                        lang:      lang,
                      );
                    },
                    childCount: 6,
                  ),
                );
              },
            ),

            // Arabesque divider
            const SliverToBoxAdapter(child: ArabesqueBorder()),

            // Daily Hadith card
            SliverToBoxAdapter(
              child: FutureBuilder(
                future: DatabaseHelper.instance.getDailyHadith(DateTime.now()),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: HadithCard(hadith: snapshot.data!, lang: lang),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  static Widget _locationShimmer() => Shimmer.fromColors(
    baseColor: AppColors.sky3,
    highlightColor: AppColors.sky4,
    child: Container(
      height: 40,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sky3,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static Widget _locationError(String msg, String lang) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      lang == 'bn' ? 'অবস্থান পাওয়া যায়নি' : 'Location unavailable',
      style: const TextStyle(color: AppColors.error),
    ),
  );

  static Widget _countdownShimmer() => Shimmer.fromColors(
    baseColor: AppColors.sky3,
    highlightColor: AppColors.sky4,
    child: Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sky3,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static Widget _prayerShimmer() => Shimmer.fromColors(
    baseColor: AppColors.sky3,
    highlightColor: AppColors.sky4,
    child: Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sky3,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.loc});
  final String loc;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    child: Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: AppColors.goldWarm),
        const SizedBox(width: 4),
        Text(
          loc,
          style: const TextStyle(
            fontFamily: 'NotoSansBengali',
            color: AppColors.sand,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.prayerName,
    required this.countdown,
    required this.lang,
  });
  final String   prayerName;
  final Duration countdown;
  final String   lang;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.sky2, AppColors.sky3],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBd),
          boxShadow: [
            BoxShadow(
              color: AppColors.domeGlow,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              lang == 'bn' ? 'পরবর্তী নামাজ' : 'Next Prayer',
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                color: AppColors.sand,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prayerName,
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                color: AppColors.goldWarm,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            CountdownTimer(remaining: countdown, lang: lang, large: true),
          ],
        ),
      ),
      Positioned(
        top: 12,
        right: 16,
        child: Opacity(
          opacity: 0.15,
          child: MosqueSilhouette(
            width: 100,
            color: AppColors.goldPale,
            opacity: 1,
          ),
        ),
      ),
    ],
  );
}

class _RamadanBanner extends StatelessWidget {
  const _RamadanBanner({required this.lang});
  final String lang;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.goldGlow,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.goldBd),
    ),
    child: Row(
      children: [
        const OctaStar(size: 18, color: AppColors.goldWarm),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            lang == 'bn'
                ? 'রমজান মোবারক — সেহরি ও ইফতারের সময় দেখতে ট্যাপ করুন'
                : 'Ramadan Mubarak — Tap to see Sehri & Iftar times',
            style: const TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.goldWarm,
            ),
          ),
        ),
      ],
    ),
  );
}
