import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Page for selecting foods the user doesn't eat.
class UnwantedFoodsPage extends StatelessWidget {
  const UnwantedFoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: VERY_LARGE_SPACE,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Ce que je ne mange pas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: LARGE_SPACE),
          Text(
            'Indiquez les aliments ou ingrédients que vous ne consommez pas.',
          ),
          // TODO: Add unwanted foods selection options
        ],
      ),
    );
  }
}
