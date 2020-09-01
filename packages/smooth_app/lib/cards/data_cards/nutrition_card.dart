import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:smooth_ui_library/widgets/smooth_gauge.dart';

class NutritionCard extends StatelessWidget {
  const NutritionCard(
      {@required this.title, @required this.color, @required this.nutriments});

  final String title;
  final Color color;
  final Nutriments nutriments;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12.0,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      shadowColor: color,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: color.withAlpha(200),
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getLine('Sugars', 50, 100, context),
            _getLine('Salt', 50, 100, context),
            _getLine('Fat', 50, 100, context),
            _getLine('Saturated Fat', 50, 100, context),
          ],
        ),
      ),
    );
  }

  Widget _getLine(
      String title, double value, double recommendation, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.white),
                ),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                value.toString(),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.white),
              ),
              Text(
                '0%',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SmoothGauge(
                circular: false,
                color: Colors.white,
                backgroundColor: Colors.white54,
                value: 0.5,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
