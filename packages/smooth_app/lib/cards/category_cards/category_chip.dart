// Flutter imports:
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.title,
    required this.color,
    required this.onTap,
  });

  final String title;
  final Color color;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
        child: Material(
          elevation: 8.0,
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          shadowColor: color.withAlpha(160),
          child: Container(
            decoration: BoxDecoration(
              color: color.withAlpha(200),
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
