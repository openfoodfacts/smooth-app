import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterEditButton extends StatelessWidget {
  const ProductFooterEditButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.edit_product_label_short,
      semanticsLabel: appLocalizations.edit_product_label,
      icon: const icons.Edit(),
      onTap: () => _editProduct(context, context.read<Product>()),
    );
  }

  Future<void> _editProduct(BuildContext context, Product product) async {
    ProductPageState.of(context).stopRobotoffQuestion();

    AnalyticsHelper.trackEvent(
      AnalyticsEvent.openProductEditPage,
      barcode: product.barcode,
    );

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EditProductPage(product),
      ),
    );

    if (context.mounted) {
      ProductPageState.of(context).startRobotoffQuestion();
    }
  }
}
