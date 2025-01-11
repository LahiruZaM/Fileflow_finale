import 'package:fileflow/model/persistence/favorite_device.dart';
import 'package:fileflow/provider/persistence_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// This provider stores the list of favorite devices.
/// It automatically saves the list to the device's storage.
final favoritesProvider = ReduxProvider<FavoritesService, List<FavoriteDevice>>((ref) {
  return FavoritesService(ref.read(persistenceProvider));
});

class FavoritesService extends ReduxNotifier<List<FavoriteDevice>> {
  final PersistenceService _persistence;

  FavoritesService(this._persistence);

  @override
  List<FavoriteDevice> init() => _persistence.getFavorites();
}

/// Action to add a device to the list of favorites.
class AddFavoriteAction extends AsyncReduxAction<FavoritesService, List<FavoriteDevice>> {
  final FavoriteDevice device;

  AddFavoriteAction(this.device);

  @override
  Future<List<FavoriteDevice>> reduce() async {
    final updated = List<FavoriteDevice>.unmodifiable([
      ...state,
      device,
    ]);
    await notifier._persistence.setFavorites(updated);
    return updated;
  }
}

/// Action to update an existing favorite device in the list.
class UpdateFavoriteAction extends AsyncReduxAction<FavoritesService, List<FavoriteDevice>> {
  final FavoriteDevice device;

  UpdateFavoriteAction(this.device);

  @override
  Future<List<FavoriteDevice>> reduce() async {
    final index = state.indexWhere((e) => e.id == device.id);
    if (index == -1) {
      // Unknown device
      await Future.microtask(() {});
      return state;
    }
    final updated = List<FavoriteDevice>.unmodifiable(<FavoriteDevice>[
      ...state,
    ]..replaceRange(index, index + 1, [device]));
    await notifier._persistence.setFavorites(updated);
    return updated;
  }
}

/// Action to remove a device from the favorites list.
class RemoveFavoriteAction extends AsyncReduxAction<FavoritesService, List<FavoriteDevice>> {
  final String deviceFingerprint;

  RemoveFavoriteAction({
    required this.deviceFingerprint,
  });

  @override
  Future<List<FavoriteDevice>> reduce() async {
    final index = state.indexWhere((e) => e.fingerprint == deviceFingerprint);
    if (index == -1) {
      // Unknown device
      return state;
    }
    final updated = List<FavoriteDevice>.unmodifiable(<FavoriteDevice>[
      ...state,
    ]..removeAt(index));
    await notifier._persistence.setFavorites(updated);
    return updated;
  }
}
