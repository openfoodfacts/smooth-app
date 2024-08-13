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
import 'package:smooth_app/query/product_query.dart';

// TODO(monsieurtanuki): use transient file, in order to have instant access to proof image?
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
    required this.barcodes,
    required this.pricesAreDiscounted,
    required this.prices,
    required this.pricesWithoutDiscount,
  });

  BackgroundTaskAddPrice.fromJson(Map<String, dynamic> json)
      : fullPath = json[_jsonTagImagePath] as String,
        rotationDegrees = json[_jsonTagRotation] as int? ?? 0,
        cropX1 = json[_jsonTagX1] as int? ?? 0,
        cropY1 = json[_jsonTagY1] as int? ?? 0,
        cropX2 = json[_jsonTagX2] as int? ?? 0,
        cropY2 = json[_jsonTagY2] as int? ?? 0,
        proofType = ProofType.fromOffTag(json[_jsonTagProofType] as String)!,
        date = JsonHelper.stringTimestampToDate(json[_jsonTagDate] as String),
        currency = Currency.fromName(json[_jsonTagCurrency] as String)!,
        locationOSMId = json[_jsonTagOSMId] as int,
        locationOSMType =
            LocationOSMType.fromOffTag(json[_jsonTagOSMType] as String)!,
        eraserCoordinates =
            _fromJsonListDouble(json[_jsonTagEraserCoordinates]),
        barcodes = json.containsKey(_jsonTagBarcode)
            ? <String>[json[_jsonTagBarcode] as String]
            : _fromJsonListString(json[_jsonTagBarcodes])!,
        pricesAreDiscounted = json.containsKey(_jsonTagIsDiscounted)
            ? <bool>[json[_jsonTagIsDiscounted] as bool]
            : _fromJsonListBool(json[_jsonTagAreDiscounted])!,
        prices = json.containsKey(_jsonTagPrice)
            ? <double>[json[_jsonTagPrice] as double]
            : _fromJsonListDouble(json[_jsonTagPrices])!,
        pricesWithoutDiscount = json.containsKey(_jsonTagPriceWithoutDiscount)
            ? <double?>[json[_jsonTagPriceWithoutDiscount] as double?]
            : _fromJsonListNullableDouble(json[_jsonTagPricesWithoutDiscount])!,
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

  static List<double?>? _fromJsonListNullableDouble(
    final List<dynamic>? input,
  ) {
    if (input == null) {
      return null;
    }
    final List<double?> result = <double?>[];
    for (final dynamic item in input) {
      result.add(item as double?);
    }
    return result;
  }

  static List<String>? _fromJsonListString(final List<dynamic>? input) {
    if (input == null) {
      return null;
    }
    final List<String> result = <String>[];
    for (final dynamic item in input) {
      result.add(item as String);
    }
    return result;
  }

  static List<bool>? _fromJsonListBool(final List<dynamic>? input) {
    if (input == null) {
      return null;
    }
    final List<bool> result = <bool>[];
    for (final dynamic item in input) {
      result.add(item as bool);
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
  static const String _jsonTagBarcodes = 'barcodes';
  static const String _jsonTagAreDiscounted = 'areDiscounted';
  static const String _jsonTagPrices = 'prices';
  static const String _jsonTagPricesWithoutDiscount = 'pricesWithoutDiscount';
  @Deprecated('Use [_jsonTagBarcodes] instead')
  static const String _jsonTagBarcode = 'barcode';
  @Deprecated('Use [_jsonTagAreDiscounted] instead')
  static const String _jsonTagIsDiscounted = 'isDiscounted';
  @Deprecated('Use [_jsonTagPrices] instead')
  static const String _jsonTagPrice = 'price';
  @Deprecated('Use [_jsonTagPricesWithoutDiscount] instead')
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
  // per line
  final List<String> barcodes;
  final List<bool> pricesAreDiscounted;
  final List<double> prices;
  final List<double?> pricesWithoutDiscount;

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
    result[_jsonTagBarcodes] = barcodes;
    result[_jsonTagAreDiscounted] = pricesAreDiscounted;
    result[_jsonTagPrices] = prices;
    result[_jsonTagPricesWithoutDiscount] = pricesWithoutDiscount;
    return result;
  }

  /// Adds the background task about uploading a product image.
  static Future<void> addTask({
    required final BuildContext context,
    required final CropParameters cropObject,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final List<String> barcodes,
    required final List<bool> pricesAreDiscounted,
    required final List<double> prices,
    required final List<double?> pricesWithoutDiscount,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(localDatabase);
    final BackgroundTask task = _getNewTask(
      uniqueId: uniqueId,
      cropObject: cropObject,
      proofType: proofType,
      date: date,
      currency: currency,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
      barcodes: barcodes,
      pricesAreDiscounted: pricesAreDiscounted,
      prices: prices,
      pricesWithoutDiscount: pricesWithoutDiscount,
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
    required final String uniqueId,
    required final CropParameters cropObject,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final List<String> barcodes,
    required final List<bool> pricesAreDiscounted,
    required final List<double> prices,
    required final List<double?> pricesWithoutDiscount,
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
        barcodes: barcodes,
        pricesAreDiscounted: pricesAreDiscounted,
        prices: prices,
        pricesWithoutDiscount: pricesWithoutDiscount,
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
      uriHelper: ProductQuery.uriPricesHelper,
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
      date: date,
      currency: currency,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
      imageUri: initialImageUri,
      mediaType: initialMediaType,
      bearerToken: bearerToken,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    if (uploadProof.isError) {
      throw Exception('Could not upload proof: ${uploadProof.error}');
    }

    for (int i = 0; i < barcodes.length; i++) {
      final Price newPrice = Price()
        ..date = date
        ..currency = currency
        ..locationOSMId = locationOSMId
        ..locationOSMType = locationOSMType
        ..proofId = uploadProof.value.id
        ..priceIsDiscounted = pricesAreDiscounted[i]
        ..price = prices[i]
        ..priceWithoutDiscount = pricesWithoutDiscount[i]
        ..productCode = barcodes[i];

      // create price
      final MaybeError<Price> addedPrice =
          await OpenPricesAPIClient.createPrice(
        price: newPrice,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriPricesHelper,
      );
      if (addedPrice.isError) {
        throw Exception('Could not add price: ${addedPrice.error}');
      }
    }

    // close session
    final MaybeError<bool> closedSession =
        await OpenPricesAPIClient.deleteUserSession(
      uriHelper: ProductQuery.uriPricesHelper,
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

  @override
  bool isDeduplicable() => false;
}
