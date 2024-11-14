import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_new_packagings.dart';
import 'package:smooth_app/pages/product/edit_ocr/edit_ocr_page.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_ingredients_helper.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_packaging_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

// TODO(monsieurtanuki): refactor - move all product field edit files to a new "field" folder
/// Helper class about product fields.
///
/// The typical use-case is the centralized "open edit page" method.
abstract class ProductFieldEditor {
  /// Returns true if the field is populated for that product.
  bool isPopulated(final Product product);

  /// Returns a standard "add/edit" button label.
  String getLabel(final AppLocalizations appLocalizations);

  /// Opens a page to edit that field for that product.
  Future<void> edit({
    required final BuildContext context,
    required final Product product,
    final bool isLoggedInMandatory = true,
  });
}

class ProductFieldSimpleEditor extends ProductFieldEditor {
  ProductFieldSimpleEditor(this.helper);

  final AbstractSimpleInputPageHelper helper;

  @override
  bool isPopulated(final Product product) => helper.isPopulated(product);

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      helper.getAddButtonLabel(appLocalizations);

  @override
  Future<void> edit({
    required final BuildContext context,
    required final Product product,
    final bool isLoggedInMandatory = true,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      helper.getAnalyticsEditEvent(),
      product,
    );

    if (!context.mounted) {
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SimpleInputPage(
          helper: helper,
          product: product,
        ),
      ),
    );
  }
}

class ProductFieldDetailsEditor extends ProductFieldEditor {
  /// Returns true if the [field] is valid (= not empty).
  bool _isProductFieldValid(final String? field) =>
      field != null && field.trim().isNotEmpty;

  @override
  bool isPopulated(final Product product) =>
      _isProductFieldValid(product.productName) ||
      (product.productNameInLanguages?.isNotEmpty == true) ||
      _isProductFieldValid(product.brands);

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.completed_basic_details_btn_text;

  @override
  Future<void> edit({
    required final BuildContext context,
    required final Product product,
    final bool isLoggedInMandatory = true,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.basicDetails,
      product,
    );

    if (!context.mounted) {
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AddBasicDetailsPage(
          product,
          isLoggedInMandatory: isLoggedInMandatory,
        ),
      ),
    );
  }
}

class ProductFieldPackagingEditor extends ProductFieldEditor {
  @override
  bool isPopulated(final Product product) =>
      product.packagings?.isEmpty == false;

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      OcrPackagingHelper().getAddButtonLabel(appLocalizations);

  @override
  Future<void> edit({
    required final BuildContext context,
    required final Product product,
    final bool isLoggedInMandatory = true,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.packagingComponents,
      product,
    );

    if (!context.mounted) {
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EditNewPackagings(
          product: product,
          isLoggedInMandatory: isLoggedInMandatory,
        ),
      ),
    );
  }
}

class ProductFieldNutritionEditor extends ProductFieldEditor {
  @override
  bool isPopulated(final Product product) =>
      product.nutriments?.isEmpty() == false;

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.nutritional_facts_input_button_label;

  @override
  Future<void> edit({
    required final BuildContext context,
    required final Product product,
    final bool isLoggedInMandatory = true,
  }) async =>
      NutritionPageLoaded.showNutritionPage(
        product: product,
        isLoggedInMandatory: isLoggedInMandatory,
        context: context,
      );
}

abstract class ProductFieldOcrEditor extends ProductFieldEditor {
  ProductFieldOcrEditor(this.helper);

  final OcrHelper helper;

  @override
  String getLabel(final AppLocalizations appLocalizations) =>
      helper.getAddButtonLabel(appLocalizations);

  @override
  Future<void> edit({
    required final BuildContext context,
    required final Product product,
    final bool isLoggedInMandatory = true,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      helper.getEditEventAnalyticsTag(),
      product,
    );

    if (!context.mounted) {
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EditOcrPage(
          product: product,
          helper: helper,
          isLoggedInMandatory: isLoggedInMandatory,
        ),
      ),
    );
  }
}

class ProductFieldOcrIngredientEditor extends ProductFieldOcrEditor {
  ProductFieldOcrIngredientEditor() : super(OcrIngredientsHelper());

  @override
  bool isPopulated(final Product product) =>
      product.ingredientsTextInLanguages?.isEmpty == false;
}

class ProductFieldOcrPackagingEditor extends ProductFieldOcrEditor {
  ProductFieldOcrPackagingEditor() : super(OcrPackagingHelper());

  @override
  bool isPopulated(final Product product) =>
      product.packagingTextInLanguages?.isEmpty == false;
}
