import 'package:smooth_app/database/dao_osm_location.dart';
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
    final LocalDatabase localDatabase,
    final OsmLocation location,
    final bool isFavorite,
  ) async {
    final DaoStringList daoStringList = DaoStringList(localDatabase);
    final String locationKey = _locationToString(location);
    if (!isFavorite) {
      await removeFavorite(localDatabase, locationKey);
      return;
    }
    // Search results can be favorited without first selecting the location.
    await DaoOsmLocation(localDatabase).put(location);
    if (!daoStringList.getAll(_key).contains(locationKey)) {
      await daoStringList.add(_key, locationKey);
    } else {
      localDatabase.notifyListeners();
    }
  }

  /// Returns favorites in saved order, including keys without cached details.
  Future<Map<String, OsmLocation?>> getFavorites(
    final LocalDatabase localDatabase,
  ) async {
    final List<OsmLocation> locations = await DaoOsmLocation(
      localDatabase,
    ).getAll();
    final Map<String, OsmLocation> byKey = <String, OsmLocation>{
      for (final OsmLocation location in locations)
        _locationToString(location): location,
    };
    return <String, OsmLocation?>{
      for (final String key in DaoStringList(localDatabase).getAll(_key))
        key: byKey[key],
    };
  }

  Future<void> removeFavorite(
    final LocalDatabase localDatabase,
    final String locationKey,
  ) async {
    await DaoStringList(localDatabase).remove(_key, locationKey);
  }

  /// Returns true if a store was flagged as favorite.
  bool isFavorite(
    final LocalDatabase localDatabase,
    final OsmLocation location,
  ) {
    final DaoStringList daoStringList = DaoStringList(localDatabase);
    final List<String> favorites = daoStringList.getAll(_key);
    return _isFavorite(favorites, location);
  }

  /// Returns true if a store was flagged as favorite, from stored keys.
  bool _isFavorite(final List<String> favorites, final OsmLocation location) {
    for (final String favorite in favorites) {
      if (favorite == _locationToString(location)) {
        return true;
      }
    }
    return false;
  }

  String _locationToString(final OsmLocation location) =>
      '${location.osmType}-${location.osmId}';
}
