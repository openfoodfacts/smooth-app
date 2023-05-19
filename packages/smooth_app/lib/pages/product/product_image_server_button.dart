import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/image/uploaded_image_gallery.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/query/product_query.dart';

/// Button asking for a "server" photo (taken from what was already uploaded).
class ProductImageServerButton extends StatelessWidget {
  const ProductImageServerButton({
    required this.barcode,
    required this.imageField,
    required this.language,
  });

  final String barcode;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;

  @override
  Widget build(BuildContext context) => EditImageButton(
        iconData: Icons.image_search,
        label: AppLocalizations.of(context)
            .edit_photo_select_existing_button_label,
        onPressed: () async => _actionGallery(context),
      );

  Future<void> _actionGallery(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!context.mounted) {
      return;
    }
    final bool loggedIn = await ProductRefresher().checkIfLoggedIn(context);
    if (!loggedIn) {
      return;
    }
    if (context.mounted) {
    } else {
      return;
    }
    final List<int>? result = await LoadingDialog.run<List<int>>(
      future: OpenFoodAPIClient.getProductImageIds(
        barcode,
        user: ProductQuery.getUser(),
      ),
      context: context,
      title: appLocalizations.edit_photo_select_existing_download_label,
    );
    if (result == null) {
      return;
    }
    if (context.mounted) {
    } else {
      return;
    }
    if (result.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body:
              Text(appLocalizations.edit_photo_select_existing_downloaded_none),
          actionsAxis: Axis.vertical,
          positiveAction: SmoothActionButton(
            text: appLocalizations.okay,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => UploadedImageGallery(
          barcode: barcode,
          imageIds: result,
          imageField: imageField,
          language: language,
        ),
      ),
    );
  }
}
