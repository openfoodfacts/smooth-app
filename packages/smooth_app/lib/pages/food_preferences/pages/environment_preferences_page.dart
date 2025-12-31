import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Page for selecting environmental preferences.
class EnvironmentPreferencesPage extends StatelessWidget {
  const EnvironmentPreferencesPage({super.key});

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
            "Préférences en matière d'environnement",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: LARGE_SPACE),
          Text(
            "Indiquez vos préférences environnementales pour des recommandations plus durables.",
          ),
          // TODO: Add environment preferences selection options
        ],
      ),
    );
  }
}
