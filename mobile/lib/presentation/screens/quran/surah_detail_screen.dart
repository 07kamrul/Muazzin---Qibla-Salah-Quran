import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatting.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/models/surah_model.dart';
import '../../providers/settings_provider.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final surahDetailProvider =
    FutureProvider.family<SurahModel?, int>((ref, surahNumber) async {
  return DatabaseHelper.instance.getSurahWithAyahs(surahNumber);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class SurahDetailScreen extends ConsumerStatefulWidget {
  const SurahDetailScreen({required this.surahNumber, super.key});

  final int surahNumber;

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  final _scrollController = ScrollController();
  Set<int> _bookmarked = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await DatabaseHelper.instance
        .getBookmarksForSurah(widget.surahNumber);
    if (mounted) {
      setState(() {
        _bookmarked = bookmarks.map((b) => b['ayah_number'] as int).toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang     = settings.language;
    final isBn     = lang == 'bn';
    final display  = settings.quranDisplayMode; // 'arabic_only', 'arabic_bn', 'arabic_en', 'all'

    final surahAsync = ref.watch(surahDetailProvider(widget.surahNumber));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: surahAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (surah) {
          if (surah == null) {
            return Center(
              child: Text(isBn ? 'সূরা পাওয়া যায়নি' : 'Surah not found'),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar with surah info
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryGreen, Color(0xFF2D6A4F)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            surah.nameArabic,
                            style: const TextStyle(
                              fontFamily: 'AmiriQuran',
                              fontSize: 32,
                              color: AppColors.gold,
                            ),
                          ),
                          Text(
                            isBn ? surah.nameBn : surah.nameEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${isBn ? Formatting.toBanglaDigits(surah.totalAyahs) : surah.totalAyahs}'
                            ' ${isBn ? 'আয়াত' : 'Verses'} · '
                            '${isBn ? _revelationTypeBn(surah.revelationType) : surah.revelationType.name}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bismillah (all surahs except At-Tawbah & Al-Fatiha itself)
              if (surah.number != 9 && surah.number != 1)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    child: const Text(
                      'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                      style: TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 26,
                        color: AppColors.primaryGreen,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),

              // Ayah list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final ayah = surah.ayahs[i];
                    return _AyahCard(
                      ayah: ayah,
                      surahNumber: surah.number,
                      isBn: isBn,
                      displayMode: display,
                      isBookmarked: _bookmarked.contains(ayah.number),
                      onBookmarkToggle: () => _toggleBookmark(ayah),
                    );
                  },
                  childCount: surah.ayahs.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleBookmark(AyahModel ayah) async {
    final isBookmarked = _bookmarked.contains(ayah.number);
    if (isBookmarked) {
      await DatabaseHelper.instance.removeBookmarkByAyah(
        widget.surahNumber, ayah.number,
      );
      setState(() => _bookmarked.remove(ayah.number));
    } else {
      await DatabaseHelper.instance.addBookmark(
        surahNumber: widget.surahNumber,
        ayahNumber: ayah.number,
      );
      setState(() => _bookmarked.add(ayah.number));
    }
  }

  String _revelationTypeBn(RevelationType t) =>
      t == RevelationType.meccan ? 'মক্কী' : 'মাদানী';
}

// ── Ayah card ─────────────────────────────────────────────────────────────────

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.ayah,
    required this.surahNumber,
    required this.isBn,
    required this.displayMode,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  final AyahModel ayah;
  final int       surahNumber;
  final bool      isBn;
  final String    displayMode; // 'arabic_only' | 'arabic_bn' | 'arabic_en' | 'all'
  final bool      isBookmarked;
  final VoidCallback onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final showBn = displayMode == 'arabic_bn' || displayMode == 'all';
    final showEn = displayMode == 'arabic_en' || displayMode == 'all';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isBookmarked
            ? Border.all(color: AppColors.gold.withOpacity(0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: ayah number + actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Ayah number medallion
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isBn
                          ? Formatting.toBanglaDigits(ayah.number)
                          : '${ayah.number}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Bookmark toggle
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.gold : Colors.grey,
                    size: 20,
                  ),
                  onPressed: onBookmarkToggle,
                  tooltip: isBn ? 'বুকমার্ক' : 'Bookmark',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                // Copy arabic
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ayah.textArabic));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isBn ? 'আরবি কপি হয়েছে' : 'Arabic copied'),
                      duration: const Duration(seconds: 1),
                    ));
                  },
                  tooltip: isBn ? 'কপি করুন' : 'Copy',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),

          // Arabic text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                ayah.textArabic,
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

          // Bangla translation
          if (showBn && ayah.translationBn != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                ayah.translationBn!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),

          // English translation
          if (showEn && ayah.translationEn != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                '"${ayah.translationEn!}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
