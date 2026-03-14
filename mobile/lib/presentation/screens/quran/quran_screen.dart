import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatting.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../../data/models/surah_model.dart';
import '../../providers/settings_provider.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final surahListProvider = FutureProvider<List<SurahModel>>((ref) async {
  final maps = await ApiClient().getSurahs();
  return maps.map(SurahModel.fromJson).toList();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang     = ref.watch(settingsProvider).language;
    final isBn     = lang == 'bn';
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'কুরআন' : 'Quran'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isBn ? 'সূরা' : 'Surah'),
            Tab(text: isBn ? 'বুকমার্ক' : 'Bookmarks'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isBn ? 'সূরা খুঁজুন...' : 'Search Surah...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Surah list tab
                surahsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (surahs) {
                    final filtered = _searchQuery.isEmpty
                        ? surahs
                        : surahs.where((s) =>
                            s.nameArabic.contains(_searchQuery) ||
                            s.nameBangla.contains(_searchQuery) ||
                            s.nameEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            s.number.toString() == _searchQuery).toList();

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _SurahListItem(
                        surah: filtered[i],
                        isBn: isBn,
                        onTap: () => context.push('/quran/${filtered[i].number}'),
                      ),
                    );
                  },
                ),

                // Bookmarks tab
                _BookmarksTab(isBn: isBn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Surah list item ───────────────────────────────────────────────────────────

class _SurahListItem extends StatelessWidget {
  const _SurahListItem({
    required this.surah,
    required this.isBn,
    required this.onTap,
  });

  final SurahModel surah;
  final bool       isBn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Surah number badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  isBn
                      ? Formatting.toBanglaDigits(surah.number.toString())
                      : '${surah.number}',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? surah.nameBangla : surah.nameEnglish,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${isBn ? Formatting.toBanglaDigits(surah.ayahCount.toString()) : surah.ayahCount} '
                    '${isBn ? 'আয়াত' : 'verses'} · '
                    '${isBn ? _revelationTypeBn(surah.revelationType) : surah.revelationType.name}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Arabic name
            Text(
              surah.nameArabic,
              style: const TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 20,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _revelationTypeBn(RevelationType t) =>
      t == RevelationType.meccan ? 'মক্কী' : 'মাদানী';
}

// ── Bookmarks tab ─────────────────────────────────────────────────────────────

class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab({required this.isBn});

  final bool isBn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getBookmarks('ayah').then((ids) => ids.map((id) => <String, dynamic>{'id': id}).toList()),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final bookmarks = snap.data ?? [];

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  isBn ? 'কোনো বুকমার্ক নেই' : 'No bookmarks yet',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  isBn
                      ? 'কুরআন পড়তে গিয়ে বুকমার্ক করুন'
                      : 'Bookmark ayahs while reading',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (_, i) {
            final b = bookmarks[i];
            return ListTile(
              leading: const Icon(Icons.bookmark, color: AppColors.gold),
              title: Text(
                '${isBn ? 'সূরা' : 'Surah'} ${b['surah_number']} · '
                '${isBn ? 'আয়াত' : 'Ayah'} ${b['ayah_number']}',
              ),
              subtitle: Text(
                b['note'] as String? ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => context.push('/quran/${b['surah_number']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () async {
                  await DatabaseHelper.instance
                      .removeBookmark('ayah', b['id'] as String);
                },
              ),
            );
          },
        );
      },
    );
  }
}
