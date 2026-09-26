import 'package:flutter/material.dart';

/// Allows to unfocus TextField (and dismiss the keyboard) when user tap outside the TextField and inside this widget.
/// Therefore, this widget should be put before the Scaffold to make the TextField unfocus when tapping anywhere.
class UnfocusFieldWhenTapOutside extends StatelessWidget {
  const UnfocusFieldWhenTapOutside({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      final FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    },
    child: child,
  );
}
