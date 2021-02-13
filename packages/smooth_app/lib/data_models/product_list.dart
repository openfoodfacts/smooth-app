import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ProductList {
  ProductList({
    @required this.listType,
    @required this.parameters,
    this.databaseTimestamp,
    this.databaseCount,
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
    LIST_TYPE_HTTP_SEARCH_GROUP: _COLOR_ORANGE,
    LIST_TYPE_SCAN: _COLOR_GREEN,
    LIST_TYPE_HISTORY: _COLOR_BLUE,
    LIST_TYPE_USER_DEFINED: _COLOR_PURPLE,
  };

  static const String _ICON_TAG = 'tag';
  static const String _ICON_HEART = 'heart';
  static const String _ICON_SEARCH = 'search';
  static const String _ICON_GROUP = 'group';
  static const String _ICON_SCAN = 'scan';
  static const String _ICON_HISTORY = 'history';

  static const Map<String, List<String>> _ORDERED_ICONS_PER_TYPE =
      <String, List<String>>{
    LIST_TYPE_HTTP_SEARCH_KEYWORDS: <String>[_ICON_SEARCH],
    LIST_TYPE_HTTP_SEARCH_GROUP: <String>[_ICON_GROUP],
    LIST_TYPE_SCAN: <String>[_ICON_SCAN],
    LIST_TYPE_HISTORY: <String>[_ICON_HISTORY],
    LIST_TYPE_USER_DEFINED: <String>[_ICON_TAG, _ICON_HEART]
  };

  static const Map<String, IconData> _ICON_DATA = <String, IconData>{
    _ICON_TAG: CupertinoIcons.tag_fill,
    _ICON_HEART: CupertinoIcons.heart_fill,
    _ICON_SEARCH: Icons.search,
    _ICON_GROUP: Icons.fastfood,
    _ICON_SCAN: CupertinoIcons.barcode,
    _ICON_HISTORY: Icons.history,
  };

  static const Map<String, String> _DEFAULT_ICON_TAG_PER_TYPE =
      <String, String>{
    LIST_TYPE_HTTP_SEARCH_KEYWORDS: _ICON_SEARCH,
    LIST_TYPE_HTTP_SEARCH_GROUP: _ICON_GROUP,
    LIST_TYPE_SCAN: _ICON_SCAN,
    LIST_TYPE_HISTORY: _ICON_HISTORY,
    LIST_TYPE_USER_DEFINED: _ICON_TAG,
  };

  final String listType;
  final String parameters;
  final int databaseTimestamp;
  final int databaseCount;
  final int databaseCountDistinct;
  Map<String, String> extraTags;

  final List<String> _barcodes = <String>[];
  final Map<String, Product> _products = <String, Product>{};

  static const String LIST_TYPE_HTTP_SEARCH_GROUP = 'http/search/group';
  static const String LIST_TYPE_HTTP_SEARCH_KEYWORDS = 'http/search/keywords';
  static const String LIST_TYPE_SCAN = 'scan';
  static const String LIST_TYPE_HISTORY = 'history';
  static const String LIST_TYPE_USER_DEFINED = 'user';

  List<String> get barcodes => _barcodes;

  set colorTag(final String tag) => _setExtra(_EXTRA_COLOR, tag);
  set iconTag(final String tag) => _setExtra(_EXTRA_ICON, tag);

  void _setExtra(final String key, final String value) {
    extraTags ??= <String, String>{};
    extraTags[key] = value;
  }

  String get _colorTag =>
      (extraTags == null ? null : extraTags[_EXTRA_COLOR]) ??
      _DEFAULT_COLOR_TAG_PER_TYPE[listType];
  String get _iconTag =>
      (extraTags == null ? null : extraTags[_EXTRA_ICON]) ??
      _DEFAULT_ICON_TAG_PER_TYPE[listType];

  List<String> getPossibleIcons() => _ORDERED_ICONS_PER_TYPE[listType];

  bool isEmpty() => _barcodes.isEmpty;

  void clear() {
    _barcodes.clear();
    _products.clear();
  }

  Product getProduct(final String barcode) => _products[barcode];

  String get lousyKey =>
      '$listType/$parameters'; // TODO(monsieurtanuki): does not work if you change the name

  static Widget getReferenceIcon({
    final ColorScheme colorScheme,
    final String colorTag,
    final String iconTag,
  }) =>
      getTintedIcon(
        colorScheme: colorScheme,
        materialColor: _getReferenceMaterialColor(colorTag),
        iconData: _ICON_DATA[iconTag] ?? _ICON_DATA[_ICON_TAG],
      );

  static Widget getTintedIcon({
    final ColorScheme colorScheme,
    final MaterialColor materialColor,
    final IconData iconData,
  }) =>
      Icon(
        iconData,
        color: SmoothTheme.getForegroundColor(colorScheme, materialColor),
      );

  static MaterialColor _getReferenceMaterialColor(final String colorTag) =>
      _COLORS[colorTag] ?? _COLORS[_COLOR_RED];

  Widget getIcon(final ColorScheme colorScheme) => getReferenceIcon(
        colorScheme: colorScheme,
        colorTag: _colorTag,
        iconTag: _iconTag,
      );

  MaterialColor getMaterialColor() => _getReferenceMaterialColor(_colorTag);

  void add(final Product product) {
    if (product == null) {
      throw Exception('null product');
    }
    final String barcode = product.barcode;
    if (barcode == null) {
      throw Exception('null barcode');
    }
    _barcodes.add(barcode);
    _products[barcode] = product;
  }

  void addAll(final List<Product> products) => products.forEach(add);

  void set(
    final List<String> barcodes,
    final Map<String, Product> products,
  ) {
    clear();
    _barcodes.addAll(barcodes);
    _products.addAll(products);
  }

  List<Product> getList() {
    final List<Product> result = <Product>[];
    for (final String barcode in _barcodes) {
      final Product product = _products[barcode];
      if (product == null) {
        throw Exception('no product for barcode $barcode');
      }
      result.add(product);
    }
    return result;
  }

  List<Product> getUniqueList({final bool ascending = true}) {
    final List<Product> result = <Product>[];
    final Set<String> done = <String>{};
    final Iterable<String> orderedBarcodes =
        ascending ? _barcodes : _barcodes.reversed;
    for (final String barcode in orderedBarcodes) {
      if (done.contains(barcode)) {
        continue;
      }
      done.add(barcode);
      final Product product = _products[barcode];
      if (product == null) {
        throw Exception('no product for barcode $barcode');
      }
      result.add(product);
    }
    return result;
  }
}
