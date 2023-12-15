import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
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
      appBar: SmoothAppBar(
        centerTitle: false,
        title: Text(appLocalizations.edit_product_form_item_photos_title),
        subTitle: buildProductTitle(product, appLocalizations),
      ),
      body: Image(
        image: NetworkImage(
          ImageHelper.getUploadedImageUrl(
            product.barcode!,
            imageId,
            ImageSize.ORIGINAL,
          ),
        ),
        fit: BoxFit.cover,
      ),
    );
  }
}
