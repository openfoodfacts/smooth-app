import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Custom [ListTile] for attribute groups in preferences.
class AttributeGroupListTile extends StatelessWidget {
  const AttributeGroupListTile({required this.title, required this.icon});

  final Widget title;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: LARGE_SPACE,
      vertical: LARGE_SPACE,
    ),
    child: DefaultTextStyle.merge(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[title, icon],
      ),
      style: Theme.of(context).textTheme.headlineMedium,
    ),
  );
}
