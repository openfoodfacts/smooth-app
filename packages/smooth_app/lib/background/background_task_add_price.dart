import 'dart:async';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http_parser/http_parser.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/prices/eraser_model.dart';
import 'package:smooth_app/pages/prices/eraser_painter.dart';

// TODO(monsieurtanuki): use transient file, in order to have instant access to proof image?
// TODO(monsieurtanuki): add source
// TODO(monsieurtanuki): make it work for several products
/// Background task about adding a product price.
class BackgroundTaskAddPrice extends BackgroundTask {
  BackgroundTaskAddPrice._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    // single
    required this.fullPath,
    required this.rotationDegrees,
    required this.cropX1,
    required this.cropY1,
    required this.cropX2,
    required this.cropY2,
    required this.proofType,
    required this.date,
    required this.currency,
    required this.locationOSMId,
    required this.locationOSMType,
    // lines
    required this.eraserCoordinates,
    // multi
    required this.barcode,
    required this.priceIsDiscounted,
    required this.price,
    required this.priceWithoutDiscount,
  });

  BackgroundTaskAddPrice.fromJson(Map<String, dynamic> json)
      : fullPath = json[_jsonTagImagePath] as String,
        rotationDegrees = json[_jsonTagRotation] as int? ?? 0,
        cropX1 = json[_jsonTagX1] as int? ?? 0,
        cropY1 = json[_jsonTagY1] as int? ?? 0,
        cropX2 = json[_jsonTagX2] as int? ?? 0,
        cropY2 = json[_jsonTagY2] as int? ?? 0,
        proofType = getProofTypeFromOffTag(json[_jsonTagProofType] as String)!,
        date = JsonHelper.stringTimestampToDate(json[_jsonTagDate] as String),
        currency = getCurrencyFromName(json[_jsonTagCurrency] as String)!,
        locationOSMId = json[_jsonTagOSMId] as int,
        locationOSMType =
            LocationOSMType.fromOffTag(json[_jsonTagOSMType] as String)!,
        eraserCoordinates =
            _fromJsonListDouble(json[_jsonTagEraserCoordinates]),
        barcode = json[_jsonTagBarcode] as String,
        priceIsDiscounted = json[_jsonTagIsDiscounted] as bool,
        price = json[_jsonTagPrice] as double,
        priceWithoutDiscount = json[_jsonTagPriceWithoutDiscount] as double?,
        super.fromJson(json);

  static List<double>? _fromJsonListDouble(final List<dynamic>? input) {
    if (input == null) {
      return null;
    }
    final List<double> result = <double>[];
    for (final dynamic item in input) {
      result.add(item as double);
    }
    return result;
  }

  static const String _jsonTagImagePath = 'imagePath';
  static const String _jsonTagRotation = 'rotation';
  static const String _jsonTagX1 = 'x1';
  static const String _jsonTagY1 = 'y1';
  static const String _jsonTagX2 = 'x2';
  static const String _jsonTagY2 = 'y2';
  static const String _jsonTagProofType = 'proofType';
  static const String _jsonTagDate = 'date';
  static const String _jsonTagEraserCoordinates = 'eraserCoordinates';
  static const String _jsonTagCurrency = 'currency';
  static const String _jsonTagOSMId = 'osmId';
  static const String _jsonTagOSMType = 'osmType';
  static const String _jsonTagBarcode = 'barcode';
  static const String _jsonTagIsDiscounted = 'isDiscounted';
  static const String _jsonTagPrice = 'price';
  static const String _jsonTagPriceWithoutDiscount = 'priceWithoutDiscount';

  static const OperationType _operationType = OperationType.addPrice;

  final String fullPath;
  final int rotationDegrees;
  final int cropX1;
  final int cropY1;
  final int cropX2;
  final int cropY2;
  final ProofType proofType;
  final DateTime date;
  final Currency currency;
  final int locationOSMId;
  final LocationOSMType locationOSMType;
  final List<double>? eraserCoordinates;
  final String barcode;
  final bool priceIsDiscounted;
  final double price;
  final double? priceWithoutDiscount;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImagePath] = fullPath;
    result[_jsonTagRotation] = rotationDegrees;
    result[_jsonTagX1] = cropX1;
    result[_jsonTagY1] = cropY1;
    result[_jsonTagX2] = cropX2;
    result[_jsonTagY2] = cropY2;
    result[_jsonTagProofType] = proofType.offTag;
    result[_jsonTagDate] = date.toIso8601String();
    result[_jsonTagCurrency] = currency.name;
    result[_jsonTagOSMId] = locationOSMId;
    result[_jsonTagOSMType] = locationOSMType.offTag;
    result[_jsonTagEraserCoordinates] = eraserCoordinates;
    result[_jsonTagBarcode] = barcode;
    result[_jsonTagIsDiscounted] = priceIsDiscounted;
    result[_jsonTagPrice] = price;
    result[_jsonTagPriceWithoutDiscount] = priceWithoutDiscount;
    return result;
  }

  /// Adds the background task about uploading a product image.
  static Future<void> addTask({
    required final CropParameters cropObject,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final String barcode,
    required final bool priceIsDiscounted,
    required final double price,
    required final double? priceWithoutDiscount,
    required final BuildContext context,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(localDatabase);
    final BackgroundTask task = _getNewTask(
      cropObject: cropObject,
      proofType: proofType,
      date: date,
      currency: currency,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
      barcode: barcode,
      priceIsDiscounted: priceIsDiscounted,
      price: price,
      priceWithoutDiscount: priceWithoutDiscount,
      uniqueId: uniqueId,
    );
    if (!context.mounted) {
      return;
    }
    await task.addToManager(localDatabase, context: context);
  }

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
          final AppLocalizations appLocalizations) =>
      (
        appLocalizations.add_price_queued,
        AlignmentDirectional.center,
      );

  /// Returns a new background task about changing a product.
  static BackgroundTaskAddPrice _getNewTask({
    required final CropParameters cropObject,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final String barcode,
    required final bool priceIsDiscounted,
    required final double price,
    required final double? priceWithoutDiscount,
    required final String uniqueId,
  }) =>
      BackgroundTaskAddPrice._(
        uniqueId: uniqueId,
        processName: _operationType.processName,
        fullPath: cropObject.fullFile!.path,
        rotationDegrees: cropObject.rotation,
        cropX1: cropObject.x1,
        cropY1: cropObject.y1,
        cropX2: cropObject.x2,
        cropY2: cropObject.y2,
        proofType: proofType,
        date: date,
        currency: currency,
        locationOSMId: locationOSMId,
        locationOSMType: locationOSMType,
        eraserCoordinates: cropObject.eraserCoordinates,
        barcode: barcode,
        priceIsDiscounted: priceIsDiscounted,
        price: price,
        priceWithoutDiscount: priceWithoutDiscount,
        stamp: _getStamp(
          date: date,
          locationOSMId: locationOSMId,
          locationOSMType: locationOSMType,
        ),
      );

  static String _getStamp({
    required final DateTime date,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
  }) =>
      'no_barcode;price;$date;$locationOSMId;$locationOSMType';

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    try {
      (await BackgroundTaskUpload.getFile(fullPath)).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    try {
      (await BackgroundTaskUpload.getFile(
              BackgroundTaskImage.getCroppedPath(fullPath)))
          .deleteSync();
    } catch (e) {
      // possible, but let's not spoil the task for that either.
    }
  }

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final Price newPrice = Price()
      ..date = date
      ..currency = currency
      ..locationOSMId = locationOSMId
      ..locationOSMType = locationOSMType
      ..priceIsDiscounted = priceIsDiscounted
      ..price = price
      ..priceWithoutDiscount = priceWithoutDiscount
      ..productCode = barcode;

    final List<Offset> offsets = <Offset>[];
    if (eraserCoordinates != null) {
      for (int i = 0; i < eraserCoordinates!.length; i += 2) {
        final Offset offset = Offset(
          eraserCoordinates![i],
          eraserCoordinates![i + 1],
        );
        offsets.add(offset);
      }
    }
    final String? path = await BackgroundTaskImage.cropIfNeeded(
      fullPath: fullPath,
      croppedPath: BackgroundTaskImage.getCroppedPath(fullPath),
      rotationDegrees: rotationDegrees,
      cropX1: cropX1,
      cropY1: cropY1,
      cropX2: cropX2,
      cropY2: cropY2,
      overlayPainter: offsets.isEmpty
          ? null
          : EraserPainter(
              eraserModel: EraserModel(
                rotation: CropRotationExtension.fromDegrees(rotationDegrees)!,
                offsets: offsets,
              ),
              cropRect: BackgroundTaskImage.getDownsizedRect(
                cropX1,
                cropY1,
                cropX2,
                cropY2,
              ),
            ),
    );
    if (path == null) {
      // TODO(monsieurtanuki): maybe something more refined when we dismiss the picture, like alerting the user, though it's not supposed to happen anymore from upstream.
      return;
    }

    // authentication
    final User user = getUser();
    final MaybeError<String> token =
        await OpenPricesAPIClient.getAuthenticationToken(
      username: user.userId,
      password: user.password,
      uriHelper: uriProductHelper,
    );
    if (token.isError) {
      throw Exception('Could not get token: ${token.error}');
    }
    if (token.value.isEmpty) {
      throw Exception('Unexpected empty token');
    }
    final String bearerToken = token.value;

    // proof upload
    final Uri initialImageUri = Uri.parse(path);
    final MediaType initialMediaType =
        HttpHelper().imagineMediaType(initialImageUri.path)!;
    final MaybeError<Proof> uploadProof = await OpenPricesAPIClient.uploadProof(
      proofType: proofType,
      imageUri: initialImageUri,
      mediaType: initialMediaType,
      bearerToken: bearerToken,
      uriHelper: uriProductHelper,
    );
    if (uploadProof.isError) {
      throw Exception('Could not upload proof: ${uploadProof.error}');
    }
    newPrice.proofId = uploadProof.value.id;

    // create price
    final MaybeError<Price> addedPrice = await OpenPricesAPIClient.createPrice(
      price: newPrice,
      bearerToken: bearerToken,
      uriHelper: uriProductHelper,
    );
    if (addedPrice.isError) {
      throw Exception('Could not add price: ${addedPrice.error}');
    }

    // close session
    final MaybeError<bool> closedSession =
        await OpenPricesAPIClient.deleteUserSession(
      uriHelper: uriProductHelper,
      bearerToken: bearerToken,
    );
    if (closedSession.isError) {
      // TODO(monsieurtanuki): do we really care?
      // throw Exception('Could not close session: ${closedSession.error}');
      return;
    }
    if (!closedSession.value) {
      // TODO(monsieurtanuki): do we really care?
      // throw Exception('Could not really close session');
      return;
    }
  }

  // TODO(monsieurtanuki): move it to off-dart
  static Currency? getCurrencyFromName(final String name) {
    for (final Currency currency in Currency.values) {
      if (currency.name == name) {
        return currency;
      }
    }
    return null;
  }

  // TODO(monsieurtanuki): move it to off-dart
  static ProofType? getProofTypeFromOffTag(final String offTag) {
    for (final ProofType value in ProofType.values) {
      if (value.offTag == offTag) {
        return value;
      }
    }
    return null;
  }

  @override
  bool isDeduplicable() => false;
}
