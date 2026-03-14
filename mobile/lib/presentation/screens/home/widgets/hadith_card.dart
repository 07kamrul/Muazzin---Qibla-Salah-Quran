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

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1508), AppColors.sky2],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Green dome header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.dome, Color(0xFF112A1C)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang == 'bn' ? 'আজকের হাদিস' : "Today's Hadith",
                    style: const TextStyle(
                      fontFamily: 'NotoSansBengali',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.marble,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Share.share(
                      '${h.banglaTranslation}\n\n— ${h.source} #${h.hadithNumber}',
                    ),
                    child: const Icon(Icons.share_rounded, color: AppColors.goldWarm, size: 18),
                  ),
                ],
              ),
            ),

            // Arabic
            if (h.arabicText != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  h.arabicText!,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 19,
                    color: AppColors.marble,
                    height: 2.1,
                  ),
                ),
              ),

            const Divider(color: AppColors.goldBd, height: 1),

            // Bangla
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                firstChild: Text(
                  _preview(h.banglaTranslation),
                  style: const TextStyle(fontFamily: 'NotoSansBengali', fontSize: 13, color: AppColors.sand, height: 1.75),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.banglaTranslation, style: const TextStyle(fontFamily: 'NotoSansBengali', fontSize: 13, color: AppColors.sand, height: 1.75)),
                    const SizedBox(height: 8),
                    Text(h.englishTranslation, style: const TextStyle(fontSize: 12, color: AppColors.sandMid, fontStyle: FontStyle.italic, height: 1.6)),
                  ],
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              ),
            ),

            // Source row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${h.source} • ${lang == 'bn' ? 'হাদিস' : 'Hadith'} #${h.hadithNumber}',
                    style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 12, color: AppColors.goldWarm),
                  ),
                  if (!_expanded)
                    Text(
                      lang == 'bn' ? 'আরও পড়ুন ›' : 'Read more ›',
                      style: const TextStyle(fontFamily: 'NotoSansBengali', fontSize: 11, color: AppColors.domePale),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _preview(String text) =>
      text.length > 100 ? '${text.substring(0, 100)}…' : text;
}
