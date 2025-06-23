import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: VERY_SMALL_SPACE,
          horizontal: SMALL_SPACE,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.darkTheme() ? Colors.white : Colors.black,
              ),
        ),
      ),
    );
  }
}
