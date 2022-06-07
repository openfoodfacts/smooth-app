import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Abstract helper for Simple Input Page.
///
/// * we retrieve the initial list of labels.
/// * we add a label to the list.
/// * we remove a label from the list.
abstract class AbstractSimpleInputPageHelper {
  AbstractSimpleInputPageHelper(
    this.product,
    this.appLocalizations,
  ) {
    _labels = initLabels();
  }

  final Product product;
  final AppLocalizations appLocalizations;

  /// Labels as they were initially then edited by the user.
  late List<String> _labels;

  /// "Have the labels been changed?"
  bool _changed = false;

  /// Returns the labels as they were initially in the product.
  @protected
  List<String> initLabels();

  /// Returns the current labels to be displayed.
  List<String> getLabels() => _labels;

  /// Returns true if the label was not in the list and then was added.
  bool addLabel(String label) {
    label = label.trim();
    if (label.isEmpty) {
      return false;
    }
    if (_labels.contains(label)) {
      return false;
    }
    _labels.add(label);
    _changed = true;
    return true;
  }

  /// Returns true if the label was in the list and then was removed.
  ///
  /// The things we build the interface, very unlikely to return false,
  /// as we remove existing items.
  bool removeLabel(final String label) {
    if (_labels.remove(label)) {
      _changed = true;
      return true;
    }
    return false;
  }

  /// Returns the title on the main "edit product" page.
  String getTitle();

  /// Returns the title of the "add" paragraph.
  String getAddTitle();

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

  List<String> _splitString(final String? input) {
    if (input == null) {
      return <String>[];
    }
    final List<String> result = input.split(',');
    for (int i = 0; i < result.length; i++) {
      final int pos = result[i].indexOf(':');
      if (pos == 2) {
        // we get rid of the language, e.g. 'fr:Sac'
        result[i] = result[i].substring(pos + 1);
      }
    }
    return result;
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
  List<String> initLabels() => _splitString(product.stores);

  @override
  void changeProduct(final Product changedProduct) =>
      changedProduct.stores = _labels.join(',');

  @override
  String getTitle() => 'Stores'; // TODO(monsieurtanuki): translate

  @override
  String getAddTitle() => 'Add a store'; // TODO(monsieurtanuki): translate

  @override
  String getAddHint() => 'store'; // TODO(monsieurtanuki): translate
}
