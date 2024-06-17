import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// OCR Helper for packaging.
class OcrPackagingHelper extends OcrHelper {
  @override
  // ignore: deprecated_member_use
  String? getMonolingualText(final Product product) => product.packaging;

  @override
  void setMonolingualText(
    final Product product,
    final String text,
  ) =>
      // ignore: deprecated_member_use
      product.packaging = text;

  @override
  Map<OpenFoodFactsLanguage, String>? getMultilingualTexts(
          final Product product) =>
      product.packagingTextInLanguages;

  @override
  void setMultilingualTexts(
    final Product product,
    final Map<OpenFoodFactsLanguage, String> texts,
  ) =>
      product.packagingTextInLanguages = texts;

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
  String getActionExtractingData(AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_extracting_btn_text;

  @override
  String getActionLoadingPhoto(AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_loading_photo_btn_text;

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
  Future<String?> getExtractedText(
    final Product product,
    final OpenFoodFactsLanguage language,
  ) async {
    final OcrPackagingResult result = await OpenFoodAPIClient.extractPackaging(
      getUser(),
      product.barcode!,
      language,
      uriHelper: ProductQuery.uriProductHelper,
    );
    return result.textFromImage;
  }

  @override
  BackgroundTaskDetailsStamp getStamp() =>
      BackgroundTaskDetailsStamp.ocrPackaging;

  @override
  bool hasAddExtraPhotoButton() => true;

  @override
  AnalyticsEditEvents getEditEventAnalyticsTag() =>
      AnalyticsEditEvents.recyclingInstructionsPhotos;
}
