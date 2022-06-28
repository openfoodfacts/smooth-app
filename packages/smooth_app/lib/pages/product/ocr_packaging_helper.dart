import 'dart:async';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OcrField.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:openfoodfacts/utils/UriHelper.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';
import 'package:smooth_app/pages/product/tmp_ocr_packaging_result.dart';

/// OCR Helper for packaging.
class OcrPackagingHelper extends OcrHelper {
  @override
  String getText(final Product product) => product.packaging ?? '';

  @override
  Product getMinimalistProduct(final Product product, final String text) =>
      Product(
        barcode: product.barcode,
        packaging: text,
      );

  @override
  String? getImageUrl(final Product product) => product.imagePackagingUrl;

  @override
  String getImageError(final AppLocalizations appLocalizations) =>
      appLocalizations.packaging_editing_image_error;

  @override
  String getError(final AppLocalizations appLocalizations) =>
      appLocalizations.packaging_editing_error;

  @override
  String getActionExtractText(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_extract_btn_text;

  @override
  String getActionRefreshPhoto(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_refresh_photo_btn_text;

  @override
  String getInstructions(final AppLocalizations appLocalizations) =>
      appLocalizations.packaging_editing_instructions;

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.packaging_editing_title;

  @override
  ImageField getImageField() => ImageField.PACKAGING;

  @override
  Future<String?> getExtractedText(final Product product) async {
    final OcrPackagingResult result = await extractPackaging(
      getUser(),
      product.barcode!,
      getLanguage(),
    );
    return result.textFromImage;
  }

  // TODO(monsieurtanuki): move to off-dart
  static Future<OcrPackagingResult> extractPackaging(
    User user,
    String barcode,
    OpenFoodFactsLanguage language, {
    QueryType? queryType,
  }) async {
    final Uri uri = UriHelper.getPostUri(
      path: '/cgi/packaging.pl',
      queryType: queryType,
    );
    final Map<String, String> queryParameters = <String, String>{
      'code': barcode,
      'process_image': '1',
      'id': 'packaging_${language.code}',
      'ocr_engine': OcrField.GOOGLE_CLOUD_VISION.key
    };
    final Response response = await HttpHelper().doPostRequest(
      uri,
      queryParameters,
      user,
      queryType: queryType,
    );
    return OcrPackagingResult.fromJson(
      json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }
}
