

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/IngredientsAnalysisTags.dart';

class VegetarianInformationCard extends StatelessWidget {

  const VegetarianInformationCard({@required this.status});

  final VegetarianStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch(status) {
      case VegetarianStatus.IS_VEGETARIAN:
        color = Colors.lightGreen;
        text = 'This product is vegetarian';
        break;
      case VegetarianStatus.IS_NOT_VEGETARIAN:
        color = Colors.redAccent;
        text = 'This product is not vegetarian';
        break;
      case VegetarianStatus.MAYBE:
        color = Colors.deepOrangeAccent;
        text = 'We are unable to tell if this product is vegetarian';
        break;
    }
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        border: Border.all(color: color, width: 1.0),
      ),
      height: 50.0,
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText1.copyWith(color: color),
        ),
      ),
    );
  }

}