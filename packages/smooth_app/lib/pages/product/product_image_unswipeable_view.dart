import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/product_image_viewer.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Display of the photo of a product image field.
///
/// See also [ProductImageSwipeableView].
class ProductImageUnswipeableView extends StatelessWidget {
  const ProductImageUnswipeableView({
    super.key,
    required this.product,
    required this.imageField,
  });

  final Product product;
  final ImageField imageField;

  @override
  Widget build(BuildContext context) => SmoothScaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: WHITE_COLOR,
          elevation: 0,
          title: Text(
            getImagePageTitle(AppLocalizations.of(context), imageField),
            maxLines: 2,
          ),
          leading: SmoothBackButton(
            iconColor: Colors.white,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: ProductImageViewer(
          product: product,
          imageField: imageField,
        ),
      );
}
