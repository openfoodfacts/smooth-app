import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Custom [ListTile] for attribute groups in preferences.
class AttributeGroupListTile extends StatelessWidget {
  const AttributeGroupListTile({
    required this.title,
    required this.icon,
  });

  final Widget title;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: LARGE_SPACE,
          ),
          child: DefaultTextStyle.merge(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[title, icon],
              ),
            ),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
}
