import 'package:flutter/widgets.dart';

extension KeyboardContextExtention on BuildContext {
  bool get keyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0.0;
}
