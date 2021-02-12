import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/data_models/product_list.dart';

/// A pantry, with a name, a color, an icon,
/// and a list of barcodes with quantity and dates
/// It's stored in the SharedPreferences
/// The barcodes' Products are loaded from the local database
class Pantry {
  Pantry({
    @required this.name,
    this.data = const <String, Map<String, int>>{},
    this.products = const <String, Product>{},
    this.iconTag = _ICON_PAW,
    this.colorTag = _COLOR_DEFAULT,
  });

  String name;
  String colorTag;
  String iconTag;
  final Map<String, Map<String, int>> data;
  final Map<String, Product> products;

  static const String _ICON_DEFAULT = _ICON_PAW;
  static const String _COLOR_DEFAULT = _COLOR_BLUE;

  MaterialColor get materialColor =>
      _COLORS[colorTag] ?? _COLORS[_COLOR_DEFAULT];
  IconData get iconData => _ICON_DATA[iconTag] ?? _ICON_DATA[_ICON_DEFAULT];

  void add(final List<String> barcodes, final Map<String, Product> products) {
    for (final String barcode in barcodes) {
      if (!data.containsKey(barcode)) {
        data[barcode] = <String, int>{};
      }
    }
    this.products.addAll(products);
  }

  static const String _ICON_PAW = 'paw';
  static const String _ICON_FREEZER = 'heart';
  static const String _ICON_HOME = 'home';

  static const List<String> _ORDERED_ICONS = <String>[
    _ICON_PAW,
    _ICON_FREEZER,
    _ICON_HOME,
  ];

  static const Map<String, IconData> _ICON_DATA = <String, IconData>{
    _ICON_PAW: Icons.pets,
    _ICON_FREEZER: Icons.ac_unit,
    _ICON_HOME: Icons.home,
  };

  static const String _COLOR_RED = 'red';
  static const String _COLOR_ORANGE = 'orange';
  static const String _COLOR_GREEN = 'green';
  static const String _COLOR_BLUE = 'blue';
  static const String _COLOR_PURPLE = 'purple';

  static const Map<String, MaterialColor> _COLORS = <String, MaterialColor>{
    _COLOR_RED: Colors.red,
    _COLOR_ORANGE: Colors.orange,
    _COLOR_GREEN: Colors.green,
    _COLOR_BLUE: Colors.blue,
    _COLOR_PURPLE: Colors.purple,
  };

  static const List<String> ORDERED_COLORS = <String>[
    _COLOR_RED,
    _COLOR_ORANGE,
    _COLOR_GREEN,
    _COLOR_BLUE,
    _COLOR_PURPLE,
  ];

  List<String> getPossibleIcons() => _ORDERED_ICONS;

  static Widget getReferenceIcon({
    final ColorScheme colorScheme,
    final String colorTag,
    final String iconTag,
  }) =>
      ProductList.getTintedIcon(
        colorScheme: colorScheme,
        materialColor: _COLORS[colorTag],
        iconData: _ICON_DATA[iconTag] ?? _ICON_DATA[_ICON_DEFAULT],
      );

  Widget getIcon(final ColorScheme colorScheme) => ProductList.getTintedIcon(
        colorScheme: colorScheme,
        materialColor: materialColor,
        iconData: iconData,
      );

  List<Product> getFirstProducts(final int nbInPreview) {
    final List<Product> result = <Product>[];
    for (final Product product in products.values) {
      result.add(product);
      if (result.length >= nbInPreview) {
        break;
      }
    }
    return result;
  }

  int increaseItem(
    final String barcode,
    final String date,
    final int increment,
  ) {
    final int previous = data[barcode][date];
    if (previous == null) {
      data[barcode][date] = increment;
    } else {
      data[barcode][date] = previous + increment;
    }
    if (data[barcode][date] <= 0) {
      data[barcode].remove(date);
    }
    return data[barcode][date];
  }

  void removeBarcode(final String barcode) {
    data.remove(barcode);
    products.remove(barcode);
  }

  void clear() {
    data.clear();
    products.clear();
  }

  static Future<void> putAll(
    final UserPreferences userPreferences,
    final List<Pantry> pantries,
  ) async {
    final List<String> encodedJsons = <String>[];
    for (final Pantry pantry in pantries) {
      encodedJsons.add(_put(pantry));
    }
    await userPreferences.setPantryRepository(encodedJsons);
  }

  static Future<List<Pantry>> getAll(
    final UserPreferences userPreferences,
    final DaoProduct daoProduct,
  ) async {
    final List<Pantry> result = <Pantry>[];
    final List<String> pantryJsons = userPreferences.getPantryRepository();
    for (final String pantryJson in pantryJsons) {
      result.add(await _get(pantryJson, daoProduct));
    }
    return result;
  }

  static const String _JSON_TAG_NAME = 'name';
  static const String _JSON_TAG_COLOR = 'color';
  static const String _JSON_TAG_ICON = 'icon';
  static const String _JSON_TAG_PRODUCTS = 'products';

  static Future<Pantry> _get(
    final String encodedJson,
    final DaoProduct daoProduct,
  ) async {
    final Map<String, dynamic> decodedJsonAll =
        json.decode(encodedJson) as Map<String, dynamic>;
    final String name = decodedJsonAll[_JSON_TAG_NAME] as String;
    final String colorTag = decodedJsonAll[_JSON_TAG_COLOR] as String;
    final String iconTag = decodedJsonAll[_JSON_TAG_ICON] as String;
    final Map<String, dynamic> decodedJson =
        decodedJsonAll[_JSON_TAG_PRODUCTS] as Map<String, dynamic>;
    final List<String> barcodes = decodedJson.keys.toList();
    final Map<String, Product> products = await daoProduct.getAll(barcodes);
    final Map<String, Map<String, int>> data = <String, Map<String, int>>{};
    for (final String barcode in barcodes) {
      final dynamic rawDataForBarcode = decodedJson[barcode];
      if (rawDataForBarcode is! Map) {
        // not expected
        continue;
      }
      final Map<String, int> dataForBarcode = <String, int>{};
      final Map<String, dynamic> rawMap =
          rawDataForBarcode as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in rawMap.entries) {
        dataForBarcode[entry.key] = entry.value as int;
      }
      data[barcode] = dataForBarcode;
    }
    return Pantry(
      data: data,
      products: products,
      name: name,
      colorTag: colorTag,
      iconTag: iconTag,
    );
  }

  static String _put(final Pantry pantry) {
    final Map<String, dynamic> result = <String, dynamic>{};
    result[_JSON_TAG_NAME] = pantry.name;
    result[_JSON_TAG_COLOR] = pantry.colorTag;
    result[_JSON_TAG_ICON] = pantry.iconTag;
    result[_JSON_TAG_PRODUCTS] = pantry.data;
    final String encodedJson = json.encode(result);
    return encodedJson;
  }

  @override
  String toString() => 'Pantry(name: $name, data: $data)';
}
