import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/models/mosque_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/mosque_list_item.dart';

class MosqueScreen extends ConsumerStatefulWidget {
  const MosqueScreen({super.key});

  @override
  ConsumerState<MosqueScreen> createState() => _MosqueScreenState();
}

class _MosqueScreenState extends ConsumerState<MosqueScreen> {
  int _selectedRadius = AppConfig.mosqueDefaultRadiusKm;
  List<MosqueModel> _mosques = [];
  bool _loading = false;
  MosqueModel? _selected;
  final _mapController    = MapController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMosques());
  }

  Future<void> _loadMosques() async {
    final loc = ref.read(locationProvider).valueOrNull;
    if (loc == null) return;

    setState(() => _loading = true);

    var mosques = await DatabaseHelper.instance.getMosquesNearby(
      loc.latitude, loc.longitude, _selectedRadius.toDouble(),
    );

    if (mosques.length < AppConfig.mosqueAutoExpandMinResults &&
        _selectedRadius < AppConfig.mosqueSearchRadii.last) {
      final nextRadius = AppConfig.mosqueSearchRadii
          .firstWhere((r) => r > _selectedRadius, orElse: () => _selectedRadius);
      if (nextRadius > _selectedRadius) {
        mosques = await DatabaseHelper.instance.getMosquesNearby(
          loc.latitude, loc.longitude, nextRadius.toDouble(),
        );
      }
    }

    setState(() {
      _mosques = mosques;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang     = ref.watch(settingsProvider).language;
    final locAsync = ref.watch(locationProvider);
    final loc      = locAsync.valueOrNull;

    final filtered = _searchQuery.isEmpty
        ? _mosques
        : _mosques.where((m) =>
            m.nameBn.contains(_searchQuery) ||
            m.nameEn.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.sky0,
      appBar: AppBar(
        backgroundColor: AppColors.sky1,
        foregroundColor: AppColors.marble,
        elevation: 0,
        title: Text(
          lang == 'bn' ? 'কাছের মসজিদ' : 'Nearby Mosques',
          style: const TextStyle(fontFamily: 'NotoSansBengali', color: AppColors.marble),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            color: AppColors.sky1,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.marble),
                    decoration: InputDecoration(
                      hintText: lang == 'bn' ? 'মসজিদ খুঁজুন...' : 'Search mosques...',
                      hintStyle: const TextStyle(color: AppColors.sandMid),
                      prefixIcon: const Icon(Icons.search, color: AppColors.sandMid),
                      filled: true,
                      fillColor: AppColors.sky2,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.goldBd),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.goldBd),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.goldWarm, width: 1.5),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                // Radius chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: AppConfig.mosqueSearchRadii.map((r) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          '$r km',
                          style: TextStyle(
                            fontFamily: 'NotoSansBengali',
                            color: _selectedRadius == r ? AppColors.sky0 : AppColors.sand,
                            fontSize: 12,
                          ),
                        ),
                        selected: _selectedRadius == r,
                        selectedColor: AppColors.dome,
                        backgroundColor: AppColors.sky3,
                        side: const BorderSide(color: AppColors.goldBd),
                        checkmarkColor: AppColors.goldWarm,
                        onSelected: (_) {
                          setState(() => _selectedRadius = r);
                          _loadMosques();
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: loc == null
          ? Center(
              child: Text(
                lang == 'bn' ? 'অবস্থান পাওয়া যাচ্ছে না' : 'Location unavailable',
                style: const TextStyle(color: AppColors.sandMid),
              ),
            )
          : Column(
              children: [
                // Map
                SizedBox(
                  height: 220,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(loc.latitude, loc.longitude),
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(urlTemplate: AppConfig.osmTileUrl),
                      MarkerLayer(markers: [
                        Marker(
                          point: LatLng(loc.latitude, loc.longitude),
                          child: const Icon(Icons.my_location, color: AppColors.goldWarm, size: 28),
                        ),
                        ...filtered.map((m) => Marker(
                          point: LatLng(m.latitude, m.longitude),
                          child: GestureDetector(
                            onTap: () => setState(() => _selected = m),
                            child: Icon(
                              Icons.location_on,
                              color: _selected?.id == m.id
                                  ? AppColors.goldWarm
                                  : m.pinColor,
                              size: 30,
                            ),
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),

                const Divider(height: 1, color: AppColors.goldBd),

                // Mosque list
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.goldWarm),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                lang == 'bn' ? 'আশেপাশে কোনো মসজিদ পাওয়া যায়নি' : 'No mosques found nearby',
                                style: const TextStyle(
                                  fontFamily: 'NotoSansBengali',
                                  color: AppColors.sandMid,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => MosqueListItem(
                                mosque:     filtered[i],
                                lang:       lang,
                                isSelected: _selected?.id == filtered[i].id,
                                onTap:      () => setState(() => _selected = filtered[i]),
                              ),
                            ),
                ),
              ],
            ),
    );
  }
}
