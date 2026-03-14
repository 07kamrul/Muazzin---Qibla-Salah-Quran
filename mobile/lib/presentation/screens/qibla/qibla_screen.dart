import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatting.dart';
import '../../../domain/services/qibla_service.dart';
import '../../providers/qibla_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/compass_widget.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang     = ref.watch(settingsProvider).language;
    final qState   = ref.watch(qiblaStateProvider);

    // Haptic feedback when aligned
    ref.listen(qiblaStateProvider, (prev, next) {
      if (next != null && next.isAligned && (prev == null || !prev.isAligned)) {
        HapticFeedback.mediumImpact();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.sky0,
      appBar: AppBar(
        backgroundColor: AppColors.sky1,
        foregroundColor: AppColors.marble,
        elevation: 0,
        title: Text(
          lang == 'bn' ? 'কিবলার দিক' : 'Qibla Direction',
          style: const TextStyle(fontFamily: 'NotoSansBengali', color: AppColors.marble),
        ),
      ),
      body: qState == null
          ? _buildLoading(lang)
          : _buildCompass(context, qState, lang),
    );
  }

  Widget _buildLoading(String lang) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.goldWarm),
        const SizedBox(height: 16),
        Text(
          lang == 'bn' ? 'কম্পাস লোড হচ্ছে...' : 'Loading compass...',
          style: const TextStyle(color: AppColors.sand),
        ),
      ],
    ),
  );

  Widget _buildCompass(
    BuildContext context,
    ({double bearing, double heading, bool isAligned, double deviation}) qState,
    String lang,
  ) {
    final bearingStr = lang == 'bn'
        ? '${Formatting.toBanglaDigits(qState.bearing.toStringAsFixed(1))}°'
        : '${qState.bearing.toStringAsFixed(1)}°';
    final cardinal = QiblaService.instance.cardinalDirection(qState.bearing, lang);

    return Column(
      children: [
        const SizedBox(height: 24),

        // Alignment status
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: qState.isAligned
                ? AppColors.domeGlow
                : AppColors.goldGlow,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: qState.isAligned ? AppColors.domePale : AppColors.goldWarm,
            ),
          ),
          child: Text(
            qState.isAligned
                ? (lang == 'bn' ? '✅ কিবলামুখী' : '✅ Facing Qibla')
                : (lang == 'bn' ? 'ডিভাইস ঘুরান' : 'Rotate device'),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: qState.isAligned ? AppColors.domePale : AppColors.goldWarm,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Compass
        Expanded(
          child: Center(
            child: CompassWidget(
              compassHeading: qState.heading,
              qiblaBearing:  qState.bearing,
              isAligned:     qState.isAligned,
            ),
          ),
        ),

        // Bearing info
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '$bearingStr $cardinal',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldWarm,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lang == 'bn' ? 'কাবার দিক' : 'Direction to Kaaba',
                style: const TextStyle(fontFamily: 'NotoSansBengali', color: AppColors.sandMid, fontSize: 13),
              ),
            ],
          ),
        ),

        // Calibration button
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: TextButton.icon(
            icon: const Icon(Icons.rotate_right_rounded),
            label: Text(lang == 'bn' ? 'ক্যালিব্রেট করুন' : 'Calibrate'),
            onPressed: () => _showCalibrationDialog(context, lang),
          ),
        ),
      ],
    );
  }

  void _showCalibrationDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang == 'bn' ? 'কম্পাস ক্যালিব্রেশন' : 'Compass Calibration'),
        content: Text(
          lang == 'bn'
              ? 'ডিভাইসটি ধরে ৮-আকারে তিনবার ঘোরান।'
              : 'Move your device in a figure-8 pattern three times.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang == 'bn' ? 'ঠিক আছে' : 'OK'),
          ),
        ],
      ),
    );
  }
}
