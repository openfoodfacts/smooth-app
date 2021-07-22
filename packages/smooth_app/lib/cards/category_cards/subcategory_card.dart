import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubcategoryCard extends StatelessWidget {
  const SubcategoryCard({
    required this.title,
    required this.color,
    required this.onTap,
    required this.heroTag,
    Key? key,
  }) : super(key: key);

  final String title;
  final Color color;
  final VoidCallback onTap;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
        child: Hero(
          tag: heroTag,
          child: Container(
            height: 60.0,
            decoration: BoxDecoration(
              color: color.withAlpha(32),
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(color: color)),
                SvgPicture.asset(
                  'assets/misc/right_arrow.svg',
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
