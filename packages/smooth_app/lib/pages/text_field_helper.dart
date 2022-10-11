import 'package:flutter/material.dart';

/// A [TextEditingController] that saves the value passed to the constructor.
class TextEditingControllerWithInitialValue extends TextEditingController {
  TextEditingControllerWithInitialValue({String? text})
      : _initialValue = text,
        super(text: text);

  final String? _initialValue;

  String? get initialValue => _initialValue;

  bool get valueHasChanged => _initialValue != text;
}
