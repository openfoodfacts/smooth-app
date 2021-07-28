import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.title,
    required this.color,
    required this.onTap,
    required this.iconName,
  });

  final String title;
  final Color color;
  final String iconName;
  final VoidCallback onTap;

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
          child: Stack(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/categories/$iconName',
                    color: color,
                    height: 80.0,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
