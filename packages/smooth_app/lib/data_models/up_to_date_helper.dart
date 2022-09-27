import 'package:flutter/material.dart';

/// Just an `int` unique identifier, with a distinct class name for clarity.
@immutable
abstract class _UpToDateId implements Comparable<_UpToDateId> {
  const _UpToDateId(this.id);

  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! _UpToDateId) {
      return false;
    }
    return id == other.id;
  }

  @override
  String toString() => id.toString();

  @override
  int compareTo(final _UpToDateId other) => id.compareTo(other.id);
}

/// Unique identifier for product change in up-to-date context.
@immutable
class UpToDateOperationId extends _UpToDateId {
  const UpToDateOperationId(super.id);
}

/// Unique identifier for widget in up-to-date context.
@immutable
class UpToDateWidgetId extends _UpToDateId {
  const UpToDateWidgetId(super.id);
}

/// One-to-many relationships between barcodes and widgets.
class UpToDateBarcodeWidgets {
  /// Several widgets for the same barcode.
  final Map<String, Set<UpToDateWidgetId>> _barcodeToWidgets =
      <String, Set<UpToDateWidgetId>>{};

  /// One widget has only one barcode.
  final Map<UpToDateWidgetId, String> _widgetToBarcode =
      <UpToDateWidgetId, String>{};

  /// Puts a relationship between a barcode and a widget.
  void put(final String barcode, final UpToDateWidgetId widgetId) {
    _widgetToBarcode[widgetId] = barcode;
    Set<UpToDateWidgetId>? widgets = _barcodeToWidgets[barcode];
    if (widgets == null) {
      widgets = <UpToDateWidgetId>{};
      _barcodeToWidgets[barcode] = widgets;
    }
    widgets.add(widgetId);
  }

  /// Returns the barcode related to a widget.
  ///
  /// No good reason to return null actually.
  String? getBarcode(final UpToDateWidgetId widgetId) =>
      _widgetToBarcode[widgetId];

  /// Returns all the widgets related to a barcode.
  Iterable<UpToDateWidgetId>? getWidgets(final String barcode) =>
      _barcodeToWidgets[barcode];

  /// Removes the relationship between a barcode and a widget.
  ///
  /// Returns true if no widget are related to that barcode anymore.
  bool remove(final String barcode, final UpToDateWidgetId widgetId) {
    final Set<UpToDateWidgetId>? widgets = _barcodeToWidgets[barcode];
    if (widgets == null) {
      // very unlikely
      return true;
    }
    _widgetToBarcode.remove(widgetId);
    widgets.remove(barcode);
    return widgets.isEmpty;
  }
}
