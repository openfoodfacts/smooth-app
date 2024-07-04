import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Full page display of a raw product image.
class ProductImageOtherPage extends StatelessWidget {
  const ProductImageOtherPage(
    this.product,
    this.imageId,
  );

  final Product product;
  final int imageId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: buildEditProductAppBar(
        context: context,
        title: appLocalizations.edit_product_form_item_photos_title,
        product: product,
      ),
      body: Image(
        image: NetworkImage(
          ProductImage.raw(
            imgid: imageId.toString(),
            size: ImageSize.ORIGINAL,
          ).getUrl(
            product.barcode!,
            uriHelper: ProductQuery.uriProductHelper,
          ),
        ),
        fit: BoxFit.cover,
      ),
    );
  }
}
