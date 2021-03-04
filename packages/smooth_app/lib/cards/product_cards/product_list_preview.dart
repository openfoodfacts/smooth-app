// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/cards/product_cards/product_list_preview_helper.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product_list_page.dart';
import 'package:smooth_app/pages/product_query_page_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

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
              color: SmoothTheme.getColor(
                Theme.of(context).colorScheme,
                productList.getMaterialColor(),
                ColorDestination.SURFACE_BACKGROUND,
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
                    leading: productList.getIcon(
                      Theme.of(context).colorScheme,
                      ColorDestination.SURFACE_FOREGROUND,
                    ),
                    trailing: const Icon(Icons.more_horiz),
                    subtitle: subtitle == null ? null : Text(subtitle),
                    title: Text(
                      title,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  ProductListPreviewHelper(
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
