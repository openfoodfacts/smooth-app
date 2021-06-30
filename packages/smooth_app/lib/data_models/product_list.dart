import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/data_models/product_extra.dart';

class ProductList {
  ProductList({
    required this.listType,
    required this.parameters,
    this.databaseTimestamp,
    this.databaseCountDistinct,
  });

  static const String _EXTRA_COLOR = 'color';
  static const String _EXTRA_ICON = 'icon';

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

  static const Map<String, String> _DEFAULT_COLOR_TAG_PER_TYPE =
      <String, String>{
    LIST_TYPE_HTTP_SEARCH_KEYWORDS: _COLOR_RED,
    LIST_TYPE_HTTP_SEARCH_CATEGORY: _COLOR_BLUE,
    LIST_TYPE_HTTP_SEARCH_GROUP: _COLOR_ORANGE,
    LIST_TYPE_SCAN: _COLOR_GREEN,
    LIST_TYPE_HISTORY: _COLOR_BLUE,
    LIST_TYPE_USER_DEFINED: _COLOR_PURPLE,
  };

  static const String _ICON_TAG = 'tag';
  static const String _ICON_HEART = 'heart';
  static const String _ICON_SEARCH = 'search';
  static const String _ICON_CATEGORY = 'category';
  static const String _ICON_GROUP = 'group';
  static const String _ICON_SCAN = 'scan';
  static const String _ICON_HISTORY = 'history';

  static const Map<String, List<String>> _ORDERED_ICONS_PER_TYPE =
      <String, List<String>>{
    LIST_TYPE_HTTP_SEARCH_KEYWORDS: <String>[_ICON_SEARCH],
    LIST_TYPE_HTTP_SEARCH_CATEGORY: <String>[_ICON_CATEGORY],
    LIST_TYPE_HTTP_SEARCH_GROUP: <String>[_ICON_GROUP],
    LIST_TYPE_SCAN: <String>[_ICON_SCAN],
    LIST_TYPE_HISTORY: <String>[_ICON_HISTORY],
    LIST_TYPE_USER_DEFINED: <String>[_ICON_TAG, _ICON_HEART]
  };

  static const Map<String, IconData> _ICON_DATA = <String, IconData>{
    _ICON_TAG: CupertinoIcons.tag_fill,
    _ICON_HEART: CupertinoIcons.heart_fill,
    _ICON_SEARCH: Icons.search,
    _ICON_CATEGORY: Icons.description,
    _ICON_GROUP: Icons.fastfood,
    _ICON_SCAN: CupertinoIcons.barcode,
    _ICON_HISTORY: Icons.history,
  };

  static const Map<String, String> _DEFAULT_ICON_TAG_PER_TYPE =
      <String, String>{
    LIST_TYPE_HTTP_SEARCH_KEYWORDS: _ICON_SEARCH,
    LIST_TYPE_HTTP_SEARCH_CATEGORY: _ICON_CATEGORY,
    LIST_TYPE_HTTP_SEARCH_GROUP: _ICON_GROUP,
    LIST_TYPE_SCAN: _ICON_SCAN,
    LIST_TYPE_HISTORY: _ICON_HISTORY,
    LIST_TYPE_USER_DEFINED: _ICON_TAG,
  };

  final String listType;
  final String parameters;
  final int? databaseTimestamp;
  final int? databaseCountDistinct;
  Map<String, String>? extraTags;

  final List<String> _barcodes = <String>[];
  final Map<String, Product> _products = <String, Product>{};
  final Map<String, ProductExtra> _productExtras = <String, ProductExtra>{};

  static const String LIST_TYPE_HTTP_SEARCH_GROUP = 'http/search/group';
  static const String LIST_TYPE_HTTP_SEARCH_KEYWORDS = 'http/search/keywords';
  static const String LIST_TYPE_HTTP_SEARCH_CATEGORY = 'http/search/category';
  static const String LIST_TYPE_SCAN = 'scan';
  static const String LIST_TYPE_HISTORY = 'history';
  static const String LIST_TYPE_USER_DEFINED = 'user';

  List<String> get barcodes => _barcodes;
  Map<String, ProductExtra> get productExtras => _productExtras;

  set colorTag(final String tag) => _setExtra(_EXTRA_COLOR, tag);
  set iconTag(final String tag) => _setExtra(_EXTRA_ICON, tag);

  void _setExtra(final String key, final String value) {
    extraTags ??= <String, String>{};
    extraTags![key] = value;
  }

  String get _colorTag =>
      (extraTags == null ? null : extraTags![_EXTRA_COLOR]) ??
      _DEFAULT_COLOR_TAG_PER_TYPE[listType]!;
  String get _iconTag =>
      (extraTags == null ? null : extraTags![_EXTRA_ICON]) ??
      _DEFAULT_ICON_TAG_PER_TYPE[listType]!;

  List<String> getPossibleIcons() => _ORDERED_ICONS_PER_TYPE[listType]!;

  bool isEmpty() => _barcodes.isEmpty;

  Product getProduct(final String barcode) => _products[barcode]!;

  bool isSameAs(final ProductList other) =>
      listType == other.listType && parameters == other.parameters;

  IconData get iconData => _ICON_DATA[_iconTag] ?? _ICON_DATA[_ICON_TAG]!;

  static Widget getReferenceIcon({
    required final ColorScheme colorScheme,
    required final String colorTag,
    required final String iconTag,
    required final ColorDestination colorDestination,
  }) =>
      getTintedIcon(
        colorScheme: colorScheme,
        materialColor: _getReferenceMaterialColor(colorTag),
        iconData: _ICON_DATA[iconTag] ?? _ICON_DATA[_ICON_TAG]!,
        colorDestination: colorDestination,
      );

  static Widget getTintedIcon({
    required final ColorScheme colorScheme,
    required final MaterialColor materialColor,
    required final IconData iconData,
    final ColorDestination? colorDestination,
  }) =>
      Icon(
        iconData,
        color: colorDestination == null
            ? null
            : SmoothTheme.getColor(
                colorScheme, materialColor, colorDestination),
      );

  static MaterialColor _getReferenceMaterialColor(final String colorTag) =>
      _COLORS[colorTag] ?? _COLORS[_COLOR_RED]!;

  Widget getIcon(
    final ColorScheme colorScheme,
    final ColorDestination colorDestination,
  ) =>
      getReferenceIcon(
        colorScheme: colorScheme,
        colorTag: _colorTag,
        iconTag: _iconTag,
        colorDestination: colorDestination,
      );

  MaterialColor getMaterialColor() => _getReferenceMaterialColor(_colorTag);

  void refresh(final Product? product) {
    if (product == null) {
      throw Exception('null product');
    }
    final String? barcode = product.barcode;
    if (barcode == null) {
      throw Exception('null barcode');
    }
    _products[barcode] = product;
  }

  /// Adds a product to the end of a list if not there already, or does nothing
  ///
  /// Returns false if already in the list
  /// Don't forget to update the database afterwards
  bool add(final Product product) {
    refresh(product);
    if (_barcodes.contains(product.barcode!)) {
      return false;
    }
    _barcodes.add(product.barcode!);
    int index = 1; // default value
    // looking for the highest index so far
    for (final String barcode in _barcodes.reversed) {
      if (barcode == product.barcode) {
        continue;
      }
      final ProductExtra last = _productExtras[barcode]!;
      index = last.intValue;
      break;
    }
    _productExtras[product.barcode!] = _computeProductExtra(index);
    return true;
  }

  /// Removes a barcode from the list
  ///
  /// Returns false if not already in the list
  /// Don't forget to update the database afterwards
  bool remove(final String barcode) {
    if (!_barcodes.contains(barcode)) {
      return false;
    }
    _barcodes.remove(barcode);
    _products.remove(barcode);
    _productExtras.remove(barcode);
    return true;
  }

  /// Sets all products with the same order as the input list
  void setAll(final List<Product> products) {
    int i = 0;
    final List<String> barcodes = <String>[];
    final Map<String, Product> productMap = <String, Product>{};
    final Map<String, ProductExtra> productExtras = <String, ProductExtra>{};
    for (final Product product in products) {
      final String barcode = product.barcode!;
      barcodes.add(barcode);
      productMap[barcode] = product;
      productExtras[barcode] = _computeProductExtra(i++);
    }
    set(barcodes, productMap, productExtras);
  }

  void set(
    final List<String> barcodes,
    final Map<String, Product> products,
    final Map<String, ProductExtra>? productExtras,
  ) {
    _barcodes.clear();
    _products.clear();
    _barcodes.addAll(barcodes);
    _products.addAll(products);
    _productExtras.clear();
    if (productExtras != null) {
      _productExtras.addAll(productExtras);
    }
  }

  ProductExtra _computeProductExtra(final int index) => ProductExtra(index, '');

  void reorder(final int oldIndex, int newIndex) {
    final List<String> order = _barcodes;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = order.removeAt(oldIndex);
    order.insert(newIndex, item);

    int i = 0;
    final Map<String, ProductExtra> productExtras = <String, ProductExtra>{};
    for (final String barcode in order) {
      productExtras[barcode] = _computeProductExtra(i++);
    }
    _productExtras.addAll(productExtras);
  }

  List<Product> getList() {
    final List<Product> result = <Product>[];
    for (final String barcode in _barcodes) {
      final Product? product = _products[barcode];
      if (product == null) {
        throw Exception('no product for barcode $barcode');
      }
      result.add(product);
    }
    return result;
  }
}
