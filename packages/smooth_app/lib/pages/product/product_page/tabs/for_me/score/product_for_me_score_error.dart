import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductForMeCompatibilityError extends StatelessWidget {
  const ProductForMeCompatibilityError({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: LARGE_SPACE,
      children: <Widget>[
        const icons.Milk.unhappy(),
        Expanded(child: Text(label)),
      ],
    );
  }
}
