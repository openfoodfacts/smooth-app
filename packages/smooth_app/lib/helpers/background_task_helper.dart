import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/data_models/background_tasks_model.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_tasks.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/background_taks_constants.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask(
    (String task, Map<String, dynamic>? inputData) async {
      final String processName = inputData!['processName'] as String;
      switch (processName) {
        case 'ImageUpload':
          return uploadImage(inputData);
        case 'Others':
          return otherDetails(inputData);
        default:
          return Future<bool>.error('Unknown task');
      }
    },
  );
}

Future<bool> otherDetails(Map<String, dynamic> inputData) async {
  final BackgroundOtherDetailsInput inputTask =
      BackgroundOtherDetailsInput.fromJson(inputData);
  final LocalDatabase localDatabase = await LocalDatabase.getLocalDatabase();
  final DaoProduct daoProduct = DaoProduct(localDatabase);
  final DaoBackgroundTask daoBackgroundTask = DaoBackgroundTask(localDatabase);
  final int counter = inputTask.counter;
  // if task is greater than 6 , that means it has been executed 7 times
  if (counter > BACKGROUND_DURATION_LIST.length - 1) {
    // returns true to let platform know that the task is completed
    return true;
  }
  bool shouldRetry = false;
  try {
    final Map<String, dynamic> mp =
        json.decode(inputTask.inputMap) as Map<String, dynamic>;
    final User user =
        User.fromJson(jsonDecode(inputTask.user) as Map<String, dynamic>);
    final Status result = await OpenFoodAPIClient.saveProduct(
      user,
      Product.fromJson(mp),
      language: LanguageHelper.fromJson(inputTask.languageCode),
      country: CountryHelper.fromJson(inputTask.country),
    );
    shouldRetry = result.error != null;
  } catch (e) {
    shouldRetry = true;
  }
  if (shouldRetry) {
    inputTask.counter += 1;
    await Workmanager().initialize(callbackDispatcher);
    final BackgroundTaskModel? retryBackgroundTaskModel =
        await daoBackgroundTask.get(inputTask.uniqueId);
    await daoBackgroundTask.delete(inputTask.uniqueId);
    retryBackgroundTaskModel!.backgroundTaskId =
        '${inputTask.uniqueId}_${inputTask.counter}';
    inputTask.uniqueId = retryBackgroundTaskModel.backgroundTaskId;
    await daoBackgroundTask.put(retryBackgroundTaskModel);
    await Workmanager().registerOneOffTask(
      '${inputTask.uniqueId}_${inputTask.counter}',
      UNIVERSAL_BACKGROUND_PROCESS_TASK_NAME,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: inputTask.toJson(),
      initialDelay: BACKGROUND_DURATION_LIST[inputTask.counter - 1],
    );
    return Future<bool>.error('Failed and it will try again');
  } else {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
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
          await daoBackgroundTask.delete(inputTask.uniqueId);
          localDatabase.notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error: $e,Updating to local database failed');
      // Return true as the task of uploading image is completed successfully
      // It's just that the task of updating the product in the local database has failed
      // The user can simply refresh it
      return true;
    }
    // Returns true to let platform know that the task is completed
    return true;
  }
}

Future<bool> uploadImage(Map<String, dynamic> inputData) async {
  final BackgroundImageInputData inputTask =
      BackgroundImageInputData.fromJson(inputData);
  final LocalDatabase localDatabase = await LocalDatabase.getLocalDatabase();
  final DaoProduct daoProduct = DaoProduct(localDatabase);
  final DaoBackgroundTask daoBackgroundTask = DaoBackgroundTask(localDatabase);
  final int counter = inputTask.counter;
  // if task is greater than 6 , that means it has been executed 7 times
  if (counter > BACKGROUND_DURATION_LIST.length - 1) {
    // returns true to let platform know that the task is completed
    final File file = File(inputTask.imageUri);
    file.deleteSync();
    return true;
  }
  final User user =
      User.fromJson(jsonDecode(inputTask.user) as Map<String, dynamic>);
  bool shouldRetry = false;
  try {
    final SendImage image = SendImage(
      lang: LanguageHelper.fromJson(inputTask.languageCode),
      barcode: inputTask.barcode,
      imageField: ImageFieldExtension.getType(inputTask.imageField),
      imageUri: Uri.parse(inputTask.imageUri),
    );
    final Status result = await OpenFoodAPIClient.addProductImage(
      user,
      image,
    );
    shouldRetry = result.error != null || result.status != 'status ok';
  } catch (e) {
    shouldRetry = true;
  }
  if (shouldRetry) {
    inputTask.counter += 1;
    await Workmanager().initialize(callbackDispatcher);
    final BackgroundTaskModel? retryBackgroundTaskModel =
        await daoBackgroundTask.get(inputTask.uniqueId);
    await daoBackgroundTask.delete(inputTask.uniqueId);
    retryBackgroundTaskModel!.backgroundTaskId =
        '${inputTask.uniqueId}_${inputTask.counter}';
    inputTask.uniqueId = retryBackgroundTaskModel.backgroundTaskId;
    await daoBackgroundTask.put(retryBackgroundTaskModel);
    await Workmanager().registerOneOffTask(
      '${inputTask.uniqueId}_${inputTask.counter}',
      UNIVERSAL_BACKGROUND_PROCESS_TASK_NAME,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: inputTask.toJson(),
      initialDelay: BACKGROUND_DURATION_LIST[inputTask.counter - 1],
    );

    return Future<bool>.error('Failed and it will try again');
  } else {
    // go to the file system and delete the file that was uploaded
    final File file = File(inputTask.imageUri);
    file.deleteSync();

    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
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
          await daoBackgroundTask.delete(inputTask.uniqueId);
          localDatabase.notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error: $e,Updating to local database failed');
      // Return true as the task of uploading image is completed successfully
      // It's just that the task of updating the product in the local database has failed
      // The user can simply refresh it
      return true;
    }
    // Returns true to let platform know that the task is completed
    return true;
  }
}

/// Helper class for serialization and deserialization of data for the background task
class BackgroundImageInputData {
  BackgroundImageInputData({
    required this.processName,
    required this.uniqueId,
    required this.barcode,
    required this.imageField,
    required this.imageUri,
    required this.counter,
    required this.languageCode,
    required this.user,
    required this.country,
  });

  BackgroundImageInputData.fromJson(Map<String, dynamic> json)
      : processName = json['processName'] as String,
        uniqueId = json['uniqueId'] as String,
        barcode = json['barcode'] as String,
        imageField = json['imageField'] as String,
        imageUri = json['imageUri'] as String,
        counter = json['counter'] as int,
        languageCode = json['languageCode'] as String,
        user = json['user'] as String,
        country = json['country'] as String;

  final String processName;
  String uniqueId;
  final String barcode;
  final String imageField;
  final String imageUri;
  int counter;
  final String languageCode;
  String user;
  final String country;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'imageField': imageField,
        'imageUri': imageUri,
        'counter': counter,
        'languageCode': languageCode,
        'user': user,
        'country': country,
      };
}

class BackgroundOtherDetailsInput {
  BackgroundOtherDetailsInput({
    required this.processName,
    required this.uniqueId,
    required this.barcode,
    required this.counter,
    required this.languageCode,
    required this.inputMap,
    required this.user,
    required this.country,
  });
  BackgroundOtherDetailsInput.fromJson(Map<String, dynamic> json)
      : processName = json['processName'] as String,
        uniqueId = json['uniqueId'] as String,
        barcode = json['barcode'] as String,
        counter = json['counter'] as int,
        languageCode = json['languageCode'] as String,
        inputMap = json['inputMap'] as String,
        user = json['user'] as String,
        country = json['country'] as String;
  final String processName;
  String uniqueId;
  final String barcode;
  int counter;
  final String languageCode;
  String inputMap;
  final String user;
  final String country;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'counter': counter,
        'languageCode': languageCode,
        'inputMap': inputMap,
        'user': user,
        'country': country,
      };
}
