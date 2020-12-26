import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/IngredientsAnalysisTags.dart';

class PalmOilFreeInformationCard extends StatelessWidget {
  const PalmOilFreeInformationCard({@required this.status});

  final PalmOilFreeStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case PalmOilFreeStatus.IS_PALM_OIL_FREE:
        color = Colors.lightGreen;
        text = 'This product is palm oil free';
        break;
      case PalmOilFreeStatus.IS_NOT_PALM_OIL_FREE:
        color = Colors.redAccent;
        text = 'This product is not palm oil free';
        break;
      case PalmOilFreeStatus.MAYBE:
        color = Colors.deepOrangeAccent;
        text = 'We are unable to tell if this product is palm oil free';
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
