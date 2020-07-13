
import 'package:flutter/material.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';

class NutriscoreExpandable extends StatelessWidget {

  const NutriscoreExpandable({@required this.nutriscore});

  final String nutriscore;

  @override
  Widget build(BuildContext context) {
    return SmoothExpandableCard(
      headerHeight: 50.0,
      collapsedHeader: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Image.asset(
              'assets/product/nutri_score_$nutriscore.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            width: 12.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Row(
              children: const <Widget>[
                Flexible(
                  child: Text('Message according to the score'),
                )
              ],
            ),
          ),
        ],
      ),
      content: Container(
        width: 150.0,
        child: Image.asset(
          'assets/product/nutri_score_$nutriscore.png',
          fit: BoxFit.contain,
        ),
      ),
      expandedHeader: Text('Nutri-score', style: Theme.of(context).textTheme.headline3,),
    );
  }

}