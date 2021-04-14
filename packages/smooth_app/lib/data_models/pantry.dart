// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

enum PantryType {
  PANTRY,
  SHOPPING,
}

/// A pantry, with a name, a color, an icon,
/// and a list of barcodes with quantity and dates
/// It's stored in the SharedPreferences
/// The barcodes' Products are loaded from the local database
class Pantry {
  Pantry({
    @required this.name,
    @required this.pantryType,
    @required this.order,
    this.data = const <String, Map<String, int>>{},
    this.products = const <String, Product>{},
    this.iconTag = '',
    this.colorTag = _COLOR_DEFAULT,
  });

  String name;
  String colorTag;
  String iconTag;
  final PantryType pantryType;

  /// Pantry data for each barcode
  final Map<String, Map<String, int>> data;

  /// Product for each barcode
  final Map<String, Product> products;

  /// Order of the barcodes
  final List<String> order;

  static const String _ICON_DEFAULT_PANTRY = _ICON_PAW;
  static const String _ICON_DEFAULT_SHOPPING = _ICON_CART;
  static const String _COLOR_DEFAULT = _COLOR_BLUE;

  MaterialColor get materialColor =>
      _COLORS[colorTag] ?? _COLORS[_COLOR_DEFAULT];
  IconData get iconData => _ICON_DATA[iconTag] ?? _ICON_DATA[_defaultIconTag];

  String get _defaultIconTag => pantryType == PantryType.PANTRY
      ? _ICON_DEFAULT_PANTRY
      : _ICON_DEFAULT_SHOPPING;

  /// Returns the number of actually added barcodes (new barcodes, then)
  int addAll(final List<String> barcodes, final Map<String, Product> products) {
    int result = 0;
    for (final String barcode in barcodes) {
      if (!data.containsKey(barcode)) {
        data[barcode] = <String, int>{};
        order.add(barcode);
        result++;
      }
    }
    this.products.addAll(products);
    return result;
  }

  /// Returns true if the product was actually added (= was not there before)
  bool add(final Product product) =>
      addAll(
        <String>[product.barcode],
        <String, Product>{
          product.barcode: product,
        },
      ) ==
      1;

  static const String _ICON_PAW = 'paw';
  static const String _ICON_FREEZER = 'heart';
  static const String _ICON_HOME = 'home';
  static const String _ICON_CART = 'cart';
  static const String _ICON_TREE = 'tree';
  static const String _ICON_SPARKLES = 'sparkles';

  static const List<String> _ORDERED_ICONS_PANTRY = <String>[
    _ICON_PAW,
    _ICON_FREEZER,
    _ICON_HOME,
  ];

  static const List<String> _ORDERED_ICONS_SHOPPING = <String>[
    _ICON_CART,
    _ICON_TREE,
    _ICON_SPARKLES,
  ];

  static const Map<String, IconData> _ICON_DATA = <String, IconData>{
    _ICON_PAW: Icons.pets,
    _ICON_FREEZER: Icons.ac_unit,
    _ICON_HOME: Icons.home,
    _ICON_CART: Icons.shopping_cart,
    _ICON_TREE: CupertinoIcons.tree,
    _ICON_SPARKLES: CupertinoIcons.sparkles,
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

  List<String> getPossibleIcons() => pantryType == PantryType.PANTRY
      ? _ORDERED_ICONS_PANTRY
      : _ORDERED_ICONS_SHOPPING;

  Widget getReferenceIcon({
    final ColorScheme colorScheme,
    final String colorTag,
    final String iconTag,
    final ColorDestination colorDestination,
  }) =>
      ProductList.getTintedIcon(
        colorScheme: colorScheme,
        materialColor: _COLORS[colorTag],
        iconData: _ICON_DATA[iconTag] ?? _ICON_DATA[_defaultIconTag],
        colorDestination: colorDestination,
      );

  Widget getIcon(
    final ColorScheme colorScheme,
    final ColorDestination colorDestination,
  ) =>
      ProductList.getTintedIcon(
        colorScheme: colorScheme,
        materialColor: materialColor,
        iconData: iconData,
        colorDestination: colorDestination,
      );

  List<Product> getFirstProducts(final int nbInPreview) {
    final List<Product> result = <Product>[];
    final List<String> order =
        getOrderedBarcodes(); // in the old version case only
    for (final String barcode in order) {
      result.add(products[barcode]);
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
      if (pantryType == PantryType.PANTRY) {
        data[barcode].remove(date);
      } else {
        data[barcode][date] = 0;
      }
    }
    return data[barcode][date];
  }

  void removeBarcode(final String barcode) {
    data.remove(barcode);
    order.remove(barcode);
    products.remove(barcode);
  }

  void clear() {
    data.clear();
    order.clear();
    products.clear();
  }

  static Future<void> putAll(
    final UserPreferences userPreferences,
    final List<Pantry> pantries,
    final PantryType pantryType,
  ) async {
    final List<String> encodedJsons = <String>[];
    for (final Pantry pantry in pantries) {
      encodedJsons.add(_put(pantry));
    }
    await userPreferences.setPantryRepository(encodedJsons, pantryType);
  }

  static Future<List<Pantry>> getAll(
    final UserPreferences userPreferences,
    final DaoProduct daoProduct,
    final PantryType pantryType,
  ) async {
    final List<Pantry> result = <Pantry>[];
    final List<String> pantryJsons =
        userPreferences.getPantryRepository(pantryType);
    for (final String pantryJson in pantryJsons) {
      result.add(await _get(pantryJson, daoProduct, pantryType));
    }
    return result;
  }

  static const String _JSON_TAG_NAME = 'name';
  static const String _JSON_TAG_COLOR = 'color';
  static const String _JSON_TAG_ICON = 'icon';
  static const String _JSON_TAG_PRODUCTS = 'products';
  static const String _JSON_TAG_ORDER = 'order';

  static Future<Pantry> _get(
    final String encodedJson,
    final DaoProduct daoProduct,
    final PantryType pantryType,
  ) async {
    final Map<String, dynamic> decodedJsonAll =
        json.decode(encodedJson) as Map<String, dynamic>;
    final String name = decodedJsonAll[_JSON_TAG_NAME] as String;
    final String colorTag = decodedJsonAll[_JSON_TAG_COLOR] as String;
    final String iconTag = decodedJsonAll[_JSON_TAG_ICON] as String;
    final List<String> order = <String>[];
    final List<dynamic> tmpOrder =
        decodedJsonAll[_JSON_TAG_ORDER] as List<dynamic>;
    if (tmpOrder != null) {
      for (final dynamic item in tmpOrder) {
        order.add(item as String);
      }
    }
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
      pantryType: pantryType,
      data: data,
      products: products,
      name: name,
      order: order,
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
    result[_JSON_TAG_ORDER] = pantry.order;
    final String encodedJson = json.encode(result);
    return encodedJson;
  }

  List<String> getOrderedBarcodes() {
    if (order.isEmpty) {
      // fix for old versions
      order.addAll(products.keys);
    }
    return order;
  }

  void reorder(final int oldIndex, int newIndex) {
    final List<String> order = getOrderedBarcodes();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
  }

  @override
  String toString() => 'Pantry(name: $name, data: $data)';
}
