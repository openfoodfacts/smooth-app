import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/helpers/background_task_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_random.dart';
import 'package:workmanager/workmanager.dart';

Future<bool> uploadCapturedPicture(
  BuildContext context, {
  required String barcode,
  required ImageField imageField,
  required Uri imageUri,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  final BackgroundImageInputData inputData = BackgroundImageInputData(
    processName: 'ImageUpload',
    barcode: barcode,
    imageField: imageField.value,
    imageUri: File(imageUri.path).path,
    counter: 0,
    languageCode: ProductQuery.getLanguage().code,
  );
  // generate a random 8 digit word as the task name
  final String uniqueId =
      'ImageUploader_${barcode}_${imageField.value}${SmoothRandom.generateRandomString(8)}';
  await Workmanager().registerOneOffTask(
    uniqueId,
    'BackgroundProcess', // TODO(g123k): change this in ios config
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    inputData: inputData.toJson(),
  );
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        appLocalizations.image_upload_queued,
      ),
    ),
  );
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
