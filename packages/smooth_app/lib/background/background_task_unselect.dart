import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_barcode.dart';
import 'package:smooth_app/background/background_task_product_change.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Background task about unselecting a product image.
class BackgroundTaskUnselect extends BackgroundTaskBarcode
    implements BackgroundTaskProductChange {
  BackgroundTaskUnselect._({
    required super.processName,
    required super.uniqueId,
    required OpenFoodFactsLanguage super.language,
    required super.barcode,
    required super.productType,
    required super.stamp,
    required this.imageField,
  });

  BackgroundTaskUnselect.fromJson(super.json)
      : imageField = json[_jsonTagImageField] as String,
        super.fromJson();

  static const String _jsonTagImageField = 'imageField';

  static const OperationType _operationType = OperationType.unselect;

  final String imageField;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImageField] = imageField;
    return result;
  }

  /// Adds the background task about unselecting a product image.
  static Future<void> addTask(
    final String barcode, {
    required final ProductType? productType,
    required final ImageField imageField,
    required final BuildContext context,
    required final OpenFoodFactsLanguage language,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTaskBarcode task = _getNewTask(
      barcode,
      productType ?? ProductType.food,
      imageField,
      uniqueId,
      language,
    );
    if (!context.mounted) {
      return;
    }
    await task.addToManager(
      localDatabase,
      context: context,
      queue: BackgroundTaskQueue.fast,
    );
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.product_task_background_schedule,
        AlignmentDirectional.bottomCenter,
      );

  /// Returns a new background task about unselecting a product image.
  static BackgroundTaskUnselect _getNewTask(
    final String barcode,
    final ProductType productType,
    final ImageField imageField,
    final String uniqueId,
    final OpenFoodFactsLanguage language,
  ) =>
      BackgroundTaskUnselect._(
        uniqueId: uniqueId,
        barcode: barcode,
        productType: productType,
        language: language,
        processName: _operationType.processName,
        imageField: imageField.offTag,
        // same stamp as image upload
        stamp: BackgroundTaskUpload.getStamp(
          barcode,
          imageField.offTag,
          language.code,
        ),
      );

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {
    localDatabase.upToDate.addChange(uniqueId, getProductChange());
    _getTransientFile().removeImage(localDatabase);
  }

  TransientFile _getTransientFile() => TransientFile(
        ImageField.fromOffTag(imageField)!,
        barcode,
        getLanguage(),
      );

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    // TODO(monsieurtanuki): we should also remove the hypothetical transient file, shouldn't we?
    if (success) {
      await BackgroundTaskRefreshLater.addTask(
        barcode,
        localDatabase: localDatabase,
        productType: productType,
      );
    }
  }

  /// Unselects the product image.
  @override
  Future<void> upload() async => OpenFoodAPIClient.unselectProductImage(
        barcode: barcode,
        imageField: ImageField.fromOffTag(imageField)!,
        language: getLanguage(),
        user: getUser(),
        uriHelper: uriProductHelper,
      );

  /// Returns a product with "unselected" image.
  ///
  /// The problem is that `null` may mean both
  /// * "I don't change this value"
  /// * "I change the value to null"
  /// Here we put an empty string instead, to be understood as "force to null!".
  @override
  Product getProductChange() {
    final Product result = Product(barcode: barcode);
    ImageField.fromOffTag(imageField)!.setUrl(result, '');
    return result;
  }
}
