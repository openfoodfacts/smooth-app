import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/image/uploaded_image_gallery.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/query/product_query.dart';

/// Button asking for a "server" photo (taken from what was already uploaded).
class ProductImageServerButton extends StatelessWidget {
  const ProductImageServerButton({
    required this.product,
    required this.imageField,
    required this.language,
    required this.isLoggedInMandatory,
    this.borderWidth,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final bool isLoggedInMandatory;
  final double? borderWidth;

  static bool _hasServerImages(final Product product) =>
      product.images?.isNotEmpty == true;

  String get barcode => product.barcode!;

  @override
  Widget build(BuildContext context) {
    if (!_hasServerImages(product)) {
      return EMPTY_WIDGET;
    }
    return EditImageButton(
      iconData: Icons.image_search,
      label:
          AppLocalizations.of(context).edit_photo_select_existing_button_label,
      onPressed: () async => _actionGallery(context),
      borderWidth: borderWidth,
    );
  }

  Future<void> _actionGallery(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    List<int>? result;
    if (context.mounted) {
      result = await LoadingDialog.run<List<int>>(
        future: OpenFoodAPIClient.getProductImageIds(
          barcode,
          user: ProductQuery.getUser(),
          uriHelper: ProductQuery.uriProductHelper,
        ),
        context: context,
        title: appLocalizations.edit_photo_select_existing_download_label,
      );
    }

    if (context.mounted) {
      if (result?.isEmpty == true) {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) => SmoothAlertDialog(
            body: Text(
                appLocalizations.edit_photo_select_existing_downloaded_none),
            actionsAxis: Axis.vertical,
            positiveAction: SmoothActionButton(
              text: appLocalizations.okay,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
        return;
      } else {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => UploadedImageGallery(
              barcode: barcode,
              imageIds: result!,
              imageField: imageField,
              language: language,
              isLoggedInMandatory: isLoggedInMandatory,
            ),
          ),
        );
      }
    }
  }
}
