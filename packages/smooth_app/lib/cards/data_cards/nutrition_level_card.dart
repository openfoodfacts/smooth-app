import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/NutrientLevels.dart';

class NutritionLevelCard extends StatelessWidget {
  const NutritionLevelCard(
      {@required this.title,
      this.subtitle,
      @required this.level,
      this.icon,
      this.chip = false});

  final String title;
  final String subtitle;
  final Widget icon;
  final Level level;
  final bool chip;

  @override
  Widget build(BuildContext context) {
    if (chip) {
      return Material(
          elevation: 4.0,
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          shadowColor: _getColor().withAlpha(60),
          color: Colors.transparent,
          child: Container(
              height: 36.0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: _getColor().withAlpha(60),
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Center(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: _getColor()),
                ),
              )));
    }
    return Material(
      elevation: 4.0,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      shadowColor: _getColor().withAlpha(60),
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 80.0,
        decoration: BoxDecoration(
          color: _getColor().withAlpha(60),
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  .copyWith(color: _getColor()),
            ),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: _getColor()),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (level) {
      case Level.LOW:
        return Colors.lightGreen;
        break;
      case Level.MODERATE:
        return Colors.orangeAccent;
        break;
      case Level.HIGH:
        return Colors.redAccent;
        break;
      case Level.UNDEFINED:
        return Colors.grey;
        break;
      default:
        return Colors.grey;
        break;
    }
  }
}
