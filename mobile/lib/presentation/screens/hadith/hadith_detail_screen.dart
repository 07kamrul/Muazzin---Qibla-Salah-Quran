import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/models/hadith_model.dart';
import '../../providers/settings_provider.dart';

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
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final hadithAsync = ref.watch(hadithDetailProvider(hadithId));

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'হাদিস' : 'Hadith'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
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
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('$e')),
        data: (hadith) {
          if (hadith == null) {
            return Center(
              child: Text(isBn ? 'হাদিস পাওয়া যায়নি' : 'Hadith not found'),
            );
          }
          return _HadithBody(hadith: hadith, isBn: isBn);
        },
      ),
    );
  }

  String _buildShareText(HadithModel h, bool isBn) {
    final parts = <String>[];
    if (h.textArabic != null) parts.add(h.textArabic!);
    if (isBn) {
      parts.add(h.textBn);
    } else {
      if (h.textEn != null) parts.add(h.textEn!);
    }
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, Color(0xFF2D6A4F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '📖',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  isBn ? 'হাদিস #${hadith.hadithNumber}' : 'Hadith #${hadith.hadithNumber}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  hadith.source,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Arabic text
          if (hadith.textArabic != null)
            _ContentBlock(
              label: isBn ? 'আরবি' : 'Arabic',
              labelColor: AppColors.gold,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  hadith.textArabic!,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 22,
                    height: 2.0,
                    color: AppColors.primaryGreen,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Bangla text
          _ContentBlock(
            label: isBn ? 'বাংলা অনুবাদ' : 'Bangla Translation',
            labelColor: AppColors.primaryGreen,
            child: Text(
              hadith.textBn,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ),

          // English text
          if (hadith.textEn != null) ...[
            const SizedBox(height: 16),
            _ContentBlock(
              label: 'English Translation',
              labelColor: Colors.blueGrey,
              child: Text(
                '"${hadith.textEn!}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Source info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, color: AppColors.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hadith.source,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                      if (hadith.narrator != null)
                        Text(
                          '${isBn ? 'বর্ণনাকারী:' : 'Narrator:'} ${hadith.narrator}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (hadith.grade != null)
                        Text(
                          '${isBn ? 'মান:' : 'Grade:'} ${hadith.grade}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
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
