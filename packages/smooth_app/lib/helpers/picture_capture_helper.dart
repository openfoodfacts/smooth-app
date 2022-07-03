import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/helpers/background_task_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask(
    (String task, Map<String, dynamic>? inputData) async {
      const List<Duration> duration = <Duration>[
        Duration(seconds: 30),
        Duration(minutes: 1),
        Duration(minutes: 30),
        Duration(hours: 1),
        Duration(hours: 6),
        Duration(days: 1),
      ];
      // make a counter with task as key as it is unique for each task
      final BackgroundInputData inputTask =
          BackgroundInputData.fromJson(inputData!);
      final int counter = inputTask.counter;
      // if task is greate than 6 , that means it has been executed 7 times
      if (counter > duration.length) {
        // returns true to let platform know that the task is completed
        final File file = File(inputTask.imageUri);
        file.deleteSync();
        return true;
      }

      bool shouldRetry = false;
      try {
        final SendImage image = SendImage(
          lang: ProductQuery.getLanguage(),
          barcode: inputTask.barcode,
          imageField: ImageFieldExtension.getType(inputTask.imageField),
          imageUri: Uri.parse(inputTask.imageUri),
        );
        final Status result = await OpenFoodAPIClient.addProductImage(
          ProductQuery.getUser(),
          image,
        );
        shouldRetry = result.error != null || result.status != 'status ok';
      } catch (e) {
        shouldRetry = true;
      }
      if (shouldRetry) {
        inputTask.counter += 1;
        await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
        await Workmanager().registerOneOffTask(
          task,
          'ImageUploadWorker',
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
          inputData: inputTask.toJson(),
          initialDelay: duration[counter - 1],
        );
        return Future<bool>.error('Failed and it will try again');
      } else {
        // go to the file system and delete the file that was uploaded
        final File file = File(inputData['imageUri'].toString());
        file.deleteSync();
        return true;
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
  final AppLocalizations appLocalizations = AppLocalizations.of(context);
  final BackgroundInputData inputData = BackgroundInputData(
    barcode: barcode,
    imageField: imageField.value,
    imageUri: File(imageUri.path).path,
    counter: 0,
  );

  await Workmanager().initialize(
      callbackDispatcher // The top level function, aka callbackDispatcher
      );
  // generate a random 4 digit word as the task name

  final String uniqueId =
      'ImageUploader_${barcode}_${imageField.value}${Random().nextInt(100)}';
  await Workmanager().registerOneOffTask(
    uniqueId,
    'ImageUploadWorker',
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
