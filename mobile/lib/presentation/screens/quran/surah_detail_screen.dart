import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatting.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../../data/models/surah_model.dart';
import '../../providers/settings_provider.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

/// Returns (SurahModel, List<AyahModel>) fetched from the API.
final surahDetailProvider = FutureProvider.family<
    (SurahModel, List<AyahModel>), int>((ref, surahNumber) async {
  final data = await ApiClient().getSurah(surahNumber);
  final surah = SurahModel.fromJson(data);
  final ayahsRaw = data['ayahs'] as List<dynamic>? ?? [];
  final ayahs = ayahsRaw
      .map((a) => AyahModel.fromJson(a as Map<String, dynamic>))
      .toList();
  return (surah, ayahs);
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
  Set<String> _bookmarked = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await DatabaseHelper.instance.getBookmarks('ayah');
    final prefix = '${widget.surahNumber}_';
    if (mounted) {
      setState(() {
        _bookmarked = bookmarks.where((id) => id.startsWith(prefix)).toSet();
      });
    }
  }

  String _ayahId(int ayahNumber) => '${widget.surahNumber}_$ayahNumber';

  @override
  Widget build(BuildContext context) {
    final settings  = ref.watch(settingsProvider);
    final lang      = settings.language;
    final isBn      = lang == 'bn';
    final display   = settings.quranDisplayMode;

    final surahAsync = ref.watch(surahDetailProvider(widget.surahNumber));

    return Scaffold(
      backgroundColor: AppColors.sky0,
      body: surahAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldWarm),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.marble)),
        ),
        data: (record) {
          final (surah, ayahs) = record;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: AppColors.sky1,
                foregroundColor: AppColors.marble,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.sky1, AppColors.sky3],
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
                              color: AppColors.goldWarm,
                            ),
                          ),
                          Text(
                            isBn ? surah.nameBangla : surah.nameEnglish,
                            style: const TextStyle(
                              fontFamily: 'NotoSansBengali',
                              color: AppColors.marble,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${isBn ? Formatting.toBanglaDigits(surah.ayahCount.toString()) : surah.ayahCount}'
                            ' ${isBn ? 'আয়াত' : 'Verses'} · '
                            '${isBn ? _revelationTypeBn(surah.revelationType) : surah.revelationType.name}',
                            style: const TextStyle(
                              fontFamily: 'NotoSansBengali',
                              color: AppColors.sand,
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
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.goldBd),
                      ),
                    ),
                    child: const Text(
                      'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                      style: TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 26,
                        color: AppColors.goldWarm,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),

              // Ayah list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final ayah = ayahs[i];
                    final id   = _ayahId(ayah.ayahNumber);
                    return _AyahCard(
                      ayah:            ayah,
                      isBn:            isBn,
                      displayMode:     display,
                      isBookmarked:    _bookmarked.contains(id),
                      onBookmarkToggle: () => _toggleBookmark(ayah),
                    );
                  },
                  childCount: ayahs.length,
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
    final id           = _ayahId(ayah.ayahNumber);
    final isBookmarked = _bookmarked.contains(id);
    if (isBookmarked) {
      await DatabaseHelper.instance.removeBookmark('ayah', id);
      setState(() => _bookmarked.remove(id));
    } else {
      await DatabaseHelper.instance.addBookmark('ayah', id);
      setState(() => _bookmarked.add(id));
    }
  }

  String _revelationTypeBn(RevelationType t) =>
      t == RevelationType.meccan ? 'মক্কী' : 'মাদানী';
}

// ── Ayah card ─────────────────────────────────────────────────────────────────

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.ayah,
    required this.isBn,
    required this.displayMode,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  final AyahModel    ayah;
  final bool         isBn;
  final String       displayMode;
  final bool         isBookmarked;
  final VoidCallback onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    final showBn = displayMode == 'arabic_bn' || displayMode == 'all';
    final showEn = displayMode == 'arabic_en' || displayMode == 'all';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sky2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBookmarked
              ? AppColors.goldWarm.withOpacity(0.5)
              : AppColors.goldBd,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.dome.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.domeBd),
                  ),
                  child: Center(
                    child: Text(
                      isBn
                          ? Formatting.toBanglaDigits(ayah.ayahNumber.toString())
                          : '${ayah.ayahNumber}',
                      style: const TextStyle(
                        fontFamily: 'NotoSansBengali',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.domePale,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Bookmark toggle
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.goldWarm : AppColors.sandMid,
                    size: 20,
                  ),
                  onPressed: onBookmarkToggle,
                  tooltip: isBn ? 'বুকমার্ক' : 'Bookmark',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                // Copy arabic
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: AppColors.sandMid),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ayah.arabicText));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: AppColors.sky3,
                      content: Text(
                        isBn ? 'আরবি কপি হয়েছে' : 'Arabic copied',
                        style: const TextStyle(color: AppColors.marble),
                      ),
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
                ayah.arabicText,
                style: const TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: 22,
                  height: 2.0,
                  color: AppColors.marble,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),

          // Bangla translation
          if (showBn && ayah.banglaTranslation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                ayah.banglaTranslation,
                style: const TextStyle(
                  fontFamily: 'NotoSansBengali',
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.sand,
                ),
              ),
            ),

          // English translation
          if (showEn && ayah.englishTranslation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                '"${ayah.englishTranslation}"',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.sandMid,
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
