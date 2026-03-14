import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/models/hadith_model.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/haramain_atoms.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final hadithDetailProvider =
    FutureProvider.family<HadithModel?, int>((ref, id) async {
  return DatabaseHelper.instance.getHadithById(id);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class HadithDetailScreen extends ConsumerWidget {
  const HadithDetailScreen({required this.hadithId, super.key});

  final int hadithId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn       = ref.watch(settingsProvider).language == 'bn';
    final hadithAsync = ref.watch(hadithDetailProvider(hadithId));

    return Scaffold(
      backgroundColor: AppColors.sky0,
      appBar: AppBar(
        backgroundColor: AppColors.sky1,
        iconTheme: const IconThemeData(color: AppColors.goldWarm),
        title: Text(
          isBn ? 'হাদিস' : 'Hadith',
          style: const TextStyle(
            fontFamily: 'NotoSansBengali',
            color: AppColors.marble,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.goldWarm),
            tooltip: isBn ? 'কপি করুন' : 'Copy',
            onPressed: () => hadithAsync.whenData((h) {
              if (h == null) return;
              final text = _buildShareText(h, isBn);
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isBn ? 'কপি হয়েছে' : 'Copied'),
                duration: const Duration(seconds: 1),
              ));
            }),
          ),
        ],
      ),
      body: hadithAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldWarm),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.sandMid)),
        ),
        data: (hadith) {
          if (hadith == null) {
            return Center(
              child: Text(
                isBn ? 'হাদিস পাওয়া যায়নি' : 'Hadith not found',
                style: const TextStyle(color: AppColors.sandMid),
              ),
            );
          }
          return _HadithBody(hadith: hadith, isBn: isBn);
        },
      ),
    );
  }

  String _buildShareText(HadithModel h, bool isBn) {
    final parts = <String>[];
    if (h.arabicText != null) parts.add(h.arabicText!);
    parts.add(isBn ? h.banglaTranslation : h.englishTranslation);
    parts.add('— ${h.source} (${isBn ? 'হাদিস' : 'Hadith'} #${h.hadithNumber})');
    return parts.join('\n\n');
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _HadithBody extends StatelessWidget {
  const _HadithBody({required this.hadith, required this.isBn});

  final HadithModel hadith;
  final bool        isBn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.dome, Color(0xFF112A1C)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.domeBd),
            ),
            child: Stack(
              children: [
                const StarfieldWidget(count: 10),
                Column(
                  children: [
                    Text(
                      isBn
                          ? 'হাদিস #${hadith.hadithNumber}'
                          : 'Hadith #${hadith.hadithNumber}',
                      style: const TextStyle(
                        fontFamily: 'NotoSansBengali',
                        color: AppColors.goldWarm,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hadith.source,
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 16,
                        color: AppColors.marble,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Arabic text
          if (hadith.arabicText != null) ...[
            _ContentBlock(
              label: isBn ? 'আরবি' : 'Arabic',
              labelColor: AppColors.goldWarm,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  hadith.arabicText!,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 22,
                    height: 2.1,
                    color: AppColors.marble,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Bangla text
          _ContentBlock(
            label: isBn ? 'বাংলা অনুবাদ' : 'Bangla Translation',
            labelColor: AppColors.domePale,
            child: Text(
              hadith.banglaTranslation,
              style: const TextStyle(
                fontFamily: 'NotoSansBengali',
                fontSize: 14,
                color: AppColors.sand,
                height: 1.75,
              ),
            ),
          ),

          // English text
          const SizedBox(height: 16),
          _ContentBlock(
            label: 'English Translation',
            labelColor: AppColors.sandMid,
            child: Text(
              '"${hadith.englishTranslation}"',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.65,
                color: AppColors.sandMid,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Source info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldGlow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldBd),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, color: AppColors.goldWarm, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hadith.bookName,
                        style: const TextStyle(
                          fontFamily: 'NotoSansBengali',
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldWarm,
                          fontSize: 13,
                        ),
                      ),
                      if (hadith.narrator != null)
                        Text(
                          '${isBn ? 'বর্ণনাকারী:' : 'Narrator:'} ${hadith.narrator}',
                          style: const TextStyle(
                            fontFamily: 'NotoSansBengali',
                            fontSize: 11,
                            color: AppColors.sandMid,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ContentBlock extends StatelessWidget {
  const _ContentBlock({
    required this.label,
    required this.labelColor,
    required this.child,
  });

  final String label;
  final Color  labelColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: labelColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
