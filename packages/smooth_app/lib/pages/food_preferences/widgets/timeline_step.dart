import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class TimelineStep extends StatelessWidget {
  const TimelineStep({required this.index, required this.text});

  static const double stepIndicatorSize = 20.0;

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      spacing: MEDIUM_SPACE,
      children: <Widget>[
        CircleAvatar(
          radius: stepIndicatorSize,
          backgroundColor: theme.colorScheme.secondary,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
