import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

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

  final String _separator = ',';

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

  /// Returns additional examples about the "add" text field.
  String? getAddExplanations(final AppLocalizations appLocalizations) => null;

  /// Stamp to identify similar updates on the same product.
  BackgroundTaskDetailsStamp getStamp();

  /// Impacts a product in order to take the changes into account.
  @protected
  void changeProduct(final Product changedProduct);

  /// Returns the tag type for autocomplete suggestions.
  TagType? getTagType();

  /// Returns the icon data for the list tile.
  Widget getIcon();

  /// Extra widget to be displayed after the list.
  Widget? getExtraWidget(
    final BuildContext context,
    final Product product,
  ) =>
      null;

  /// Typical extra widget for the "add other pics" button.
  @protected
  Widget getExtraPhotoWidget(
    final BuildContext context,
    final Product product,
    final String title,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SMALL_SPACE,
          horizontal: SMALL_SPACE,
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
          iconData: Icons.add_a_photo,
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
    return input.split(_separator);
  }

  /// Returns the current language.
  @protected
  OpenFoodFactsLanguage getLanguage() => ProductQuery.getLanguage();

  /// Adds all the non-already existing items from the controller.
  ///
  /// The item separator is the comma.
  bool addItemsFromController(final TextEditingController controller) {
    final List<String> input = controller.text.split(',');
    bool result = false;
    for (final String item in input) {
      if (addTerm(item.trim())) {
        result = true;
      }
    }
    if (result) {
      controller.text = '';
    }
    return result;
  }

  /// Returns the enum to be used for matomo analytics.
  AnalyticsEditEvents getAnalyticsEditEvent();

  /// Returns true if the field is an owner field.
  bool isOwnerField(final Product product) => false;
}

/// Implementation for "Stores" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageStoreHelper extends AbstractSimpleInputPageHelper {
  @override
  List<String> initTerms(final Product product) => splitString(product.stores);

  @override
  void changeProduct(final Product changedProduct) =>
      changedProduct.stores = terms.join(_separator);

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
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_stores_type;

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
      changedProduct.origins = terms.join(_separator);

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
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_origins_type;

  @override
  String? getAddExplanations(final AppLocalizations appLocalizations) =>
      '${appLocalizations.edit_product_form_item_origins_explainer_1}'
      '\n'
      '${appLocalizations.edit_product_form_item_origins_explainer_2}';

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
      changedProduct.embCodes = terms.join(_separator);

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
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_emb_codes_type;

  @override
  String getAddExplanations(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_emb_codes_explanations;

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
    changedProduct.labels = terms.join(_separator);
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
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_labels_type;

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
    changedProduct.categories = terms.join(_separator);
  }

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_categories_title;

  @override
  String getAddButtonLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.score_add_missing_product_category;

  @override
  String? getAddExplanations(final AppLocalizations appLocalizations) =>
      '${appLocalizations.edit_product_form_item_categories_explainer_1}'
      '\n'
      '${appLocalizations.edit_product_form_item_categories_explainer_2}'
      '\n'
      '${appLocalizations.edit_product_form_item_categories_explainer_3}';

  @override
  String getAddHint(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_categories_hint;

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
  @override
  List<String> initTerms(final Product product) =>
      product.countriesTagsInLanguages?[getLanguage()] ?? <String>[];

  @override
  void changeProduct(final Product changedProduct) {
    // for the temporary local change
    changedProduct.countriesTagsInLanguages =
        <OpenFoodFactsLanguage, List<String>>{getLanguage(): terms};
    // for the server - write-only
    changedProduct.countries = terms.join(_separator);
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
  String getTypeLabel(AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_type;

  @override
  String getAddExplanations(final AppLocalizations appLocalizations) =>
      appLocalizations.edit_product_form_item_countries_explanations;

  @override
  TagType? getTagType() => TagType.COUNTRIES;

  @override
  Widget getIcon() => const icons.Countries(size: 20.0);

  @override
  BackgroundTaskDetailsStamp getStamp() => BackgroundTaskDetailsStamp.countries;

  @override
  AnalyticsEditEvents getAnalyticsEditEvent() => AnalyticsEditEvents.country;
}
