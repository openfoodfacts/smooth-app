import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

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
  String getActionExtractShortText(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_extract_btn_text_short;

  @override
  String getActionExtractingData(AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_extracting_btn_text;

  @override
  String getActionLoadingPhoto(AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_loading_photo_btn_text;

  @override
  String getActionLoadingPhotoDialogTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_loading_photo_help_dialog_title;

  @override
  String getActionLoadingPhotoDialogBody(AppLocalizations appLocalizations) =>
      appLocalizations.edit_packaging_loading_photo_help_dialog_body;

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
  String getEditableContentTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_packaging_list_title;

  @override
  String getPhotoTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_packaging_photo_title;

  @override
  String getType(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_packagings_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_packaging_image;

  /// Not supported yet
  @override
  bool isOwnerField(Product product, OpenFoodFactsLanguage language) => false;

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
      uriHelper: ProductQuery.getUriProductHelper(
        productType: product.productType,
      ),
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

  @override
  WidgetBuilder getIcon() {
    return (BuildContext context) => const icons.Packaging();
  }
}
