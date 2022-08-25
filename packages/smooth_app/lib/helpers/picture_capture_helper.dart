import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/background_task_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:task_manager/task_manager.dart';

Future<bool> uploadCapturedPicture(
  BuildContext context, {
  required String barcode,
  required ImageField imageField,
  required Uri imageUri,
}) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  final LocalDatabase localDatabase = context.read<LocalDatabase>();
  final String uniqueId = _getUniqueId(imageField, barcode);
  final BackgroundImageInputData backgroundImageInputData =
      BackgroundImageInputData(
    processName: IMAGE_UPLOAD_TASK,
    uniqueId: uniqueId,
    barcode: barcode,
    imageField: imageField.value,
    imagePath: File(imageUri.path).path,
    languageCode: ProductQuery.getLanguage().code,
    user: jsonEncode(ProductQuery.getUser().toJson()),
    country: ProductQuery.getCountry()!.iso2Code,
  );
  await TaskManager().addTask(
    Task(
      data: backgroundImageInputData.toJson(),
      uniqueId: uniqueId,
    ),
  );

  localDatabase.notifyListeners();
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        appLocalizations.image_upload_queued,
      ),
      duration: SnackBarDuration.medium,
    ),
  );
  //ignore: use_build_context_synchronously
  await _updateContinuousScanModel(context, barcode);
  return true;
}

/// Generates a unique id for the task , in case of tasks with the same name
///.It gets replaced with the new one , also for other images we randomize the id with date time so that it runs seperately
/// example: 00000000_front_en_us_"random_user_id"
String _getUniqueId(ImageField imageField, String barcode) {
// use String buffer to concatenate strings
  final StringBuffer stringBuffer = StringBuffer();
  stringBuffer.write(barcode);
  stringBuffer.write('_');
  stringBuffer.write(imageField.value);
  stringBuffer.write('_');
  stringBuffer.write(ProductQuery.getLanguage().code);
  stringBuffer.write('_');
  stringBuffer.write(ProductQuery.getCountry()!.iso2Code);
  stringBuffer.write('_');
  stringBuffer.write(ProductQuery.getUser().userId);
  if (imageField != ImageField.OTHER) {
    return stringBuffer.toString();
  }
  stringBuffer.write('_');
  stringBuffer.write(DateTime.now().millisecondsSinceEpoch);
  return stringBuffer.toString();
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
