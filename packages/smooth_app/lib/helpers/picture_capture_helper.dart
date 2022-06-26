import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask(
    (String task, Map<String, dynamic>? inputData) async {
      // make a counter with task as key as it is unique for each task
      final int counter = inputData!['counter'] as int;
      // if task is greate than 4 , that means it has been executed 5 times
      if (counter > 6) {
        // returns true to let platform know that the task is completed
        return Future<bool>.value(true);
      }
      final List<Duration> duration = <Duration>[
        const Duration(seconds: 30),
        const Duration(minutes: 1),
        const Duration(minutes: 30),
        const Duration(hours: 1),
        const Duration(hours: 6),
        const Duration(days: 1),
      ];
      bool shouldRetry = false;
      try {
        final SendImage image = SendImage(
          lang: ProductQuery.getLanguage(),
          barcode: inputData['barcode'].toString(),
          imageField:
              ImageFieldExtension.getType(inputData['imageField'].toString()),
          imageUri: Uri.parse(inputData['imageUri'].toString()),
        );
        final Status result = await OpenFoodAPIClient.addProductImage(
          ProductQuery.getUser(),
          image,
        );
        shouldRetry = result.error != null || result.status != 'status ok';
      } catch (e) {
        shouldRetry = true;
        debugPrint(e.toString());
      }
      if (shouldRetry) {
        inputData['counter'] = counter + 1;
        Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
        Workmanager().registerOneOffTask(
          task,
          'ImageUploadWorker',
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: true,
          ),
          inputData: inputData,
          initialDelay: duration[counter],
        );
        return Future<bool>.error('Failed and it will try again');
      } else {
        return Future<bool>.value(true);
      }
    },
  );
}

Future<bool> uploadCapturedPicture(
  BuildContext context, {
  required String barcode,
  required ImageField imageField,
  required Uri imageUri,
}) async {
  // ignore: unused_local_variable
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  final Map<String, dynamic> inputData = <String, dynamic>{
    'barcode': barcode,
    'imageField': imageField.value,
    'imageUri': File(imageUri.path).path,
    'counter': 0,
  };
  await Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  final String uniqueId = 'ImageUploader_${barcode}_${imageField.value}';
  await Workmanager().registerOneOffTask(
    uniqueId,
    'ImageUploadWorker',
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
    inputData: inputData,
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
