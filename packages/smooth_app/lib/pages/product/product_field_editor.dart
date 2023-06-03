import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_new_packagings.dart';
import 'package:smooth_app/pages/product/edit_ocr_page.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';
import 'package:smooth_app/pages/product/ocr_ingredients_helper.dart';
import 'package:smooth_app/pages/product/ocr_packaging_helper.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

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

  /// Returns true if no log-in required or if logged in
  @protected
  Future<bool> passedLoggedIn({
    required final BuildContext context,
    required final bool isLoggedInMandatory,
  }) async {
    if (!isLoggedInMandatory) {
      return true;
    }

    return ProductRefresher().checkIfLoggedIn(context);
  }
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
  }) async =>
      helper.showEditPage(
        context: context,
        product: product,
        isLoggedInMandatory: isLoggedInMandatory,
      );
}

class ProductFieldDetailsEditor extends ProductFieldEditor {
  /// Returns true if the [field] is valid (= not empty).
  bool _isProductFieldValid(final String? field) =>
      field != null && field.trim().isNotEmpty;

  @override
  bool isPopulated(final Product product) =>
      _isProductFieldValid(product.productName) ||
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
    // ignore: use_build_context_synchronously
    if (!await passedLoggedIn(
      context: context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.basicDetails,
      product.barcode!,
    );

    // ignore: use_build_context_synchronously
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
    // ignore: use_build_context_synchronously
    if (!await passedLoggedIn(
      context: context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.packagingComponents,
      product.barcode!,
    );

    // ignore: use_build_context_synchronously
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EditNewPackagings(
          product: product,
        ),
        fullscreenDialog: true,
      ),
    );
  }
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
    // ignore: use_build_context_synchronously
    if (!await passedLoggedIn(
      context: context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      helper.getEditEventAnalyticsTag(),
      product.barcode!,
    );

    // ignore: use_build_context_synchronously
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EditOcrPage(
          product: product,
          helper: helper,
        ),
        fullscreenDialog: true,
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
