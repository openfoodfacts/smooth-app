import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';

/// OCR Helper for ingredients.
class OcrIngredientsHelper extends OcrHelper {
  @override
  String getText(final Product product) => product.ingredientsText ?? '';

  @override
  Product getMinimalistProduct(final Product product, final String text) {
    product.ingredientsText = text;
    return product;
  }

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
      appLocalizations.edit_ingredients_extrait_ingredients_btn_text;

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
  Future<String?> getExtractedText(final Product product) async {
    final OcrIngredientsResult result =
        await OpenFoodAPIClient.extractIngredients(
      getUser(),
      product.barcode!,
      getLanguage(),
    );
    return result.ingredientsTextFromImage;
  }

  @override
  BackgroundTaskDetailsStamp getStamp() =>
      BackgroundTaskDetailsStamp.ocrIngredients;

  @override
  bool hasAddExtraPhotoButton() => false;
}
