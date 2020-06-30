import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({@required this.title, @required this.color, this.onTap});

  final String title;
  final Color color;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Material(
        elevation: 12.0,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        shadowColor: color.withAlpha(160),
        child: Container(
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
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/actions/smoothie.svg',
                    color: color,
                    height: 50.0,
                  ),
                ],
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
