import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';

Future<bool> uploadCapturedPicture(
  BuildContext context, {
  required String barcode,
  required ImageField imageField,
  required Uri imageUri,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  final SendImage image = SendImage(
    lang: ProductQuery.getLanguage(),
    barcode: barcode,
    imageField: imageField,
    imageUri: imageUri,
  );
  final Status? result = await LoadingDialog.run<Status>(
    context: context,
    future: OpenFoodAPIClient.addProductImage(
      ProductQuery.getUser(),
      image,
    ),
    title: appLocalizations.uploading_image(
      _imageFieldLabel(
        appLocalizations,
        imageField,
      ),
    ),
  );
  if (result == null || result.error != null || result.status != 'status ok') {
    await LoadingDialog.error(
      context: context,
      title: appLocalizations.error_occurred,
    );
    return false;
  }
  await _updateContinuousScanModel(context, barcode);
  return true;
}

String _imageFieldLabel(
  AppLocalizations appLocalizations,
  ImageField field,
) {
  switch (field) {
    case ImageField.FRONT:
      return appLocalizations.uploading_image_type_front;
    case ImageField.INGREDIENTS:
      return appLocalizations.uploading_image_type_ingredients;
    case ImageField.NUTRITION:
      return appLocalizations.uploading_image_type_nutrition;
    case ImageField.PACKAGING:
      return appLocalizations.uploading_image_type_packaging;
    case ImageField.OTHER:
      return appLocalizations.uploading_image_type_other;
  }
}

Future<void> _updateContinuousScanModel(
    BuildContext context, String barcode) async {
  final ContinuousScanModel? model =
      await ContinuousScanModel().load(context.read<LocalDatabase>());
  await model?.onCreateProduct(barcode);
}
