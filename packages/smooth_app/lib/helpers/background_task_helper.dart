import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:task_manager/task_manager.dart';

Future<TaskResult> callbackDispatcher() async {
  await TaskManager().init(
      executor: (Task inputData) async {
        final String processName = inputData.data!['processName'] as String;
        switch (processName) {
          case 'ImageUpload':
            return uploadImage(inputData.data!);

          case 'Others':
            return otherDetails(inputData.data!);

          default:
            return TaskResult.success;
        }
      },
      listener: (Task task, TaskStatus status) {});
  return TaskResult.success;
}

Future<TaskResult> otherDetails(Map<String, dynamic> inputData) async {
  try {
    final BackgroundOtherDetailsInput inputTask =
        BackgroundOtherDetailsInput.fromJson(inputData);
    final Map<String, dynamic> mp =
        json.decode(inputTask.inputMap) as Map<String, dynamic>;
    final User user =
        User.fromJson(jsonDecode(inputTask.user) as Map<String, dynamic>);
    await OpenFoodAPIClient.saveProduct(
      user,
      Product.fromJson(mp),
      language: LanguageHelper.fromJson(inputTask.languageCode),
      country: CountryHelper.fromJson(inputTask.country),
    );
  } catch (e) {
    debugPrint('Error: $e,Updating to local database failed');
    // Return true as the task of uploading image is completed successfully
    // It's just that the task of updating the product in the local database has failed
    // The user can simply refresh it
    return TaskResult.success;
  }
  // Returns true to let platform know that the task is completed
  return TaskResult.success;
}

Future<TaskResult> uploadImage(Map<String, dynamic> inputData) async {
  try {
    final BackgroundImageInputData inputTask =
        BackgroundImageInputData.fromJson(inputData);
    final User user =
        User.fromJson(jsonDecode(inputTask.user) as Map<String, dynamic>);
    final SendImage image = SendImage(
      lang: LanguageHelper.fromJson(inputTask.languageCode),
      barcode: inputTask.barcode,
      imageField: ImageFieldExtension.getType(inputTask.imageField),
      imageUri: Uri.parse(inputTask.imageUri),
    );
    await OpenFoodAPIClient.addProductImage(user, image);
    // go to the file system and delete the file that was uploaded
    final File file = File(inputTask.imageUri);
    file.deleteSync();
    return TaskResult.success;
  } catch (e) {
    debugPrint('Error: $e');
    // Returns true to let platform know that the task is completed
    return TaskResult.success;
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
