import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/product_for_me_attributes.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/score/product_for_me_score.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/score/product_for_me_score_error.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';

class ProductForMeTab extends StatelessWidget {
  const ProductForMeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsumerFilter<Product>(
      buildWhen: (Product? previousValue, Product currentValue) =>
          previousValue?.productType != currentValue.productType,
      builder: (BuildContext context, Product product, Widget? child) {
        if (product.productType != ProductType.food) {
          final AppLocalizations appLocalizations = AppLocalizations.of(
            context,
          );

          return Align(
            alignment: AlignmentDirectional.topCenter,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LARGE_SPACE,
                vertical: MEDIUM_SPACE,
              ),
              child: ProductForMeCompatibilityError(
                label: appLocalizations
                    .product_page_for_me_compatibility_score_unsupported(
                      product.productType?.getLabel(appLocalizations) ??
                          appLocalizations.product_type_label_unknown,
                    ),
              ),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            ProductForMeScore(),
            SizedBox(height: LARGE_SPACE),
            ProductForMeAttributes(),
          ],
        );
      },
    );
  }
}
