import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/preferences_helper.dart';
import '../../data/models/location_model.dart';
import '../../domain/services/location_service.dart';

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<LocationModel>>((ref) {
  return LocationNotifier()..init();
});

class LocationNotifier extends StateNotifier<AsyncValue<LocationModel>> {
  LocationNotifier() : super(const AsyncValue.loading());

  Future<void> init() async {
    // 1. Show cached location immediately for fast first render
    final cached = await PreferencesHelper.instance.loadLocation();
    if (cached != null) {
      state = AsyncValue.data(cached);
    }

    // 2. Refresh from GPS in background (unless cache is fresh)
    if (cached == null || cached.isStale) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final loc = await LocationService.instance.getLocation();
      state = AsyncValue.data(loc);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setManualLocation(LocationModel location) {
    state = AsyncValue.data(location);
    PreferencesHelper.instance.saveLocation(location);
  }
}
