import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/background_tasks_model.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/dao_tasks.dart';
import 'package:smooth_app/database/local_database.dart';
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
  // get time since epoch in milliseconds
  final int uniqueId = DateTime.now().millisecondsSinceEpoch;
  final BackgroundImageInputData backgroundImageInputData =
      BackgroundImageInputData(
    processName: 'ImageUpload',
    uniqueId: uniqueId,
    barcode: barcode,
    imageField: imageField.value,
    imageUri: File(imageUri.path).path,
    languageCode: ProductQuery.getLanguage().code,
    user: jsonEncode(ProductQuery.getUser().toJson()),
    country: ProductQuery.getCountry()!.iso2Code,
  );
  // generate a random 8 digit word as the task name
  await TaskManager().addTask(
    Task(
      data: backgroundImageInputData.toJson(),
      uniqueId: uniqueId,
    ),
  );
  final DaoBackgroundTask daoBackgroundTask = DaoBackgroundTask(localDatabase);
  await daoBackgroundTask.put(
    BackgroundTaskModel(
      backgroundTaskId: uniqueId,
      backgroundTaskName: 'ImageUpload',
      backgroundTaskDescription:
          getImageUploadedMessage(imageField, appLocalizations),
      barcode: barcode,
      dateTime: DateTime.now(),
      status: 'Pending',
      taskMap: backgroundImageInputData.toJson(),
    ),
  );
  localDatabase.notifyListeners();
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        appLocalizations.image_upload_queued,
      ),
      duration: const Duration(seconds: 3),
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
