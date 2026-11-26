import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// OCR Helper for ingredients.
class OcrIngredientsHelper extends OcrHelper {
  @override
  String? getMonolingualText(Product product) => product.ingredientsText;

  @override
  void setMonolingualText(Product product, String text) =>
      product.ingredientsText = text;

  @override
  Map<OpenFoodFactsLanguage, String>? getMultilingualTexts(
    Product product,
  ) => product.ingredientsTextInLanguages;

  @override
  void setMultilingualTexts(
    Product product,
    Map<OpenFoodFactsLanguage, String> texts,
  ) => product.ingredientsTextInLanguages = texts;

  @override
  String? getImageUrl(Product product) => product.imageIngredientsUrl;

  @override
  String getImageError(AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_image_error;

  @override
  String getError(AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_error;

  @override
  String getActionExtractText(AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_extract_ingredients_btn_text;

  @override
  String getActionExtractShortText(AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_extract_ingredients_btn_text_short;

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
  String getActionRefreshPhoto(AppLocalizations appLocalizations) =>
      appLocalizations.edit_ingredients_refresh_photo_btn_text;

  @override
  String getInstructions(AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_instructions;

  @override
  String getTitle(AppLocalizations appLocalizations) =>
      appLocalizations.ingredients_editing_title;

  @override
  String getType(AppLocalizations appLocalizations) =>
      appLocalizations.ingredients;

  @override
  String getEditableContentTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_ingredients_list_title;

  @override
  String getPhotoTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_ingredients_photo_title;

  @override
  String getAddButtonLabel(AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_ingredients;

  @override
  ImageField getImageField() => ImageField.INGREDIENTS;

  @override
  bool isOwnerField(
    Product product,
    OpenFoodFactsLanguage language,
  ) =>
      product.ownerFields?.containsKey('ingredients_text_${language.offTag}') ??
      false;

  @override
  Future<String?> getExtractedText(
    Product product,
    OpenFoodFactsLanguage language,
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

  @override
  WidgetBuilder getIcon() {
    return (BuildContext context) => const icons.Ingredients();
  }
}
