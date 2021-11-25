import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_extra.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/common/product_list_item.dart';
import 'package:smooth_app/helpers/time_helper.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget(
    this.productList, {
    Key? key,
    this.reorderable = false,
    this.timestamps = false,
    this.dismissible = false,
  }) : super(key: key);
  final ProductList productList;
  final bool timestamps;
  final bool reorderable;
  final bool dismissible;
  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final List<_Meta> metas = <_Meta>[];
    final List<Product> products = widget.productList.getList();
    final Map<String, ProductExtra> productExtras =
        widget.productList.productExtras;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (widget.timestamps) {
      final int nowInMillis = LocalDatabase.nowInMillis();
      const int DAY_IN_MILLIS = 24 * 3600 * 1000;
      String? daysAgoLabel;
      for (final Product product in products) {
        final int timestamp = productExtras[product.barcode]!.intValue;
        final int daysAgo = ((nowInMillis - timestamp) / DAY_IN_MILLIS).round();
        final String tmpDaysAgoLabel = getDaysAgoLabel(context, daysAgo);
        if (daysAgoLabel != tmpDaysAgoLabel) {
          daysAgoLabel = tmpDaysAgoLabel;
          metas.add(_Meta.daysAgoLabel(daysAgoLabel));
        }
        metas.add(_Meta.product(product));
      }
    } else {
      for (final Product product in products) {
        metas.add(_Meta.product(product));
      }
    }
    return ReorderableListView.builder(
      onReorder: (final int oldIndex, final int newIndex) async {
        widget.productList.reorder(oldIndex, newIndex);
        daoProductList
            .put(widget.productList); // careful: if "await", flickering
        setState(() {});
      },
      buildDefaultDragHandles: false,
      itemCount: metas.length,
      itemBuilder: (BuildContext context, int index) {
        final _Meta meta = metas[index];
        if (!meta.isProduct()) {
          return ListTile(
            key: Key(meta.daysAgoLabel!),
            leading: const Icon(Icons.history),
            title: Text(meta.daysAgoLabel!),
          );
        }
        final Product product = meta.product!;
        final Widget child = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: ProductListItem(
            product: product,
            productList: widget.productList,
            listRefresher: () => setState(() {}),
            daoProductList: daoProductList,
            reorderIndex: widget.reorderable ? index : null,
          ),
        );
        if (widget.dismissible) {
          return Dismissible(
            background: Container(color: colorScheme.background),
            key: Key(product.barcode!),
            onDismissed: (final DismissDirection direction) async {
              final bool removed = widget.productList.remove(product.barcode!);
              if (removed) {
                await daoProductList.put(widget.productList);
                setState(() => metas.removeAt(index));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      removed ? 'Product removed' : 'Could not remove product'),
                  duration: const Duration(seconds: 3),
                ),
              );
              // TODO(monsieurtanuki): add a snackbar ("put back the food")
            },
            child: child,
          );
        }
        return Container(
          key: Key(product.barcode!),
          child: child,
        );
      },
    );
  }
}

class _Meta {
  _Meta.product(this.product) : daysAgoLabel = null;
  _Meta.daysAgoLabel(this.daysAgoLabel) : product = null;

  final Product? product;
  final String? daysAgoLabel;

  bool isProduct() => product != null;
}
