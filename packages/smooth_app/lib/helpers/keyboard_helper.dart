import 'package:flutter/widgets.dart';

extension KeyboardContextExtention on BuildContext {
  bool get keyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0.0;
}
