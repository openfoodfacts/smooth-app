import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterOpenWebsiteButton extends StatelessWidget {
  const ProductFooterOpenWebsiteButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();

    return ProductFooterButton(
      label: appLocalizations.product_footer_action_open_website,
      semanticsLabel: appLocalizations.product_footer_action_open_website,
      icon: const icons.ExternalLink(),
      onTap: () => AppNavigator.of(context).push(
        AppRoutes.EXTERNAL('https://'
            '${ProductQuery.getCountry().offTag}.${(product.productType ?? ProductType.food).getDomain()}.org'
            '/product/${product.barcode}'),
      ),
    );
  }
}
