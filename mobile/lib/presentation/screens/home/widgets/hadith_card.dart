import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/hadith_model.dart';

class HadithCard extends StatefulWidget {
  const HadithCard({required this.hadith, required this.lang, super.key});
  final HadithModel hadith;
  final String      lang;

  @override
  State<HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<HadithCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final h    = widget.hadith;
    final lang = widget.lang;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.format_quote_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    lang == 'bn' ? 'আজকের হাদিস' : "Today's Hadith",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 18),
                    onPressed: () => Share.share(
                      '${h.banglaTranslation}\n\n— ${h.source} #${h.hadithNumber}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Arabic (only when expanded)
              if (_expanded && h.arabicText != null) ...[
                Text(
                  h.arabicText!,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 20,
                    height: 2.0,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                const Divider(height: 20),
              ],

              // Bangla translation
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                firstChild: Text(
                  _preview(h.banglaTranslation),
                  style: const TextStyle(fontSize: 14, height: 1.6),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.banglaTranslation, style: const TextStyle(fontSize: 14, height: 1.6)),
                    if (_expanded) ...[
                      const SizedBox(height: 8),
                      Text(
                        h.englishTranslation,
                        style: const TextStyle(fontSize: 13, color: AppColors.lightTextLight, height: 1.5),
                      ),
                    ],
                  ],
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              ),

              // Source
              const SizedBox(height: 8),
              Text(
                '${h.source} — ${lang == 'bn' ? 'হাদিস' : 'Hadith'} #${h.hadithNumber}',
                style: const TextStyle(fontSize: 12, color: AppColors.lightTextMuted),
              ),

              // Read more link
              if (!_expanded)
                TextButton(
                  onPressed: () => setState(() => _expanded = true),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 28)),
                  child: Text(
                    lang == 'bn' ? 'আরও পড়ুন' : 'Read more',
                    style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _preview(String text) =>
      text.length > 100 ? '${text.substring(0, 100)}…' : text;
}
