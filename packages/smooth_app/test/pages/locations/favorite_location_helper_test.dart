import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/pages/locations/favorite_location_helper.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';

import '../../tests_utils/favorite_locations_test_database.dart';

const OsmLocation _store = OsmLocation(
  osmId: 123,
  osmType: LocationOSMType.node,
  longitude: 2.3,
  latitude: 48.8,
  name: 'Local store',
  city: 'Paris',
);

const OsmLocation _otherStore = OsmLocation(
  osmId: 123,
  osmType: LocationOSMType.way,
  longitude: 2.4,
  latitude: 48.9,
  name: 'Other store',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final FavoriteLocationHelper helper = FavoriteLocationHelper();
  late FavoriteLocationsTestStorage storage;

  setUp(() async {
    storage = FavoriteLocationsTestStorage();
    await storage.init();
  });

  tearDown(() => storage.delete());

  test('starts empty and caches details when adding a search result', () async {
    expect(await helper.getFavorites(storage.localDatabase), isEmpty);
    await helper.setFavorite(storage.localDatabase, _store, true);

    expect(helper.isFavorite(storage.localDatabase, _store), isTrue);
    final Map<String, OsmLocation?> favorites = await helper.getFavorites(
      storage.localDatabase,
    );
    expect(favorites.values.single?.name, _store.name);
    expect(favorites.values.single?.city, _store.city);
    expect(
      (await DaoOsmLocation(storage.localDatabase).getAll()).single.osmId,
      _store.osmId,
    );
  });

  test('duplicates keep saved order and OSM types remain distinct', () async {
    await helper.setFavorite(storage.localDatabase, _store, true);
    await helper.setFavorite(storage.localDatabase, _otherStore, true);
    final List<String> keys = (await helper.getFavorites(
      storage.localDatabase,
    )).keys.toList();
    await helper.setFavorite(storage.localDatabase, _store, true);

    expect((await helper.getFavorites(storage.localDatabase)).keys, keys);
    expect(keys, hasLength(2));
    expect(helper.isFavorite(storage.localDatabase, _otherStore), isTrue);
  });

  test('favorites and details survive closing and reopening storage', () async {
    await helper.setFavorite(storage.localDatabase, _store, true);
    await storage.close();
    await storage.open();

    expect(helper.isFavorite(storage.localDatabase, _store), isTrue);
    expect(
      (await helper.getFavorites(storage.localDatabase)).values.single?.name,
      _store.name,
    );

    await helper.setFavorite(storage.localDatabase, _store, false);
    await storage.close();
    await storage.open();
    expect(helper.isFavorite(storage.localDatabase, _store), isFalse);
    expect(await helper.getFavorites(storage.localDatabase), isEmpty);
    expect(await DaoOsmLocation(storage.localDatabase).getAll(), hasLength(1));
  });

  test('legacy keys resolve without rewriting the saved identifiers', () async {
    await DaoOsmLocation(storage.localDatabase).put(_store);
    const String key = 'LocationOSMType.node-123';
    await DaoStringList(
      storage.localDatabase,
    ).add(DaoStringList.keyPriceStores, key);

    final Map<String, OsmLocation?> favorites = await helper.getFavorites(
      storage.localDatabase,
    );
    expect(favorites.keys, <String>[key]);
    expect(favorites[key]?.name, _store.name);
    expect(helper.isFavorite(storage.localDatabase, _store), isTrue);
  });

  test('missing details remain removable and can be restored', () async {
    await helper.setFavorite(storage.localDatabase, _store, true);
    await DaoOsmLocation(storage.localDatabase).delete(_store);
    Map<String, OsmLocation?> favorites = await helper.getFavorites(
      storage.localDatabase,
    );
    expect(favorites, hasLength(1));
    expect(favorites.values.single, isNull);

    await helper.setFavorite(storage.localDatabase, _store, true);
    favorites = await helper.getFavorites(storage.localDatabase);
    expect(favorites.values.single?.name, _store.name);

    await DaoOsmLocation(storage.localDatabase).delete(_store);
    await helper.removeFavorite(storage.localDatabase, favorites.keys.single);
    expect(await helper.getFavorites(storage.localDatabase), isEmpty);
  });

  test('changes notify existing location consumers after saving', () async {
    int notifications = 0;
    storage.localDatabase.addListener(() => notifications++);

    await helper.setFavorite(storage.localDatabase, _store, true);
    expect(notifications, 1);
    await helper.setFavorite(storage.localDatabase, _store, true);
    expect(notifications, 2);
    await helper.setFavorite(storage.localDatabase, _store, false);
    expect(notifications, 3);
  });
}
