import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Page for selecting foods the user prefers to avoid.
class FoodsToAvoidPage extends StatelessWidget {
  const FoodsToAvoidPage({super.key});

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
            'Ce que je préfère éviter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: LARGE_SPACE),
          Text(
            'Sélectionnez les aliments que vous préférez éviter sans que ce soit une interdiction stricte.',
          ),
          // TODO: Add foods to avoid selection options
        ],
      ),
    );
  }
}
