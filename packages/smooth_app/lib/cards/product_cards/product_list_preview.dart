import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product_page.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:smooth_app/pages/product_list_page.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';

class ProductListPreview extends StatelessWidget {
  const ProductListPreview({
    @required this.daoProductList,
    @required this.productList,
    @required this.nbInPreview,
  });

  final DaoProductList daoProductList;
  final ProductList productList;
  final int nbInPreview;

  static const String _TRANSLATE_ME_SEARCHING = 'Searching...';

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Product>>(
        future: daoProductList.getFirstProducts(
          productList,
          nbInPreview,
          true,
          true,
        ),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<Product>> snapshot,
        ) {
          final String title =
              ProductQueryPageHelper.getProductListLabel(productList);
          if (snapshot.connectionState == ConnectionState.done) {
            final List<Product> list = snapshot.data;

            String subtitle;
            final double iconSize = MediaQuery.of(context).size.width / 6;
            if (list == null || list.isEmpty) {
              subtitle = 'Empty list';
            }
            return Card(
              color: SmoothTheme.getBackgroundColor(
                Theme.of(context).colorScheme,
                productList.getMaterialColor(),
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    onTap: () async {
                      await daoProductList.get(productList);
                      await Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => ProductListPage(
                            productList,
                            reverse: ProductQueryPageHelper.isListReversed(
                              productList,
                            ),
                          ),
                        ),
                      );
                    },
                    leading: productList.getIcon(Theme.of(context).colorScheme),
                    trailing: const Icon(Icons.more_horiz),
                    subtitle: subtitle == null ? null : Text(subtitle),
                    title: Text(title,
                        style: Theme.of(context).textTheme.subtitle2),
                  ),
                  _ProductListPreviewHelper(
                    list: list,
                    iconSize: iconSize,
                  ),
                ],
              ),
            );
          }
          return Card(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              subtitle: Text(title),
              title: Text(
                _TRANSLATE_ME_SEARCHING,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          );
        },
      );
}

class _ProductListPreviewHelper extends StatelessWidget {
  const _ProductListPreviewHelper({
    @required this.list,
    @required this.iconSize,
  });

  final List<Product> list;
  final double iconSize;

  static const double _PREVIEW_SPACING = 8.0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> previews = <Widget>[];
    for (final Product product in list) {
      previews.add(GestureDetector(
        onTap: () async {
          await Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ProductPage(
                product: product,
              ),
            ),
          );
        },
        child: SmoothProductImage(
          product: product,
          width: iconSize,
          height: iconSize,
        ),
      ));
    }
    return Container(
      child: Wrap(
        direction: Axis.horizontal,
        children: previews,
        spacing: _PREVIEW_SPACING,
        runSpacing: _PREVIEW_SPACING,
      ),
      padding: const EdgeInsets.only(bottom: _PREVIEW_SPACING),
    );
  }
}
