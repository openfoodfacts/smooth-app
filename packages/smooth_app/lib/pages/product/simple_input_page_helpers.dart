import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';

/// Abstract helper for Simple Input Page.
///
/// * we retrieve the initial list of terms.
/// * we add a term to the list.
/// * we remove a term from the list.
abstract class AbstractSimpleInputPageHelper {
  AbstractSimpleInputPageHelper(
    this.product,
    this.appLocalizations,
  ) {
    _language = ProductQuery.getLanguage()!;
    _terms = initTerms();
  }

  final Product product;
  final AppLocalizations appLocalizations;
  late final OpenFoodFactsLanguage _language;

  /// Terms as they were initially then edited by the user.
  late List<String> _terms;

  /// "Have the terms been changed?"
  bool _changed = false;

  /// Returns the terms as they were initially in the product.
  @protected
  List<String> initTerms();

  /// Returns the current terms to be displayed.
  List<String> get terms => _terms;

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
    return true;
  }

  /// Returns true if the term was in the list and then was removed.
  ///
  /// The things we build the interface, very unlikely to return false,
  /// as we remove existing items.
  bool removeTerm(final String term) {
    if (_terms.remove(term)) {
      _changed = true;
      return true;
    }
    return false;
  }

  /// Returns the title on the main "edit product" page.
  String getTitle();

  /// Returns the subtitle on the main "edit product" page.
  String? getSubtitle() => null;

  /// Returns the hint of the "add" text field.
  String getAddHint();

  /// Impacts a product in order to take the changes into account.
  @protected
  void changeProduct(final Product changedProduct);

  /// Returns null is no change was made, or a Product to be saved on the BE.
  Product? getChangedProduct() {
    if (!_changed) {
      return null;
    }
    final Product changedProduct = Product(barcode: product.barcode);
    changeProduct(changedProduct);
    return changedProduct;
  }
}

/// Implementation for "Stores" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageStoreHelper extends AbstractSimpleInputPageHelper {
  SimpleInputPageStoreHelper(
    final Product product,
    final AppLocalizations appLocalizations,
  ) : super(
          product,
          appLocalizations,
        );

  @override
  List<String> initTerms() => _splitString(product.stores);

  @override
  void changeProduct(final Product changedProduct) =>
      changedProduct.stores = terms.join(', ');

  @override
  String getTitle() => appLocalizations.edit_product_form_item_stores_title;

  @override
  String getAddHint() => appLocalizations.edit_product_form_item_stores_hint;

  List<String> _splitString(String? input) {
    if (input == null) {
      return <String>[];
    }
    input = input.trim();
    if (input.isEmpty) {
      return <String>[];
    }
    return input.split(',');
  }
}

/// Abstraction, for "in language" field, of an [AbstractSimpleInputPageHelper].
abstract class AbstractSimpleInputPageInLanguageHelper
    extends AbstractSimpleInputPageHelper {
  AbstractSimpleInputPageInLanguageHelper(
    final Product product,
    final AppLocalizations appLocalizations,
  ) : super(
          product,
          appLocalizations,
        );

  final Map<String, String> _termToTags = <String, String>{};

  /// Returns the value of the tags list of field for a product.
  ///
  /// E.g. `product.categoriesTags`
  @protected
  List<String>? getTags();

  /// Returns the value of the translations of a field for a product.
  ///
  /// E.g. `product.categoriesTagsInLanguages`
  @protected
  Map<OpenFoodFactsLanguage, List<String>>? getInLanguages();

  /// Sets the value of a field for a product.
  ///
  /// e.g. `product.categories = value`
  @protected
  void setValue(final Product changedProduct, final String value);

  @override
  List<String> initTerms() {
    final List<String>? tags = getTags();
    final Map<OpenFoodFactsLanguage, List<String>>? inLanguages =
        getInLanguages();
    if (tags != null && inLanguages != null) {
      final List<String>? translations = inLanguages[_language];
      if (translations != null && translations.length == tags.length) {
        for (int i = 0; i < translations.length; i++) {
          _termToTags[translations[i]] = tags[i];
        }
        return List<String>.from(translations);
      }
    }
    return <String>[];
  }

  @override
  void changeProduct(final Product changedProduct) {
    final StringBuffer result = StringBuffer();
    for (int i = 0; i < terms.length; i++) {
      final String term = terms[i];
      String? tag = _termToTags[term];
      tag ??= '${_language.code}:$term';
      if (i > 0) {
        result.write(', ');
      }
      result.write(tag);
    }
    setValue(changedProduct, result.toString());
  }
}

/// Implementation for "Labels" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageLabelHelper
    extends AbstractSimpleInputPageInLanguageHelper {
  SimpleInputPageLabelHelper(
    final Product product,
    final AppLocalizations appLocalizations,
  ) : super(
          product,
          appLocalizations,
        );

  @override
  List<String>? getTags() => product.labelsTags;

  @override
  Map<OpenFoodFactsLanguage, List<String>>? getInLanguages() =>
      product.labelsTagsInLanguages;

  @override
  void setValue(final Product changedProduct, final String value) =>
      changedProduct.labels = value;

  @override
  String getTitle() => appLocalizations.edit_product_form_item_labels_title;

  @override
  String getSubtitle() =>
      appLocalizations.edit_product_form_item_labels_subtitle;

  @override
  String getAddHint() => appLocalizations.edit_product_form_item_labels_hint;
}

/// Implementation for "Categories" of an [AbstractSimpleInputPageHelper].
class SimpleInputPageCategoryHelper
    extends AbstractSimpleInputPageInLanguageHelper {
  SimpleInputPageCategoryHelper(
    final Product product,
    final AppLocalizations appLocalizations,
  ) : super(
          product,
          appLocalizations,
        );

  @override
  List<String>? getTags() => product.categoriesTags;

  @override
  Map<OpenFoodFactsLanguage, List<String>>? getInLanguages() =>
      product.categoriesTagsInLanguages;

  @override
  void setValue(final Product changedProduct, final String value) =>
      changedProduct.categories = value;

  @override
  String getTitle() => appLocalizations.edit_product_form_item_categories_title;

  @override
  String getAddHint() =>
      appLocalizations.edit_product_form_item_categories_hint;
}
