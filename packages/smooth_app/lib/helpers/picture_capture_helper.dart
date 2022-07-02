import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/query/product_query.dart';

Future<bool> uploadCapturedPicture(
  BuildContext context, {
  required String barcode,
  required ImageField imageField,
  required Uri imageUri,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
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
    title: appLocalizations.uploading_image,
  );
  if (result == null || result.error != null || result.status != 'status ok') {
    await LoadingDialog.error(
      context: context,
      title: appLocalizations.error_occurred,
    );
    return false;
  }
  //ignore: use_build_context_synchronously
  await _updateContinuousScanModel(context, barcode);
  return true;
}

Future<void> _updateContinuousScanModel(
    BuildContext context, String barcode) async {
  final ContinuousScanModel model = context.read<ContinuousScanModel>();
  await model.onCreateProduct(barcode);
}

String getImageUploadedMessage(
    ImageField imageField, AppLocalizations appLocalizations) {
  String message = '';
  switch (imageField) {
    case ImageField.FRONT:
      message = appLocalizations.front_photo_uploaded;
      break;
    case ImageField.INGREDIENTS:
      message = appLocalizations.ingredients_photo_uploaded;
      break;
    case ImageField.NUTRITION:
      message = appLocalizations.nutritional_facts_photo_uploaded;
      break;
    case ImageField.PACKAGING:
      message = appLocalizations.recycling_photo_uploaded;
      break;
    case ImageField.OTHER:
      message = appLocalizations.other_photo_uploaded;
      break;
  }
  return message;
}
