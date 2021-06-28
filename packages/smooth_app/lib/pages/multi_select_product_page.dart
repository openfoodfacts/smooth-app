import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/product_copy_helper.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';
import 'package:smooth_app/data_models/pantry.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

/// Page where products can be selected for copy or removal
///
/// The list of products come from
/// a pantry, a shopping list or a product list.
class MultiSelectProductPage extends StatefulWidget {
  const MultiSelectProductPage.pantry({
    required this.barcode,
    required this.pantries,
    this.index,
    this.pantryType,
  }) : productList = null;

  const MultiSelectProductPage.productList({
    required this.barcode,
    this.productList,
  })  : pantries = null,
        pantryType = null,
        index = null;

  /// Initial selected barcode
  final String barcode;

  final List<Pantry> pantries;
  final int index;
  final PantryType pantryType;
  Pantry get pantry => pantries == null ? null : pantries[index];

  final ProductList productList;

  @override
  _MultiSelectProductPageState createState() => _MultiSelectProductPageState();
}

class _MultiSelectProductPageState extends State<MultiSelectProductPage> {
  final Set<String> _selectedBarcodes = <String>{};
  List<String> _orderedBarcodes; // late final

  @override
  void initState() {
    super.initState();
    _selectedBarcodes.add(widget.barcode);
    if (widget.productList != null) {
      _orderedBarcodes = widget.productList.barcodes;
    } else {
      _orderedBarcodes = widget.pantry.getOrderedBarcodes();
    }
  }

  void _removeBarcode(final String barcode) {
    _orderedBarcodes.remove(barcode);
    if (widget.productList != null) {
      widget.productList.remove(barcode);
    } else {
      widget.pantry.removeBarcode(barcode);
    }
  }

  Product _getProduct(final String barcode) => widget.productList != null
      ? widget.productList.getProduct(barcode)
      : widget.pantry.products[barcode];

  Future<void> _commit(
    final UserPreferences userPreferences,
    final DaoProductList daoProductList,
  ) async =>
      widget.productList != null
          ? await daoProductList.put(widget.productList)
          : await Pantry.putAll(
              userPreferences,
              widget.pantries,
              widget.pantryType,
            );

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ThemeData themeData = Theme.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_selectedBarcodes.length} selected'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => setState(
              () => _selectedBarcodes.length == _orderedBarcodes.length
                  ? _selectedBarcodes.clear()
                  : _selectedBarcodes.addAll(_orderedBarcodes),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              final List<String> barcodes = _getSelectedBarcodes();
              if (barcodes.isEmpty) {
                // nothing selected
                return;
              }
              final List<PantryType> pantryTypes = <PantryType>[
                PantryType.PANTRY,
                PantryType.SHOPPING,
              ];
              final Map<PantryType, List<Pantry>> allPantries =
                  <PantryType, List<Pantry>>{};
              for (final PantryType pantryType in pantryTypes) {
                final List<Pantry> pantries = await Pantry.getAll(
                  userPreferences,
                  daoProduct,
                  pantryType,
                );
                allPantries[pantryType] = pantries;
              }
              final ProductCopyHelper productCopyHelper = ProductCopyHelper();
              final List<Widget> children = await productCopyHelper.getButtons(
                context: context,
                daoProductList: daoProductList,
                daoProduct: daoProduct,
                allPantries: allPantries,
                userPreferences: userPreferences,
                ignoredProductList: widget.productList,
                ignoredPantry: widget.pantry,
              );
              if (children.isEmpty) {
                // no list to add to
                return;
              }
              final dynamic target =
                  await showCupertinoModalBottomSheet<dynamic>(
                context: context,
                builder: (final BuildContext context) => Column(
                  children: <Widget>[
                    const Text('Select the destination:'),
                    Wrap(
                      direction: Axis.horizontal,
                      children: children,
                      spacing: 8.0,
                    ),
                  ],
                ),
              );
              if (target == null) {
                // nothing selected
                return;
              }
              final List<Product> products = <Product>[];
              for (final String barcode in barcodes) {
                products.add(_getProduct(barcode));
              }
              productCopyHelper.copy(
                context: context,
                target: target,
                allPantries: allPantries,
                daoProductList: daoProductList,
                products: products,
                userPreferences: userPreferences,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (_selectedBarcodes.isEmpty) {
                return;
              }
              _selectedBarcodes.forEach(_removeBarcode);
              _commit(userPreferences, daoProductList);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_selectedBarcodes.length} products removed'),
                  duration: const Duration(seconds: 3),
                ),
              );
              setState(() => _selectedBarcodes.clear());
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _orderedBarcodes.length,
        itemBuilder: (BuildContext context, int index) {
          final Product product = _getProduct(_orderedBarcodes[index]);
          final String barcode = product.barcode;
          final bool selected = _selectedBarcodes.contains(barcode);
          return Card(
            color: SmoothTheme.getColor(
              colorScheme,
              Colors.grey,
              ColorDestination.SURFACE_BACKGROUND,
            ),
            child: Container(
              height: screenSize.height / 10,
              child: ListTile(
                onTap: () => setState(
                  () => selected
                      ? _selectedBarcodes.remove(barcode)
                      : _selectedBarcodes.add(barcode),
                ),
                leading: SmoothProductImage(
                  product: product,
                  width: screenSize.height / 10,
                  height: screenSize.height / 10,
                ),
                title: Text(
                  product.productName ??
                      product.productNameEN ??
                      product.productNameFR ??
                      product.productNameDE ??
                      product.barcode,
                  style: themeData.textTheme.headline4,
                ),
                trailing: Icon(
                  _selectedBarcodes.contains(product.barcode)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getSelectedBarcodes() {
    final List<String> result = <String>[];
    if (_selectedBarcodes.isNotEmpty) {
      for (final String barcode in _orderedBarcodes) {
        if (_selectedBarcodes.contains(barcode)) {
          result.add(barcode);
        }
      }
    }
    return result;
  }
}
