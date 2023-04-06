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
class ProductImageUnswipeableView extends StatefulWidget {
  const ProductImageUnswipeableView({
    super.key,
    required this.product,
    required this.imageField,
  });

  final Product product;
  final ImageField imageField;

  @override
  State<ProductImageUnswipeableView> createState() =>
      _ProductImageUnswipeableViewState();
}

class _ProductImageUnswipeableViewState
    extends State<ProductImageUnswipeableView> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: WHITE_COLOR,
        elevation: 0,
        title: Text(
          getImagePageTitle(appLocalizations, widget.imageField),
          maxLines: 2,
        ),
        leading: SmoothBackButton(
          iconColor: Colors.white,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ProductImageViewer(
        product: widget.product,
        imageField: widget.imageField,
      ),
    );
  }
}
