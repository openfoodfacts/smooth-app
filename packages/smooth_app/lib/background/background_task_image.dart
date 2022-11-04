import 'dart:convert';
import 'dart:io';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:task_manager/task_manager.dart';

/// Background task about product image upload.
class BackgroundTaskImage extends AbstractBackgroundTask {
  const BackgroundTaskImage._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required this.imageField,
    required this.imagePath,
  });

  BackgroundTaskImage._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          imageField: json['imageField'] as String,
          imagePath: json['imagePath'] as String,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'IMAGE_UPLOAD';

  final String imageField;
  final String imagePath;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'imageField': imageField,
        'imagePath': imagePath,
      };

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromTask(final Task task) {
    try {
      final AbstractBackgroundTask result =
          BackgroundTaskImage._fromJson(task.data!);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  /// Adds the background task about uploading a product image.
  static Future<void> addTask(
    final String barcode, {
    required final ImageField imageField,
    required final File imageFile,
  }) async {
    // For "OTHER" images we randomize the id with timestamp
    // so that it runs separately.
    final String uniqueId = AbstractBackgroundTask.generateUniqueId(
      barcode,
      imageField.value,
      appendTimestamp: imageField == ImageField.OTHER,
    );
    final BackgroundTaskImage backgroundImageInputData = BackgroundTaskImage._(
      uniqueId: uniqueId,
      barcode: barcode,
      processName: _PROCESS_NAME,
      imageField: imageField.value,
      imagePath: imageFile.path,
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
  }

  /// Uploads the product image.
  @override
  Future<void> upload() async {
    final SendImage image = SendImage(
      lang: getLanguage(),
      barcode: barcode,
      imageField: ImageFieldExtension.getType(imageField),
      imageUri: Uri.parse(imagePath),
    );

    // TODO(AshAman999): check returned Status
    await OpenFoodAPIClient.addProductImage(getUser(), image);

    // Go to the file system and delete the file that was uploaded
    File(imagePath).deleteSync();
  }
}
