import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Page for selecting dietary preferences (e.g., vegetarian, vegan, etc.)
class DietsPage extends StatelessWidget {
  const DietsPage({super.key});

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
            'Sélectionnez vos régimes alimentaires',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: LARGE_SPACE),
          Text(
            'Choisissez les régimes alimentaires que vous suivez pour personnaliser vos recommandations.',
          ),
          // TODO: Add diet selection options
        ],
      ),
    );
  }
}
