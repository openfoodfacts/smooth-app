import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';

/// Helper used to set/unset/sort stores as user favorites.
class FavoriteLocationHelper {
  factory FavoriteLocationHelper() {
    _instance ??= const FavoriteLocationHelper._();
    return _instance!;
  }

  const FavoriteLocationHelper._();

  static FavoriteLocationHelper? _instance;
  static const String _key = DaoStringList.keyPriceStores;

  /// Sets a store as a favorite store (or not, depending on [isFavorite]).
  Future<void> setFavorite(
    LocalDatabase localDatabase,
    OsmLocation location,
    bool isFavorite,
  ) async {
    final DaoStringList daoStringList = DaoStringList(localDatabase);
    final String locationKey = _locationToString(location);
    await daoStringList.remove(_key, locationKey);
    if (isFavorite) {
      await daoStringList.add(_key, locationKey);
    }
  }

  /// Returns true if a store was flagged as favorite.
  bool isFavorite(
    LocalDatabase localDatabase,
    OsmLocation location,
  ) {
    final DaoStringList daoStringList = DaoStringList(localDatabase);
    final List<String> favorites = daoStringList.getAll(_key);
    return _isFavorite(favorites, location);
  }

  /// Returns true if a store was flagged as favorite, from stored keys.
  bool _isFavorite(List<String> favorites, OsmLocation location) {
    for (final String favorite in favorites) {
      if (favorite == _locationToString(location)) {
        return true;
      }
    }
    return false;
  }

  String _locationToString(OsmLocation location) =>
      '${location.osmType}-${location.osmId}';
}
