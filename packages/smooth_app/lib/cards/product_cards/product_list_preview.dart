// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/cards/product_cards/product_list_preview_helper.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

class ProductListPreview extends StatelessWidget {
  const ProductListPreview({
    @required this.daoProductList,
    @required this.productList,
    @required this.nbInPreview,
  });

  final DaoProductList daoProductList;
  final ProductList productList;
  final int nbInPreview;

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
              subtitle = AppLocalizations.of(context).empty_list;
            }
            return SmoothCard(
              insets: const EdgeInsets.all(1.0),
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
                      await Navigator.push<Widget>(
                        context,
                        MaterialPageRoute<Widget>(
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
                    trailing: const Icon(Icons.arrow_forward),
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
          return SmoothCard(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              subtitle: Text(title),
              title: Text(
                AppLocalizations.of(context).searching,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          );
        },
      );
}
