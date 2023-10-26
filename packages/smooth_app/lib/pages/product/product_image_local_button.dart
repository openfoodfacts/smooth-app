import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';

/// Button asking for a "local" photo (new from camera, existing from gallery).
class ProductImageLocalButton extends StatefulWidget {
  const ProductImageLocalButton({
    required this.firstPhoto,
    required this.barcode,
    required this.imageField,
    required this.language,
    required this.isLoggedInMandatory,
    this.borderWidth,
  });

  final bool firstPhoto;
  final String barcode;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final bool isLoggedInMandatory;
  final double? borderWidth;

  @override
  State<ProductImageLocalButton> createState() =>
      _ProductImageLocalButtonState();
}

class _ProductImageLocalButtonState extends State<ProductImageLocalButton> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return EditImageButton(
      iconData: widget.firstPhoto ? Icons.add : Icons.add_a_photo,
      label:
          widget.firstPhoto ? appLocalizations.add : appLocalizations.capture,
      onPressed: () async => _actionNewImage(context),
      borderWidth: widget.borderWidth,
    );
  }

  Future<void> _actionNewImage(final BuildContext context) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    )) {
      return;
    }
    if (context.mounted) {
    } else {
      return;
    }
    await confirmAndUploadNewPicture(
      this,
      imageField: widget.imageField,
      barcode: widget.barcode,
      language: widget.language,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    );
  }
}
