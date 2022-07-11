import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/OcrPackagingResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';

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
    final OcrPackagingResult result = await OpenFoodAPIClient.extractPackaging(
      getUser(),
      product.barcode!,
      getLanguage(),
    );
    return result.textFromImage;
  }
}
