import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/homepage/body/homepage_list_title.dart';
import 'package:smooth_app/pages/homepage/body/homepage_scanned_list.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';

class HomePageScanHistory extends StatelessWidget {
  const HomePageScanHistory({super.key});

  static const int MAX_ITEMS = 10;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return HomePageListContainer(
      title: appLocalizations.homepage_list_last_scanned_title,
      sliver: SliverToBoxAdapter(
        child: FutureBuilder<List<Product>>(
          future: _loadProducts(
            context.watch<ContinuousScanModel>(),
            context.watch<LocalDatabase>(),
          ),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return EMPTY_WIDGET;
                }

                return HomePageHorizontalList<Product>(
                  items: snapshot.data!.map(
                    (Product product) => HomePageHorizontalListItem<Product>(
                      value: product,
                      line1: getProductName(product, appLocalizations),
                      line2: getProductBrandsList(
                        product,
                        appLocalizations,
                      ).firstOrNull,
                      background: ProductPicture.fromProduct(
                        product: product,
                        imageField: ImageField.FRONT,
                        fallbackUrl: product.imageFrontUrl,
                        borderRadius: ROUNDED_BORDER_RADIUS,
                        size: const Size(
                          HomePageHorizontalList.ITEM_WIDTH,
                          HomePageHorizontalList.ITEM_HEIGHT,
                        ),
                      ),
                    ),
                  ),
                  onItemTap: (HomePageHorizontalListItem<Product> item) =>
                      AppNavigator.of(context).push(
                        AppRoutes.PRODUCT(
                          item.value.barcode!,
                          heroTag: item.value.barcode,
                        ),
                        extra: item.value,
                      ),
                  onSeeMoreTap: () {},
                );
              },
        ),
      ),
    );
  }

  Future<List<Product>> _loadProducts(
    ContinuousScanModel model,
    LocalDatabase database,
  ) async {
    final Iterable<String> barcodes = model.getBarcodes().reversed.take(
      MAX_ITEMS,
    );

    final List<Product> products = <Product>[];
    for (final String barcode in barcodes) {
      final Product? product = await DaoProduct(database).get(barcode);
      if (product != null) {
        products.add(product);
      }
    }
    return products;
  }
}
