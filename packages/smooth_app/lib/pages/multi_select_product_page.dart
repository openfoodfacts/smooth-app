import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product_copy_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';

/// Page where products can be selected for copy or removal
///
/// The list of products come from
/// a pantry, a shopping list or a product list.
class MultiSelectProductPage extends StatefulWidget {
  const MultiSelectProductPage({
    required this.barcode,
    required this.productList,
    Key? key,
  }) : super(key: key);

  /// Initial selected barcode
  final String barcode;
  final ProductList productList;

  @override
  State<MultiSelectProductPage> createState() => _MultiSelectProductPageState();
}

class _MultiSelectProductPageState extends State<MultiSelectProductPage> {
  final Set<String> _selectedBarcodes = <String>{};
  late List<String> _orderedBarcodes; // late final

  @override
  void initState() {
    super.initState();
    _selectedBarcodes.add(widget.barcode);
    _orderedBarcodes = widget.productList.barcodes;
  }

  void _removeBarcode(final String barcode) {
    _orderedBarcodes.remove(barcode);
    widget.productList.remove(barcode);
  }

  Product _getProduct(final String barcode) =>
      widget.productList.getProduct(barcode);

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
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
              final ProductCopyHelper productCopyHelper = ProductCopyHelper();
              final ProductList? productList =
                  await productCopyHelper.showProductListDialog(
                context: context,
                daoProductList: daoProductList,
                daoProduct: daoProduct,
                ignoredProductList: widget.productList,
              );
              if (productList == null) {
                // nothing selected
                return;
              }
              final List<Product> products = <Product>[];
              for (final String barcode in barcodes) {
                products.add(_getProduct(barcode));
              }
              await productCopyHelper.copy(
                context: context,
                productList: productList,
                daoProductList: daoProductList,
                products: products,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (_selectedBarcodes.isEmpty) {
                return;
              }
              _selectedBarcodes.forEach(_removeBarcode);
              await daoProductList.put(widget.productList);
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
          final String barcode = product.barcode!;
          final bool selected = _selectedBarcodes.contains(barcode);
          return Card(
            color: SmoothTheme.getColor(
              colorScheme,
              Colors.grey,
              ColorDestination.SURFACE_BACKGROUND,
            ),
            child: SizedBox(
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
                  product.productName ?? product.barcode ?? 'unknown',
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
