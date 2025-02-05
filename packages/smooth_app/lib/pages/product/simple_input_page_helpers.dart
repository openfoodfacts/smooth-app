import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/country.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/preferences/country_selector/country_selector.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

/// Abstract helper for Simple Input Page.
///
/// * we retrieve the initial list of terms.
/// * we add a term to the list.
/// * we remove a term from the list.
abstract class AbstractSimpleInputPageHelper extends ChangeNotifier {
  /// Product we are about to edit.
  late Product product;

  /// Terms as they were initially then edited by the user.
  late List<String> _terms;

  /// "Have the terms been changed?"
  bool _changed = false;

  /// Starts from scratch with a new (or refreshed) [Product].
  void reInit(final Product product) {
    this.product = product;
    _terms = List<String>.from(initTerms(this.product));
    _changed = false;
    notifyListeners();
  }

  String get separator => ',';

  /// Is the list of terms reorderable?
  bool get reorderable => false;

  /// Are items editable?
  bool get editable => false;

  /// Returns the terms as they were initially in the product.
  ///
  /// WARNING: this list must be copied; if not you may alter the product.
  /// cf. https://github.com/openfoodfacts/smooth-app/issues/3529
  @protected
  List<String> initTerms(final Product product);

  /// Returns the current terms to be displayed.
  List<String> get terms => _terms;

  /// Returns true if the field is populated.
  bool isPopulated(final Product product) => initTerms(product).isNotEmpty;

  /// Returns true if the term was not in the list and then was added.
  bool addTerm(String term) {
    term = term.trim();
    if (term.isEmpty) {
      return false;
    }
    if (_terms.contains(term)) {
      return false;
    }
    _terms.add(term);
    _changed = true;
    notifyListeners();
    return true;
  }

  /// Returns true if the term was in the list and then was removed.
  ///
  /// The things we build the interface, very unlikely to return false,
  /// as we remove existing items.
  bool removeTerm(final String term) {
    if (_terms.remove(term)) {
      _changed = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Returns the title on the main "edit product" page.
  String getTitle(final AppLocalizations appLocalizations);

  /// Returns the subtitle on the main "edit product" page.
  String? getSubtitle(final AppLocalizations appLocalizations) => null;

  /// Returns the label of the corresponding "add" button.
  String getAddButtonLabel(final AppLocalizations appLocalizations);

  /// Returns the hint of the "add" text field.
  String getAddHint(final AppLocalizations appLocalizations);

  /// Returns the type of the text field (eg: label, category…).
  String getTypeLabel(final AppLocalizations appLocalizations);

  /// Returns the Tooltip for the "add" text field.
  String getAddTooltip(final AppLocalizations appLocalizations);

  /// Returns additional examples about the "add" text field.
  String? getAddExplanationsTitle(final AppLocalizations appLocalizations) =>
      null;

  /// Returns additional examples about the "add" text field.
  WidgetBuilder? getAddExplanationsContent() => null;

  /// Stamp to identify similar updates on the same product.
  BackgroundTaskDetailsStamp getStamp();

  /// Impacts a product in order to take the changes into account.
  @protected
  void changeProduct(final Product changedProduct);

  /// Allows to provide some suggestions to the user.
  ValueNotifier<SimpleInputSuggestionsState> getSuggestions() =>
      ValueNotifier<SimpleInputSuggestionsState>(
        const SimpleInputSuggestionsNoSuggestion(),
      );

  /// Returns the tag type for autocomplete suggestions.
  TagType? getTagType();

  /// Instead of the tag type, returns the autocomplete manager.
  AutocompleteManager? getAutocompleteManager() => null;

  /// Returns the icon data for the list tile.
  Widget getIcon();

  /// Extra widget to be displayed after the list.
  Widget? getExtraWidget(
    final BuildContext context,
    final Product product,
  ) =>
      null;

  /// Text capitalization for the text field.
  TextCapitalization? getTextCapitalization() => null;

  /// Allow emojis in the text field.
  bool getAllowEmojis() => false;

  /// Typical extra widget for the "add other pics" button.
  @protected
  Widget getExtraPhotoWidget(
    final BuildContext context,
    final Product product,
    final String title,
  ) =>
      Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 0,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: addPanelButton(
          title,
          onPressed: () async => confirmAndUploadNewPicture(
            context,
            imageField: ImageField.OTHER,
            barcode: product.barcode!,
            productType: product.productType,
            language: ProductQuery.getLanguage(),
            // we're already logged in if needed
            isLoggedInMandatory: false,
          ),
          leadingIcon: const Icon(Icons.add_a_photo),
          elevation: const WidgetStatePropertyAll<double>(0.0),
          padding: const EdgeInsetsDirectional.only(
            top: SMALL_SPACE,
            bottom: SMALL_SPACE,
            start: VERY_SMALL_SPACE,
          ),
        ),
      );

  /// Returns true if changes were made.
  bool getChangedProduct(final Product product) {
    if (!_changed) {
      return false;
    }
    changeProduct(product);
    return true;
  }

  @protected
  List<String> splitString(String? input) {
    if (input == null) {
      return <String>[];
    }
    input = input.trim();
    if (input.isEmpty) {
      return <String>[];
    }
    return input.split(separator.trim()).map((String e) => e.trim()).toList(
          growable: false,
        );
  }

  /// Returns the current language.
  @protected
  OpenFoodFactsLanguage getLanguage() => ProductQuery.getLanguage();

  List<String>? _itemsBeforeLastAddition;

  /// Adds all the non-already existing items from the controller.
  ///
  /// The item separator is the comma.
  bool addItemsFromController(
    final TextEditingController controller, {
    bool clearController = true,
  }) {
    try {
      _itemsBeforeLastAddition = List<String>.from(_terms);

      final List<String> input = controller.text.split(',');
      bool result = false;
      for (final String item in input) {
        if (addTerm(item.trim())) {
          result = true;
        }
      }
      if (result && clearController) {
        controller.text = '';
      }
      return result;
    } catch (_) {
      /// The field was not initialized
      return false;
    }
  }

  void restoreItemsBeforeLastAddition() {
    if (_itemsBeforeLastAddition == null) {
      return;
    }
    _terms = List<String>.from(_itemsBeforeLastAddition!);
    _changed = true;
    _itemsBeforeLastAddition = null;
    notifyListeners();
  }

  /// Mainly used when reordering the list.
  void replaceItems(final List<String> items) {
    _terms = List<String>.of(items);
    _changed = true;
    notifyListeners();
  }

  void replaceItem(int position, String term) {
    _terms[position] = term;
    _changed = true;
    notifyListeners();
  }

  /// Returns the enum to be used for matomo analytics.
  AnalyticsEditEvents getAnalyticsEditEvent();

  /// Returns true if the field is an owner field.
  bool isOwnerField(final Product product) => false;
}

sealed class SimpleInputSuggestionsState {
  const SimpleInputSuggestionsState();
}

class SimpleInputSuggestionsLoading extends SimpleInputSuggestionsState {
  const SimpleInputSuggestionsLoading();
}

class SimpleInputSuggestionsNoSuggestion extends SimpleInputSuggestionsState {
  const SimpleInputSuggestionsNoSuggestion();
}

class SimpleInputSuggestionsLoaded extends SimpleInputSuggestionsState {
  const SimpleInputSuggestionsLoaded({
    required this.suggestions,
  });

  final List<String> suggestions;
}

/// Implementation for "Brands" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageBrandsHelper extends AbstractSimpleInputPageHelper {
  @override
  String get separator => ', ';

  @override
  bool get reorderable => true;

  @override
  bool get editable => true;

  @override
  List<String> initTerms(final Product product) => splitString(product.brands);

  @override
  void changeProduct(final Product changedProduct) =>
      changedProduct.brands = MultilingualHelper.getCleanText(
        formatProductBrands(terms.join(separator)),
      );

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.brand_names;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_brands;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.add_basic_details_brand_names_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_brand;

  @override
  String? getAddExplanationsTitle(AppLocalizations appLocalizations) =>
      appLocalizations.add_basic_details_product_brand_help_title;

  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        return Column(
          children: <Widget>[
            ExplanationBodyInfo(
              text: appLocalizations.add_basic_details_product_brand_help_info1,
              icon: false,
            ),
            ExplanationTextContainer(
              title: appLocalizations
                  .add_basic_details_product_brand_help_info2_title,
              items: <ExplanationTextContainerContent>[
                ExplanationTextContainerContentText(
                  text: appLocalizations
                      .add_basic_details_product_brand_help_info2_content,
                ),
              ],
            ),
            ExplanationTextContainer(
              title: appLocalizations
                  .add_basic_details_product_brand_help_info3_title,
              items: <ExplanationTextContainerContent>[
                ExplanationTextContainerContentItem(
                  text: appLocalizations
                      .add_basic_details_product_brand_help_info3_item1_text,
                  example: appLocalizations
                      .add_basic_details_product_brand_help_info3_item1_explanation,
                ),
                ExplanationTextContainerContentItem(
                  text: appLocalizations
                      .add_basic_details_product_brand_help_info3_item2_text,
                  example: appLocalizations
                      .add_basic_details_product_brand_help_info3_item2_explanation,
                ),
              ],
            ),
            const SizedBox(height: MEDIUM_SPACE),
            ExplanationGoodExamplesContainer(
              items: <String>[
                appLocalizations
                    .add_basic_details_product_brand_help_good_examples_1,
                appLocalizations
                    .add_basic_details_product_brand_help_good_examples_2,
              ],
            ),
          ],
        );
      };

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.brand_name;

  @override
  TagType? getTagType() => null;

  @override
  AutocompleteManager? getAutocompleteManager() => AutocompleteManager(
        TaxonomyNameAutocompleter(
          taxonomyNames: <TaxonomyName>[TaxonomyName.brand],
          // for brands, language must be English
          language: OpenFoodFactsLanguage.ENGLISH,
          user: ProductQuery.getReadUser(),
          limit: 25,
          fuzziness: Fuzziness.none,
          uriHelper: ProductQuery.getUriProductHelper(
            productType: product.productType,
          ),
        ),
      );

  @override
  Widget getIcon() => const icons.Fruit();

  @override
  bool isOwnerField(Product product) =>
      product.getOwnerFieldTimestamp(
        OwnerField.productField(
          ProductField.BRANDS,
          ProductQuery.getLanguage(),
        ),
      ) !=
      null;

  @override
  BackgroundTaskDetailsStamp getStamp() =>
      BackgroundTaskDetailsStamp.basicDetails;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() =>
      AnalyticsEditEvents.basicDetails;
}

/// Implementation for "Stores" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageStoreHelper extends AbstractSimpleInputPageHelper {
  @override
  List<String> initTerms(final Product product) => splitString(product.stores);

  @override
  void changeProduct(final Product changedProduct) =>
      changedProduct.stores = terms.join(separator);

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_stores_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_stores;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_stores_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_store;

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_stores_type;

  @override
  String? getAddExplanationsTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_stores_explanation_title;

  @override
  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return Column(
          children: <Widget>[
            ExplanationBodyInfo(
              text: appLocalizations
                  .edit_product_form_item_stores_explanation_info1,
            ),
            ExplanationGoodExamplesContainer(
              items: <String>[
                appLocalizations
                    .edit_product_form_item_stores_explanation_good_examples_1,
                appLocalizations
                    .edit_product_form_item_stores_explanation_good_examples_2,
                appLocalizations
                    .edit_product_form_item_stores_explanation_good_examples_3,
              ],
            ),
          ],
        );
      };

  @override
  TagType? getTagType() => null;

  @override
  Widget getIcon() => const Icon(Icons.shopping_cart);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.stores;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() => AnalyticsEditEvents.stores;
}

/// Implementation for "Origins" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageOriginHelper extends AbstractSimpleInputPageHelper {
  @override
  List<String> initTerms(final Product product) => splitString(product.origins);

  @override
  void changeProduct(final Product changedProduct) =>
      changedProduct.origins = terms.join(separator);

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_origins_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_origins;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_origins_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_origin;

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_origins_type;

  @override
  String? getAddExplanationsTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_origins_explanation_title;

  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return Column(
          children: <Widget>[
            ExplanationBodyInfo(
              text: appLocalizations
                  .edit_product_form_item_origins_explanation_info1,
              icon: false,
            ),
            ExplanationGoodExamplesContainer(
              items: <String>[
                appLocalizations
                    .edit_product_form_item_origins_explanation_good_examples_1,
                appLocalizations
                    .edit_product_form_item_origins_explanation_good_examples_2,
              ],
            ),
          ],
        );
      };

  @override
  TagType? getTagType() => TagType.ORIGINS;

  @override
  Widget getIcon() => const Icon(Icons.travel_explore);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.origins;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() => AnalyticsEditEvents.origins;

  @override
  Widget? getExtraWidget(
    final BuildContext context,
    final Product product,
  ) =>
      getExtraPhotoWidget(
        context,
        product,
        AppLocalizations.of(context).add_origin_photo_button_label,
      );
}

/// Implementation for "Emb Code" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageEmbCodeHelper extends AbstractSimpleInputPageHelper {
  @override
  List<String> initTerms(final Product product) =>
      splitString(product.embCodes);

  @override
  void changeProduct(final Product changedProduct) =>
      changedProduct.embCodes = terms.join(separator);

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_emb_codes_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_emb;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_emb_codes_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_emb_code;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_emb_codes_type;

  @override
  String? getAddExplanationsTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_emb_help_title;

  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return Column(
          children: <Widget>[
            ExplanationBodyInfo(
              text: appLocalizations.edit_product_form_item_emb_help_info1,
              icon: false,
            ),
            ExplanationTextContainer(
              title:
                  appLocalizations.edit_product_form_item_emb_help_info2_title,
              items: <ExplanationTextContainerContent>[
                ExplanationTextContainerContentItem(
                  text: appLocalizations
                      .edit_product_form_item_emb_help_info2_item1_text,
                  example: appLocalizations
                      .edit_product_form_item_emb_help_info2_item1_explanation,
                  visualExamplePosition:
                      ExplanationVisualExamplePosition.afterTitle,
                  visualExample: Container(
                    width: 104.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            context.lightTheme() ? Colors.black : Colors.white,
                        width: 1.0,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(100, 50),
                      ),
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: VERY_SMALL_SPACE,
                    ),
                    child: Text(
                      appLocalizations
                          .edit_product_form_item_emb_help_info2_item1_example,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontSize: 12.0,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                ExplanationTextContainerContentItem(
                  text: appLocalizations
                      .edit_product_form_item_emb_help_info2_item2_text,
                  example: appLocalizations
                      .edit_product_form_item_emb_help_info2_item2_explanation,
                ),
              ],
            ),
          ],
        );
      };

  @override
  TagType? getTagType() => TagType.EMB_CODES;

  @override
  Widget getIcon() => const Icon(Icons.factory);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.embCodes;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() =>
      AnalyticsEditEvents.traceabilityCodes;

  @override
  Widget? getExtraWidget(
    final BuildContext context,
    final Product product,
  ) =>
      getExtraPhotoWidget(
        context,
        product,
        AppLocalizations.of(context).add_emb_photo_button_label,
      );

  @override
  TextCapitalization getTextCapitalization() => TextCapitalization.characters;
}

/// Implementation for "Labels" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageLabelHelper extends AbstractSimpleInputPageHelper {
  @override
  List<String> initTerms(final Product product) =>
      product.labelsTagsInLanguages?[getLanguage()] ?? <String>[];

  @override
  void changeProduct(final Product changedProduct) {
    // for the local change
    changedProduct.labelsTagsInLanguages =
        <OpenFoodFactsLanguage, List<String>>{getLanguage(): terms};
    // for the server - write-only
    changedProduct.labels = terms.join(separator);
  }

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_labels_title;

  @override
  String getSubtitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_labels_subtitle;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_labels;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_labels_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_label;

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_labels_type;

  @override
  String? getAddExplanationsTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_labels_explanation_title;

  @override
  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return Column(
          children: <Widget>[
            ExplanationBodyInfo(
              text: appLocalizations
                  .edit_product_form_item_labels_explanation_info1,
              icon: false,
            ),
            ExplanationGoodExamplesContainer(
              items: <String>[
                appLocalizations
                    .edit_product_form_item_labels_explanation_good_examples_1,
                appLocalizations
                    .edit_product_form_item_labels_explanation_good_examples_2,
                appLocalizations
                    .edit_product_form_item_labels_explanation_good_examples_3,
                appLocalizations
                    .edit_product_form_item_labels_explanation_good_examples_4,
                appLocalizations
                    .edit_product_form_item_labels_explanation_good_examples_5,
              ],
            ),
          ],
        );
      };

  @override
  TagType? getTagType() => TagType.LABELS;

  @override
  Widget getIcon() => const Icon(Icons.local_offer);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.labels;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() =>
      AnalyticsEditEvents.labelsAndCertifications;

  @override
  Widget? getExtraWidget(
    final BuildContext context,
    final Product product,
  ) =>
      getExtraPhotoWidget(
        context,
        product,
        AppLocalizations.of(context).add_label_photo_button_label,
      );
}

/// Implementation for "Categories" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageCategoryHelper extends AbstractSimpleInputPageHelper {
  @override
  bool isOwnerField(final Product product) =>
      product.getOwnerFieldTimestamp(
        OwnerField.productField(
          ProductField.CATEGORIES,
          ProductQuery.getLanguage(),
        ),
      ) !=
      null;

  @override
  List<String> initTerms(final Product product) =>
      product.categoriesTagsInLanguages?[getLanguage()] ?? <String>[];

  @override
  void changeProduct(final Product changedProduct) {
    // for the local change
    changedProduct.categoriesTagsInLanguages =
        <OpenFoodFactsLanguage, List<String>>{getLanguage(): terms};
    // for the server - write-only
    changedProduct.categories = terms.join(separator);
  }

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_categories_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_category;

  @override
  String? getAddExplanationsTitle(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_categories_explanation_title;

  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return Column(
          children: <Widget>[
            ExplanationBodyInfo(
              text: appLocalizations
                  .edit_product_form_item_categories_explanation_info1,
              icon: false,
            ),
            ExplanationTextContainer(
              title: appLocalizations
                  .edit_product_form_item_categories_explanation_info2_title,
              items: <ExplanationTextContainerContent>[
                ExplanationTextContainerContentText(
                  text: appLocalizations
                      .edit_product_form_item_categories_explanation_info2_content,
                ),
              ],
            ),
            ExplanationGoodExamplesContainer(
              items: <String>[
                appLocalizations
                    .edit_product_form_item_categories_explanation_good_examples_1,
                appLocalizations
                    .edit_product_form_item_categories_explanation_good_examples_2,
              ],
            ),
          ],
        );
      };

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_categories_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_category;

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_categories_type;

  @override
  TagType? getTagType() => TagType.CATEGORIES;

  @override
  Widget getIcon() => const Icon(Icons.restaurant);

  @override
  BackgroundTaskDetailsStamp getStamp() =>
      BackgroundTaskDetailsStamp.categories;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() => AnalyticsEditEvents.categories;
}

class SimpleInputPageCategoryNotFoodHelper
    extends SimpleInputPageCategoryHelper {
  @override
  Widget getIcon() => const Icon(Icons.edit);
}

/// Implementation for "Countries" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageCountryHelper extends AbstractSimpleInputPageHelper {
  SimpleInputPageCountryHelper(UserPreferences userPreferences)
      : _userCountryCode = userPreferences.userCountryCode ?? 'en' {
    CountriesHelper.getCountries(
      getLanguage().offTag,
    ).then((List<Country>? countries) {
      _countries = countries ?? <Country>[];
    });
  }

  final String _userCountryCode;

  ValueNotifier<SimpleInputSuggestionsState> _suggestionsNotifier =
      ValueNotifier<SimpleInputSuggestionsState>(
    const SimpleInputSuggestionsLoading(),
  );
  List<Country>? _countries;

  @override
  List<String> initTerms(final Product product) =>
      product.countriesTagsInLanguages?[getLanguage()] ?? <String>[];

  @override
  void reInit(Product product) {
    super.reInit(product);

    try {
      _suggestionsNotifier.notifyListeners();
    } catch (_) {
      // The Notifier was disposed
      _suggestionsNotifier = ValueNotifier<SimpleInputSuggestionsState>(
        const SimpleInputSuggestionsLoading(),
      );
    }

    _reloadSuggestions();
  }

  @override
  bool addItemsFromController(
    final TextEditingController controller, {
    bool clearController = true,
  }) {
    final bool result = super.addItemsFromController(
      controller,
      clearController: clearController,
    );
    if (result) {
      _reloadSuggestions();
    }
    return result;
  }

  @override
  void changeProduct(final Product changedProduct) {
    // for the temporary local change
    changedProduct.countriesTagsInLanguages =
        <OpenFoodFactsLanguage, List<String>>{getLanguage(): terms};
    // for the server - write-only
    changedProduct.countries = terms.join(separator);
  }

  @override
  ValueNotifier<SimpleInputSuggestionsState> getSuggestions() =>
      _suggestionsNotifier;

  Future<void> _reloadSuggestions() async {
    _countries ??= await CountriesHelper.getCountries(
      getLanguage().offTag,
    );
    if (_countries == null) {
      _suggestionsNotifier.value = const SimpleInputSuggestionsNoSuggestion();
      return;
    }

    final Country? country = _countries!.firstWhereOrNull(
      (Country country) => country.countryCode == _userCountryCode,
    );

    if (country == null || _terms.contains(country.name) == true) {
      _suggestionsNotifier.value = const SimpleInputSuggestionsLoaded(
        suggestions: <String>[],
      );
      return;
    }

    _suggestionsNotifier.value = SimpleInputSuggestionsLoaded(
      suggestions: <String>[country.name],
    );
  }

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_countries;

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_hint;

  @override
  String getAddTooltip(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_add_action_country;

  @override
  TextCapitalization? getTextCapitalization() => TextCapitalization.sentences;

  @override
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_explanations_title;

  @override
  @override
  WidgetBuilder? getAddExplanationsContent() => (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        return ExplanationBodyInfo(
          text: appLocalizations
              .edit_product_form_item_countries_explanations_info1,
          safeArea: true,
        );
      };

  @override
  TagType? getTagType() => TagType.COUNTRIES;

  @override
  Widget getIcon() => const icons.Countries(size: 20.0);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.countries;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() => AnalyticsEditEvents.country;

  @override
  void dispose() {
    try {
      _suggestionsNotifier.dispose();
    } catch (_) {
      // The Notifier was already disposed
    }
    super.dispose();
  }
}
