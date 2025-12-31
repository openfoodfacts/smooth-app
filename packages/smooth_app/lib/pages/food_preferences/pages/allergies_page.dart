import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Page for selecting food allergies.
class AllergiesPage extends StatelessWidget {
  const AllergiesPage({super.key});

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
            'Indiquez vos allergies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: LARGE_SPACE),
          Text(
            'Sélectionnez les allergènes que vous devez éviter pour votre sécurité alimentaire.',
          ),
          // TODO: Add allergy selection options
        ],
      ),
    );
  }
}
