import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    required this.decimalNumberFormat,
    required this.unitNumberFormat,
    required this.expanded,
  });

  /// Creates all controllers from a packaging.
  EditNewPackagingsHelper.packaging(
    final ProductPackaging packaging,
    final bool initiallyExpanded, {
    required final NumberFormat decimalNumberFormat,
    required final NumberFormat unitNumberFormat,
  }) : this._(
         controllerUnits: TextEditingController(
           text: packaging.numberOfUnits == null
               ? null
               : unitNumberFormat.format(packaging.numberOfUnits),
         ),
         controllerShape: TextEditingController(text: packaging.shape?.lcName),
         controllerMaterial: TextEditingController(
           text: packaging.material?.lcName,
         ),
         controllerRecycling: TextEditingController(
           text: packaging.recycling?.lcName,
         ),
         controllerQuantity: TextEditingController(
           text: packaging.quantityPerUnit,
         ),
         controllerWeight: TextEditingController(
           text: packaging.weightMeasured == null
               ? null
               : decimalNumberFormat.format(packaging.weightMeasured),
         ),
         expanded: initiallyExpanded,
         decimalNumberFormat: decimalNumberFormat,
         unitNumberFormat: unitNumberFormat,
       );

  final TextEditingController controllerUnits;
  final TextEditingController controllerShape;
  final TextEditingController controllerMaterial;
  final TextEditingController controllerRecycling;
  final TextEditingController controllerQuantity;
  final TextEditingController controllerWeight;
  final NumberFormat decimalNumberFormat;
  final NumberFormat unitNumberFormat;
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
        result.add('$text ');
      }
    }

    if (controllerUnits.text.isNotEmpty) {
      result.add('${controllerUnits.text} x ');
    }

    addIfNotEmpty(controllerShape.text);
    addIfNotEmpty(controllerQuantity.text);

    if (controllerMaterial.text.isNotEmpty) {
      if (controllerWeight.text.isNotEmpty) {
        result.add('(${controllerMaterial.text}: ${controllerWeight.text}g)');
      } else {
        result.add('(${controllerMaterial.text})');
      }
    } else if (controllerWeight.text.isNotEmpty) {
      result.add('(${controllerWeight.text}g)');
    }

    if (result.isEmpty) {
      return null;
    }
    return result.join('');
  }

  /// Returns the packaging subtitle from the controllers
  String getSubTitle() {
    return controllerRecycling.text;
  }

  /// Returns the packaging from the controllers.
  ProductPackaging getPackaging() {
    final ProductPackaging packaging = ProductPackaging();
    packaging.shape = _getLocalizedTag(controllerShape);
    packaging.material = _getLocalizedTag(controllerMaterial);
    packaging.recycling = _getLocalizedTag(controllerRecycling);
    packaging.quantityPerUnit = _getString(controllerQuantity);
    packaging.weightMeasured = _getParsedDecimalController(controllerWeight);
    packaging.numberOfUnits = _getParsedUnitController(controllerUnits);
    return packaging;
  }

  double? _getParsedDecimalController(final TextEditingController controller) {
    final String text = controller.text.trim();
    if (text.isEmpty) {
      return null;
    }
    try {
      return decimalNumberFormat.parse(text).toDouble();
    } catch (e) {
      return null;
    }
  }

  int? _getParsedUnitController(final TextEditingController controller) {
    final String text = controller.text.trim();
    if (text.isEmpty) {
      return null;
    }
    try {
      return unitNumberFormat.parse(text).ceil();
    } catch (e) {
      return null;
    }
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
