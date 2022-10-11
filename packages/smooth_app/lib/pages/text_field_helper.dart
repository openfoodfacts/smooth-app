import 'package:flutter/material.dart';

class TextEditingControllerWithInitialValue extends TextEditingController {
  TextEditingControllerWithInitialValue({String? text})
      : _initialValue = text,
        super(text: text);

  final String? _initialValue;

  bool get valueHasChanged => _initialValue != text;
}
