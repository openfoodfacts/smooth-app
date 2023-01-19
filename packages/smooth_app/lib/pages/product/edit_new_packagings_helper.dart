import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Helper about packaging component edition. Useful with controllers.
class EditNewPackagingsHelper {
  EditNewPackagingsHelper._({
    required this.controllerUnits,
    required this.controllerShape,
    required this.controllerMaterial,
    required this.controllerRecycling,
    required this.controllerQuantity,
    required this.controllerWeight,
    required this.expanded,
  });

  /// Creates all controllers from a packaging.
  EditNewPackagingsHelper.packaging(
    final ProductPackaging packaging,
    final bool initiallyExpanded,
  ) : this._(
          controllerUnits: TextEditingController(
            text: packaging.numberOfUnits == null
                ? null
                : '${packaging.numberOfUnits!}',
          ),
          controllerShape: TextEditingController(
            text: packaging.shape?.lcName,
          ),
          controllerMaterial: TextEditingController(
            text: packaging.material?.lcName,
          ),
          controllerRecycling: TextEditingController(
            text: packaging.recycling?.lcName,
          ),
          controllerQuantity:
              TextEditingController(text: packaging.quantityPerUnit),
          controllerWeight: TextEditingController(
            text: packaging.weightMeasured == null
                ? null
                : '${packaging.weightMeasured!}',
          ),
          expanded: initiallyExpanded,
        );

  final TextEditingController controllerUnits;
  final TextEditingController controllerShape;
  final TextEditingController controllerMaterial;
  final TextEditingController controllerRecycling;
  final TextEditingController controllerQuantity;
  final TextEditingController controllerWeight;
  bool expanded;

  /// Disposes all controllers.
  void dispose() {
    controllerUnits.dispose();
    controllerShape.dispose();
    controllerMaterial.dispose();
    controllerRecycling.dispose();
    controllerQuantity.dispose();
    controllerWeight.dispose();
  }

  /// Returns the packaging title from the controllers, or null if empty.
  String? getTitle() {
    final List<String> result = <String>[];

    void addIfNotEmpty(final String text) {
      if (text.isNotEmpty) {
        result.add(text);
      }
    }

    addIfNotEmpty(controllerUnits.text);
    addIfNotEmpty(controllerShape.text);
    addIfNotEmpty(controllerMaterial.text);
    addIfNotEmpty(controllerRecycling.text);
    addIfNotEmpty(controllerWeight.text);
    addIfNotEmpty(controllerQuantity.text);

    if (result.isEmpty) {
      return null;
    }
    return result.join(' ');
  }

  /// Returns the packaging from the controllers.
  ProductPackaging getPackaging() {
    final ProductPackaging packaging = ProductPackaging();
    packaging.shape = _getLocalizedTag(controllerShape);
    packaging.material = _getLocalizedTag(controllerMaterial);
    packaging.recycling = _getLocalizedTag(controllerRecycling);
    packaging.quantityPerUnit = _getString(controllerQuantity);
    packaging.weightMeasured = double.tryParse(controllerWeight
        .text); // TODO(monsieurtanuki): handle the "not a number" case
    packaging.numberOfUnits = int.tryParse(controllerUnits
        .text); // TODO(monsieurtanuki): handle the "not a number" case
    return packaging;
  }

  LocalizedTag? _getLocalizedTag(final TextEditingController controller) {
    final String text = controller.text;
    if (text.isEmpty) {
      return null;
    }
    return LocalizedTag()..lcName = text;
  }

  String? _getString(final TextEditingController controller) {
    final String text = controller.text;
    if (text.isEmpty) {
      return null;
    }
    return text;
  }
}
