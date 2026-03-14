import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/haramain_atoms.dart';

class RamadanScreen extends ConsumerStatefulWidget {
  const RamadanScreen({super.key});

  @override
  ConsumerState<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends ConsumerState<RamadanScreen> {
  late Timer _timer;
  Duration _remaining = const Duration(hours: 5, minutes: 58);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_remaining.inSeconds > 0) {
            _remaining -= const Duration(seconds: 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(settingsProvider).language;
    final hh = _remaining.inHours.toString().padLeft(2, '0');
    final mm = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.sky0,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Night hero
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF120A0D), AppColors.sky1],
                  ),
                ),
                child: Stack(
                  children: [
                    const StarfieldWidget(count: 30),
                    Positioned(
                      bottom: -8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: MosqueSilhouette(
                          width: MediaQuery.of(context).size.width,
                          opacity: 0.06,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Column(
                        children: [
                          // Title
                          Column(
                            children: [
                              Text(
                                'رمضان المبارك',
                                style: const TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  fontSize: 30,
                                  color: AppColors.goldWarm,
                                  height: 1.4,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'RAMADAN MUBARAK \u2756 রমজান মুবারক',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.sandMid,
                                  letterSpacing: 4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Iftar countdown
                          Container(
                            padding: const EdgeInsets.all(17),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0x477A1E2A), Color(0x1FD4A840)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0x807A1E2A)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  lang == 'bn'
                                      ? 'ইফতার পর্যন্ত বাকি সময়'
                                      : 'Time until Iftar',
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansBengali',
                                    fontSize: 12,
                                    color: Color(0xFFE08888),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$hh:$mm:$ss',
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansBengali',
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.marble,
                                    letterSpacing: 6,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  lang == 'bn'
                                      ? 'ইফতার: ১৮:১৫ \u2022 সেহরি: ০৪:৪৭'
                                      : 'Iftar: 18:15 \u2022 Sehri: 04:47',
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansBengali',
                                    fontSize: 13,
                                    color: AppColors.goldWarm,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const ArabesqueBorder(),

              // Calendar
              Container(
                color: AppColors.sky1,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY SCHEDULE',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.sandDeep,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._ramadanDays
                        .map((r) => _RamadanDayTile(day: r, lang: lang)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _ramadanDays = [
    _RamadanDay(
        day: 1, dateBn: '\u09e7 রমজান', sehri: '\u09e6\u09ea:\u09eb\u09e8', iftar: '\u09e7\u09ee:\u09e7\u09e6'),
    _RamadanDay(
        day: 2, dateBn: '\u09e8 রমজান', sehri: '\u09e6\u09ea:\u09eb\u09e7', iftar: '\u09e7\u09ee:\u09e7\u09e7'),
    _RamadanDay(
        day: 3, dateBn: '\u09e9 রমজান', sehri: '\u09e6\u09ea:\u09eb\u09e6', iftar: '\u09e7\u09ee:\u09e7\u09e8'),
    _RamadanDay(
        day: 5, dateBn: '\u09eb রমজান', sehri: '\u09e6\u09ea:\u09ea\u09ee', iftar: '\u09e7\u09ee:\u09e7\u09ea'),
    _RamadanDay(
        day: 6,
        dateBn: '\u09ec রমজান',
        sehri: '\u09e6\u09ea:\u09ea\u09ed',
        iftar: '\u09e7\u09ee:\u09e7\u09eb',
        isToday: true),
    _RamadanDay(
        day: 7, dateBn: '\u09ed রমজান', sehri: '\u09e6\u09ea:\u09ea\u09ec', iftar: '\u09e7\u09ee:\u09e7\u09ec'),
    _RamadanDay(
        day: 27,
        dateBn: '\u09e8\u09ed রমজান',
        sehri: '\u09e6\u09ea:\u09e9\u09e6',
        iftar: '\u09e7\u09ee:\u09e8\u09ee',
        isLailat: true),
  ];
}

class _RamadanDay {
  const _RamadanDay({
    required this.day,
    required this.dateBn,
    required this.sehri,
    required this.iftar,
    this.isToday = false,
    this.isLailat = false,
  });

  final int day;
  final String dateBn;
  final String sehri;
  final String iftar;
  final bool isToday;
  final bool isLailat;
}

class _RamadanDayTile extends StatelessWidget {
  const _RamadanDayTile({required this.day, required this.lang});

  final _RamadanDay day;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        gradient: day.isToday
            ? const LinearGradient(
                colors: [Color(0x337A1E2A), Color(0xFA0E0A14)],
              )
            : null,
        color: day.isToday ? null : AppColors.sky3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: day.isToday
              ? const Color(0x727A1E2A)
              : day.isLailat
                  ? AppColors.goldBd
                  : const Color(0x0FFFFFFF),
        ),
      ),
      child: Row(
        children: [
          // Day number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: day.isLailat
                  ? const LinearGradient(
                      colors: [AppColors.gold, Color(0xFF6A4010)],
                    )
                  : null,
              color: day.isLailat
                  ? null
                  : day.isToday
                      ? const Color(0x4D7A1E2A)
                      : const Color(0x0AFFFFFF),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: day.isLailat
                    ? AppColors.gold
                    : day.isToday
                        ? const Color(0x807A1E2A)
                        : AppColors.sandDeep,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: day.isLailat ? AppColors.sky0 : AppColors.sand,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      day.dateBn,
                      style: TextStyle(
                        fontFamily: 'NotoSansBengali',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: day.isToday ? AppColors.marble : AppColors.sand,
                      ),
                    ),
                    if (day.isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0x407A1E2A),
                          borderRadius: BorderRadius.circular(7),
                          border:
                              Border.all(color: const Color(0x807A1E2A)),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                              fontSize: 8.5, color: Color(0xFFE09898)),
                        ),
                      ),
                    ],
                    if (day.isLailat) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.goldGlow,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: AppColors.goldBd),
                        ),
                        child: const Text(
                          '\u09b2\u09be\u0987\u09b2\u09be\u09a4\u09c1\u09b2 \u0995\u09a6\u09b0 \u2756',
                          style: TextStyle(
                            fontSize: 8.5,
                            color: AppColors.goldWarm,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${lang == 'bn' ? '\u09b8\u09c7\u09b9\u09b0\u09bf' : 'Sehri'} ${day.sehri}',
                  style: const TextStyle(
                    fontFamily: 'NotoSansBengali',
                    fontSize: 11,
                    color: AppColors.sandDeep,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                day.iftar,
                style: const TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldWarm,
                ),
              ),
              Text(
                lang == 'bn' ? '\u0987\u09ab\u09a4\u09be\u09b0' : 'Iftar',
                style: const TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 9.5,
                  color: AppColors.sandDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
