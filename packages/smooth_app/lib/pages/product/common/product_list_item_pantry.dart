import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/data_models/product_extra.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product/common/product_list_item_simple.dart';

/// Widget for a [ProductList] item (pantry)
class ProductListItemPantry extends StatelessWidget {
  ProductListItemPantry({
    required this.product,
    required this.productList,
    required this.listRefresher,
    required this.daoProductList,
    required this.reorderIndex,
  })  : _productExtra = productList.getProductExtra(product.barcode!),
        _counts = _getCounts(productList.getProductExtra(product.barcode!));
  // TODO(monsieurtanuki): do it with more elegance, but without a StatefulWidget

  static const String _EMPTY_DATE = '';
  static const TextStyle _DATE_TEXT_STYLE = TextStyle(fontSize: 16);

  final Product product;
  final ProductList productList;
  final VoidCallback listRefresher;
  final DaoProductList daoProductList;
  final int reorderIndex;

  final ProductExtra _productExtra;
  final Map<String, int> _counts;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    children.add(
      ProductListItemSimple(
        product: product,
        productList: productList,
        listRefresher: listRefresher,
        daoProductList: daoProductList,
        reorderIndex: reorderIndex,
      ),
    );
    children.add(
      const Divider(color: Colors.red),
    );
    _addLines(
      children: children,
      textStyle: _DATE_TEXT_STYLE,
      colorScheme: Theme.of(context).colorScheme,
      context: context,
    );
    return Column(children: children);
  }

  Widget _getDayLine({
    required final String day,
    required final String now,
    required final TextStyle textStyle,
    required final BuildContext context,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: () async => _add(day, -1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('${_counts[day]}', style: textStyle),
              IconButton(
                onPressed: () async => _add(day, 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Text(
            day != _EMPTY_DATE ? day : AppLocalizations.of(context)!.no_date,
            style: textStyle,
          ),
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                day == _EMPTY_DATE ? '' : '(${_getDayDifference(now, day)}d)',
                style: textStyle,
              ),
            ),
          ),
        ],
      );

  void _addLines({
    required final List<Widget> children,
    required final TextStyle textStyle,
    required final ColorScheme colorScheme,
    required final BuildContext context,
  }) {
    final String now = DateTime.now().toIso8601String();
    final List<String> sortedDays = <String>[..._counts.keys];
    sortedDays.sort();
    final bool alreadyHasNoDate = sortedDays.contains(_EMPTY_DATE);
    for (final String day in sortedDays) {
      children.add(
        _getDayLine(
          day: day,
          now: now,
          textStyle: textStyle,
          context: context,
        ),
      );
    }
    final Widget dateButton = ElevatedButton(
      onPressed: () async {
        final DateTime? dateTime = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2026),
          builder: (BuildContext context, Widget? child) => child!,
        );
        if (dateTime == null) {
          return;
        }
        final String date = dateTime.toIso8601String().substring(0, 10);
        await _add(date, 1);
      },
      child: Text(AppLocalizations.of(context)!.add_date, style: textStyle),
    );
    final Widget noDateButton = ElevatedButton(
      onPressed: () async => _add(_EMPTY_DATE, 1),
      child: Text(AppLocalizations.of(context)!.no_date, style: textStyle),
    );
    children.add(
      ListTile(
        title: alreadyHasNoDate
            ? dateButton
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  dateButton,
                  noDateButton,
                ],
              ),
      ),
    );
  }

  /// Returns the count of the product from the [ProductExtra] string value
  ///
  /// Very strategic method
  static Map<String, int> _getCounts(final ProductExtra productExtra) =>
      (jsonDecode(productExtra.stringValue ==
                  ProductList.PRODUCT_EXTRA_INIT_STRING_VALUE
              ? _PRODUCT_EXTRA_INIT_STRING_VALUE
              : productExtra.stringValue) as Map<String, dynamic>)
          .map((final String key, final dynamic value) =>
              MapEntry<String, int>(key, value as int));

  /// Actual default value for pantries
  ///
  /// Instead of [ProductList.PRODUCT_EXTRA_INIT_STRING_VALUE]
  /// This value means: count[no-date]=1
  static const String _PRODUCT_EXTRA_INIT_STRING_VALUE = '{"$_EMPTY_DATE":1}';

  /// Sets the count of the product to a [productExtra] string value
  ///
  /// Very strategic method
  /// Returns true if not empty
  bool _setCounts() {
    if (_counts.isNotEmpty) {
      _productExtra.stringValue = json.encode(_counts);
      return true;
    }
    return false;
  }

  Future<void> _add(
    final String day,
    final int increment,
  ) async {
    _counts[day] = (_counts[day] ?? 0) + increment;
    if (_counts[day]! <= 0) {
      _counts.remove(day);
    }
    if (_setCounts()) {
      productList.setProductExtra(product.barcode!, _productExtra);
    } else {
      productList.remove(product.barcode!);
    }
    await daoProductList.put(
        productList); // TODO(monsieurtanuki): save just the extra, not the whole product list
    listRefresher();
  }

  static int _getDayDifference(final String reference, final String value) {
    final DateTime referenceDateTime = DateTime.parse(reference);
    final DateTime valueDateTime = DateTime.parse(value);
    final Duration difference = valueDateTime.difference(referenceDateTime);
    return (difference.inHours / 24).ceil();
  }
}
