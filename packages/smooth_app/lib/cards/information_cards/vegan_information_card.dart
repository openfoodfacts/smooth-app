import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/IngredientsAnalysisTags.dart';

class VeganInformationCard extends StatelessWidget {
  const VeganInformationCard({@required this.status});

  final VeganStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case VeganStatus.IS_VEGAN:
        color = Colors.lightGreen;
        text = 'This product is vegan';
        break;
      case VeganStatus.IS_NOT_VEGAN:
        color = Colors.redAccent;
        text = 'This product is not vegan';
        break;
      case VeganStatus.MAYBE:
        color = Colors.deepOrangeAccent;
        text = 'We are unable to tell if this product is vegan';
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
