import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/background_task_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_random.dart';
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
        await Workmanager().initialize(callbackDispatcher);
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
        final LocalDatabase localDatabase =
            await LocalDatabase.getLocalDatabase();
        final DaoProduct daoProduct = DaoProduct(localDatabase);
        final ProductQueryConfiguration configuration =
            ProductQueryConfiguration(
          inputTask.barcode,
          fields: ProductQuery.fields,
          language: LanguageHelper.fromJson(inputTask.languageCode),
          country: ProductQuery.getCountry(),
        );
        try {
          final ProductResult result =
              await OpenFoodAPIClient.getProduct(configuration);
          if (result.status == 1) {
            final Product? product = result.product;
            if (product != null) {
              await daoProduct.put(product);
            }
          }
        } catch (e) {
          debugPrint('Error: $e,Updating to localdatabse failed');
          // Return true as the task of uploading image is completed successfully
          // It's just the task of updating the product in the local database is failed
          // The user can simply refresh it
          return true;
        }
        // Returns true to let platform know that the task is completed
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
    languageCode: ProductQuery.getLanguage().code,
  );

  await Workmanager().initialize(callbackDispatcher);
  // generate a random 8 digit word as the task name
  final SmoothRandom smoothie = SmoothRandom();
  final String uniqueId =
      'ImageUploader_${barcode}_${imageField.value}${smoothie.generateRandomString(8)}';
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
