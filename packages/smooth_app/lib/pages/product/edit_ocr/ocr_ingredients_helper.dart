import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// OCR Helper for ingredients.
class OcrIngredientsHelper extends OcrHelper {
  @override
  String? getMonolingualText(final Product product) => product.ingredientsText;

  @override
  void setMonolingualText(
    final Product product,
    final String text,
  ) =>
      product.ingredientsText = text;

  @override
  Map<OpenFoodFactsLanguage, String>? getMultilingualTexts(
    final Product product,
  ) =>
      product.ingredientsTextInLanguages;

  @override
  void setMultilingualTexts(
    final Product product,
    final Map<OpenFoodFactsLanguage, String> texts,
  ) =>
      product.ingredientsTextInLanguages = texts;

  @override
  String? getImageUrl(final Product product) => product.imageIngredientsUrl;

  @override
  String getImageError(final AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_image_error;

  @override
  String getError(final AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_error;

  @override
  String getActionExtractText(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_extract_ingredients_btn_text;

  @override
  String getActionExtractingData(AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_extracting_ingredients_btn_text;

  @override
  String getActionLoadingPhoto(AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_loading_photo_btn_text;

  @override
  String getActionLoadingPhotoDialogTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_loading_photo_help_dialog_title;

  @override
  String getActionLoadingPhotoDialogBody(AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_loading_photo_help_dialog_body;

  @override
  String getActionRefreshPhoto(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_refresh_photo_btn_text;

  @override
  String getInstructions(final AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_instructions;

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_ingredients;

  @override
  ImageField getImageField() => ImageField.INGREDIENTS;

  @override
  Future<String?> getExtractedText(
    final Product product,
    final OpenFoodFactsLanguage language,
  ) async {
    final OcrIngredientsResult result =
        await OpenFoodAPIClient.extractIngredients(
      getUser(),
      product.barcode!,
      language,
      uriHelper: ProductQuery.getUriProductHelper(
        productType: product.productType,
      ),
    );
    return result.ingredientsTextFromImage;
  }

  @override
  BackgroundTaskDetailsStamp getStamp() =>
      BackgroundTaskDetailsStamp.ocrIngredients;

  @override
  bool hasAddExtraPhotoButton() => false;

  @override
  AnalyticsEditEvents getEditEventAnalyticsTag() =>
      AnalyticsEditEvents.ingredients_and_Origins;
}
