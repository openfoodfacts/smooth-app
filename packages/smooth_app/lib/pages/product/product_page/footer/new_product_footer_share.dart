import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterShareButton extends StatelessWidget {
  const ProductFooterShareButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.share,
      vibrate: true,
      icon: icons.Share(),
      onTap: () => _shareProduct(context, context.read<Product>()),
    );
  }

  Future<void> _shareProduct(BuildContext context, Product product) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.shareProduct,
      barcode: product.barcode,
    );
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    // We need to provide a sharePositionOrigin to make the plugin work on ipad
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String url = 'https://'
        '${ProductQuery.getCountry().offTag}.${(product.productType ?? ProductType.food).getDomain()}.org'
        '/product/${product.barcode}';
    Share.share(
      switch (product.productType) {
        ProductType.beauty => appLocalizations.share_product_text_beauty(url),
        ProductType.petFood =>
          appLocalizations.share_product_text_pet_food(url),
        ProductType.product => appLocalizations.share_product_text_product(url),
        _ => appLocalizations.share_product_text(url),
      },
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }
}
