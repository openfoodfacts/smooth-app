import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps a TextEditingController and debounces its changes.
class DebouncedTextEditingController extends TextEditingController {
  DebouncedTextEditingController({
    TextEditingController? controller,
    this.debounceTime = const Duration(milliseconds: 500),
  }) {
    replaceWith(controller ?? TextEditingController());
  }

  final Duration debounceTime;
  TextEditingController? _controller;
  Timer? _debounce;

  void replaceWith(TextEditingController controller) {
    _controller?.removeListener(_onWrappedTextEditingControllerChanged);
    _controller = controller;
    _controller?.addListener(_onWrappedTextEditingControllerChanged);
  }

  void _onWrappedTextEditingControllerChanged() {
    if (_debounce?.isActive == true) {
      _debounce!.cancel();
    }

    _debounce = Timer(debounceTime, () => super.notifyListeners());
  }

  @override
  set text(String newText) => _controller?.value = value;

  @override
  String get text => _controller?.text ?? '';

  @override
  TextEditingValue get value => _controller?.value ?? TextEditingValue.empty;

  @override
  set value(TextEditingValue newValue) => _controller?.value = newValue;

  @override
  void clear() => _controller?.clear();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
