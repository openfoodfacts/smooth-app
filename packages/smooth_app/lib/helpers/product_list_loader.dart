import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';

class ProductListLoader extends StatefulWidget {
  const ProductListLoader({
    required this.list,
    required this.onError,
    required this.onLoaded,
    required this.onLoading,
    super.key,
    this.limit,
  });

  final ProductList list;
  final int? limit;

  final Function(BuildContext context) onLoading;
  final Function(BuildContext context, Iterable<Product> products) onLoaded;
  final Function(BuildContext context, Object error) onError;

  @override
  State<ProductListLoader> createState() => _ProductListLoaderState();
}

class _ProductListLoaderState extends State<ProductListLoader> {
  late DaoProductList _daoProductList;
  late DaoProduct _daoProduct;

  _ProductListState? _state = _ProductListLoadingState();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final LocalDatabase database = context.watch<LocalDatabase>();
    _daoProduct = DaoProduct(database);
    _daoProductList = DaoProductList(database);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (_state is _ProductListLoadedState) {
      return widget.onLoaded(
        context,
        (_state! as _ProductListLoadedState).products,
      );
    } else if (_state is _ProductListErrorState) {
      final Object error = (_state! as _ProductListErrorState).error;
      return widget.onError(context, error);
    }

    return widget.onLoading(context);
  }

  Future<void> _loadProducts() async {
    try {
      /// Load barcodes
      await _daoProductList.get(widget.list);

      Iterable<String> barcodes = widget.list.getList();
      if (widget.limit != null) {
        barcodes = barcodes.take(widget.limit!);
      }

      final Map<String, Product> res = await _daoProduct.getAll(barcodes);
      final List<Product> products = <Product>[];

      for (final String barcode in barcodes) {
        final Product? product = res[barcode];

        if (product != null) {
          products.add(product);
        }
      }

      setState(() {
        _state = _ProductListLoadedState(products);
      });
    } catch (e) {
      setState(() => _state = _ProductListErrorState(e));
    }
  }
}

sealed class _ProductListState {}

class _ProductListLoadingState extends _ProductListState {}

class _ProductListLoadedState extends _ProductListState {
  _ProductListLoadedState(this.products);

  final Iterable<Product> products;
}

class _ProductListErrorState extends _ProductListState {
  _ProductListErrorState(this.error);

  final Object error;
}
