import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_unselect.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_image_button.dart';

/// Product Image Button unselecting the current image.
class ProductImageUnselectButton extends ProductImageButton {
  const ProductImageUnselectButton({
    required super.product,
    required super.imageField,
    required super.language,
    required super.isLoggedInMandatory,
    required this.productType,
    super.borderWidth,
  });

  final ProductType? productType;

  @override
  IconData getIconData() => Icons.do_disturb_on;

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_photo_unselect_button_label;

  @override
  Future<void> action(final BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    if (!context.mounted) {
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: appLocalizations.confirm_button_label,
          body: Text(
            appLocalizations.are_you_sure,
          ),
          close: true,
          positiveAction: SmoothActionButton(
            text: appLocalizations.yes,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.no,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await BackgroundTaskUnselect.addTask(
      barcode,
      imageField: imageField,
      context: context,
      language: language,
      productType: productType,
    );
    localDatabase.notifyListeners();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}
