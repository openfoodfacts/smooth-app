import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
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
      final String processName = inputData!['processName'] as String;
      switch (processName) {
        case 'ImageUpload':
          return uploadImage(task, inputData, duration);
        case 'BasicInput':
          return addBasicDetails(task, inputData, duration);
        default:
          return Future<bool>.error('Unknown task');
      }
    },
  );
}

Future<bool> addBasicDetails(String task, Map<String, dynamic> inputData,
    List<Duration> duration) async {
  final BackgroundBasicDetailsInput inputTask =
      BackgroundBasicDetailsInput.fromJson(inputData);
  final int counter = inputTask.counter;
  // if task is greater than 6 , that means it has been executed 7 times
  if (counter > duration.length) {
    // returns true to let platform know that the task is completed
    return true;
  }
  bool shouldRetry = false;
  try {
    final Status result = await OpenFoodAPIClient.saveProduct(
      ProductQuery.getUser(),
      Product(
        barcode: inputTask.barcode,
        quantity: inputTask.quantity,
        brands: inputTask.brands,
        productName: inputTask.productName,
      ),
      language: LanguageHelper.fromJson(inputTask.languageCode),
      country: ProductQuery.getCountry(),
    );
    shouldRetry = result.error != null;
  } catch (e) {
    shouldRetry = true;
  }
  if (shouldRetry) {
    inputTask.counter += 1;
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerOneOffTask(
      task,
      'BackgroundProcess',
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: inputTask.toJson(),
      initialDelay: duration[inputTask.counter],
    );
    return Future<bool>.error('Failed and it will try again');
  } else {
    final LocalDatabase localDatabase = await LocalDatabase.getLocalDatabase();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
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

Future<bool> uploadImage(String task, Map<String, dynamic> inputData,
    List<Duration> duration) async {
  final BackgroundImageInputData inputTask =
      BackgroundImageInputData.fromJson(inputData);
  final int counter = inputTask.counter;
  // if task is greater than 6 , that means it has been executed 7 times
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
      'BackgroundProcess',
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: inputTask.toJson(),
      initialDelay: duration[inputTask.counter],
    );
    return Future<bool>.error('Failed and it will try again');
  } else {
    // go to the file system and delete the file that was uploaded
    final File file = File(inputTask.imageUri);
    file.deleteSync();
    final LocalDatabase localDatabase = await LocalDatabase.getLocalDatabase();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
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
    required this.barcode,
    required this.imageField,
    required this.imageUri,
    required this.counter,
    required this.languageCode,
  });

  BackgroundImageInputData.fromJson(Map<String, dynamic> json)
      : processName = json['processName'] as String,
        barcode = json['barcode'] as String,
        imageField = json['imageField'] as String,
        imageUri = json['imageUri'] as String,
        counter = json['counter'] as int,
        languageCode = json['languageCode'] as String;

  final String processName;
  final String barcode;
  final String imageField;
  final String imageUri;
  int counter;
  final String languageCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'barcode': barcode,
        'imageField': imageField,
        'imageUri': imageUri,
        'counter': counter,
        'languageCode': languageCode,
      };
}

class BackgroundBasicDetailsInput {
  BackgroundBasicDetailsInput({
    required this.processName,
    required this.barcode,
    required this.counter,
    required this.languageCode,
    required this.productName,
    required this.quantity,
    required this.brands,
  });
  BackgroundBasicDetailsInput.fromJson(Map<String, dynamic> json)
      : processName = json['processName'] as String,
        barcode = json['barcode'] as String,
        counter = json['counter'] as int,
        languageCode = json['languageCode'] as String,
        productName = json['productName'] as String,
        quantity = json['quantity'] as String,
        brands = json['brands'] as String;

  final String processName;
  final String barcode;
  int counter;
  final String languageCode;
  final String productName;
  final String quantity;
  final String brands;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'barcode': barcode,
        'counter': counter,
        'languageCode': languageCode,
        'productName': productName,
        'quantity': quantity,
        'brands': brands,
      };
}
