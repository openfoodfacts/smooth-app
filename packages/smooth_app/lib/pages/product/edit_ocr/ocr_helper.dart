import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// OCR Helper, to be implemented for ingredients and packaging for instance.
abstract class OcrHelper {
  String? getMonolingualText(
    final Product product,
  );

  void setMonolingualText(
    final Product product,
    final String text,
  );

  Map<OpenFoodFactsLanguage, String>? getMultilingualTexts(
    final Product product,
  );

  void setMultilingualTexts(
    final Product product,
    final Map<OpenFoodFactsLanguage, String> texts,
  );

  /// Returns the image url of this field for this [product].
  String? getImageUrl(final Product product);

  /// Returns the error to display when the image upload + OCR failed.
  String getImageError(final AppLocalizations appLocalizations);

  /// Returns the error when the server product refresh failed.
  ///
  /// E.g. no internet connection.
  String getError(final AppLocalizations appLocalizations);

  /// Returns the "extract text" button label
  String getActionExtractText(final AppLocalizations appLocalizations);

  /// Returns the "loading photo" button label
  String getActionLoadingPhoto(final AppLocalizations appLocalizations);

  /// Returns the "Extracting data…" button label
  String getActionExtractingData(final AppLocalizations appLocalizations);

  /// Returns the "refresh photo" button label
  String getActionRefreshPhoto(final AppLocalizations appLocalizations);

  /// Returns instructions about the text input.
  String getInstructions(final AppLocalizations appLocalizations);

  /// Returns the page title.
  String getTitle(final AppLocalizations appLocalizations);

  /// Returns the label of the corresponding "add" button.
  String getAddButtonLabel(final AppLocalizations appLocalizations);

  /// Returns the image field we try to run OCR on.
  ImageField getImageField();

  /// Returns the text that the server OCR managed to extract from the image.
  Future<String?> getExtractedText(
    final Product product,
    final OpenFoodFactsLanguage language,
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
