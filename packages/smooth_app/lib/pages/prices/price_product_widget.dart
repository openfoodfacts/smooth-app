import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';

/// Price Product display (no price data here).
class PriceProductWidget extends StatelessWidget {
  const PriceProductWidget(
    this.priceProduct, {
    required this.model,
  });

  final PriceProduct priceProduct;
  final GetPricesModel model;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double size = screenSize.width * 0.20;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String name = priceProduct.name ?? priceProduct.code;
    final bool unknown = priceProduct.name == null;
    final String? imageURL = priceProduct.imageURL;
    final int priceCount = priceProduct.priceCount ?? 0;
    final List<String>? brands =
        priceProduct.brands == '' ? null : priceProduct.brands?.split(',');
    final String? quantity = priceProduct.quantity == null
        ? null
        : '${priceProduct.quantity} ${priceProduct.quantityUnit ?? 'g'}';
    return Semantics(
      label: _generateSemanticsLabel(
        appLocalizations,
        name,
        brands,
        quantity,
        priceCount,
      ),
      container: true,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: size,
            child: SmoothImage(
              width: size,
              height: size,
              imageProvider: imageURL == null ? null : NetworkImage(imageURL),
            ),
          ),
          const SizedBox(width: SMALL_SPACE),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  name,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  spacing: VERY_SMALL_SPACE,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 0,
                  children: <Widget>[
                    PriceCountWidget(
                      count: priceCount,
                      onPressed: !model.enableCountButton
                          ? null
                          : () async {
                              final LocalDatabase localDatabase =
                                  context.read<LocalDatabase>();
                              final Product? newProduct =
                                  await DaoProduct(localDatabase)
                                      .get(priceProduct.code);
                              if (!context.mounted) {
                                return;
                              }
                              return Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => PricesPage(
                                    GetPricesModel.product(
                                      product: newProduct != null
                                          ? PriceMetaProduct.product(newProduct)
                                          : PriceMetaProduct.priceProduct(
                                              priceProduct),
                                      context: context,
                                    ),
                                  ),
                                ),
                              );
                            },
                    ),
                    if (brands != null)
                      for (final String brand in brands)
                        PriceButton(
                          title: brand,
                          onPressed: () {},
                        ),
                    if (quantity != null) Text(quantity),
                    if (unknown)
                      PriceButton(
                        title: appLocalizations.prices_unknown_product,
                        iconData: PriceButton.warningIconData,
                        onPressed: null,
                        buttonStyle: ElevatedButton.styleFrom(
                          disabledForegroundColor: Colors.red,
                          disabledBackgroundColor: Colors.red[100],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateSemanticsLabel(
    AppLocalizations appLocalizations,
    String productName,
    List<String>? brands,
    String? quantity,
    int priceCount,
  ) {
    final StringBuffer product = StringBuffer(productName);
    if (brands?.isNotEmpty == true) {
      product.write(' - ${brands!.join(', ')}');
    }
    if (quantity?.isNotEmpty == true) {
      product.write(' ($quantity)');
    }

    return appLocalizations.prices_product_accessibility_summary(
      priceCount,
      product.toString(),
    );
  }
}
