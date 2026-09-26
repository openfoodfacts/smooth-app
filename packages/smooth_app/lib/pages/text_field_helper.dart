import 'package:flutter/material.dart';

/// A [TextEditingController] that saves the value passed to the constructor
/// and persists the previous value.
class TextEditingControllerWithHistory extends TextEditingController {
  TextEditingControllerWithHistory({super.text})
    : _initialValue = text,
      _previousValue = text;

  final String? _initialValue;
  String? _previousValue;

  String? get initialValue => _initialValue;

  String? get previousValue => _previousValue;

  bool get isDifferentFromInitialValue => _initialValue != text;

  bool get isDifferentFromPreviousValue => _previousValue != text;

  void resetToInitialValue() {
    assert(_initialValue != null);
    if (_initialValue != null) {
      text = _initialValue;
    }
  }

  @override
  set text(String newText) {
    _previousValue = text;
    super.text = newText;
  }
}
