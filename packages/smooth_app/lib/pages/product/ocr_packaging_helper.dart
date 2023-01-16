import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';

/// OCR Helper for packaging.
class OcrPackagingHelper extends OcrHelper {
  @override
  // ignore: deprecated_member_use
  String getText(final Product product) => product.packaging ?? '';

  @override
  Product getMinimalistProduct(Product product, final String text) {
    // ignore: deprecated_member_use
    product.packaging = text;
    return product;
  }

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
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_packaging_image;

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

  @override
  BackgroundTaskDetailsStamp getStamp() =>
      BackgroundTaskDetailsStamp.ocrPackaging;

  @override
  bool hasAddExtraPhotoButton() => true;
}
