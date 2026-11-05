import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';

/// OCR Helper, to be implemented for ingredients and packaging for instance.
abstract class OcrHelper {
  String? getMonolingualText(Product product);

  void setMonolingualText(Product product, String text);

  Map<OpenFoodFactsLanguage, String>? getMultilingualTexts(
    Product product,
  );

  void setMultilingualTexts(
    Product product,
    Map<OpenFoodFactsLanguage, String> texts,
  );

  /// Returns the image url of this field for this [product].
  String? getImageUrl(Product product);

  /// Returns the error to display when the image upload + OCR failed.
  String getImageError(AppLocalizations appLocalizations);

  /// Returns the error when the server product refresh failed.
  ///
  /// E.g. no internet connection.
  String getError(AppLocalizations appLocalizations);

  /// Returns the "extract text" button label
  String getActionExtractText(AppLocalizations appLocalizations);

  /// Returns the "extract text" button label (short version)
  String getActionExtractShortText(AppLocalizations appLocalizations);

  /// Returns the "loading photo" button label
  String getActionLoadingPhoto(AppLocalizations appLocalizations);

  /// Returns the title of the dialog to explain the "loading photo" state
  String getActionLoadingPhotoDialogTitle(
    AppLocalizations appLocalizations,
  );

  /// Returns the content of the dialog to explain the "loading photo" state
  String getActionLoadingPhotoDialogBody(
    AppLocalizations appLocalizations,
  );

  /// Returns the "Extracting data…" button label
  String getActionExtractingData(AppLocalizations appLocalizations);

  /// Returns the "refresh photo" button label
  String getActionRefreshPhoto(AppLocalizations appLocalizations);

  /// Returns instructions about the text input.
  String getInstructions(AppLocalizations appLocalizations);

  /// Returns the page title.
  String getTitle(AppLocalizations appLocalizations);

  /// Returns the label of the corresponding "add" button.
  String getAddButtonLabel(AppLocalizations appLocalizations);

  /// Returns the image field we try to run OCR on.
  ImageField getImageField();

  /// Returns the type of the field (eg: ingredients).
  String getType(AppLocalizations appLocalizations);

  /// Eg: list of ingredients, packaging, etc.
  String getEditableContentTitle(AppLocalizations appLocalizations);

  /// Eg: Ingredients photo, packaging photo, etc.
  String getPhotoTitle(AppLocalizations appLocalizations);

  /// Returns the icon to be displayed in the edit page.
  WidgetBuilder getIcon();

  /// Returns if a given product has an owner field
  /// (= value provided by the producer).
  bool isOwnerField(
    Product product,
    OpenFoodFactsLanguage language,
  );

  /// Returns the text that the server OCR managed to extract from the image.
  Future<String?> getExtractedText(
    Product product,
    OpenFoodFactsLanguage language,
  );

  /// Stamp to identify similar updates on the same product.
  BackgroundTaskDetailsStamp getStamp();

  /// Returns true if we need to put an "add extra photos" button.
  bool hasAddExtraPhotoButton();

  @protected
  OpenFoodFactsLanguage getLanguage() => ProductQuery.getLanguage();

  @protected
  User getUser() => ProductQuery.getReadUser();

  /// Returns the enum to be used for matomo analytics.
  AnalyticsEditEvents getEditEventAnalyticsTag();
}
