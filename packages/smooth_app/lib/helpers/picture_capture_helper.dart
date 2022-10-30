import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

Future<bool> uploadCapturedPicture({
  required String barcode,
  required ImageField imageField,
  required Uri imageUri,
  required State<StatefulWidget> widget,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(widget.context);
  final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
  await BackgroundTaskImage.addTask(
    barcode,
    imageField: imageField,
    imageFile: File(imageUri.path),
  );
  localDatabase.notifyListeners();
  if (!widget.mounted) {
    return true;
  }
  ScaffoldMessenger.of(widget.context).showSnackBar(
    SnackBar(
      content: Text(
        appLocalizations.image_upload_queued,
      ),
      duration: SnackBarDuration.medium,
    ),
  );
  await _updateContinuousScanModel(widget.context, barcode);
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
