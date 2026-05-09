import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Object to inject at the root of the application to ensure we always
/// have the correct view padding available.
class SmoothViewPadding extends SingleChildStatelessWidget {
  const SmoothViewPadding({required Widget super.child, super.key});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Provider<_ViewPadding>.value(
      value: _ViewPadding.fromEdgeInsets(MediaQuery.of(context).viewPadding),
      child: child,
    );
  }

  static EdgeInsets of(BuildContext context) {
    return Provider.of<_ViewPadding>(context, listen: false);
  }
}

class _ViewPadding extends EdgeInsets {
  _ViewPadding.fromEdgeInsets(EdgeInsets edgeInsets)
    : super.only(
        left: edgeInsets.left,
        top: edgeInsets.top,
        right: edgeInsets.right,
        bottom: edgeInsets.bottom,
      );
}
