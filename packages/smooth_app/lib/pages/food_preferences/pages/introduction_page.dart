import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  static const double stepIndicatorSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<String> steps = <String>[
      'Régimes alimentaires',
      'Allergies',
      'Ce que je ne mange pas',
      'Ce que je préfère éviter',
      "Préférences en matière d'environnement",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: VERY_LARGE_SPACE * 2,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Dans les prochaines étapes, vous pourrez personnaliser l\'application en indiquant vos:',
          ),
          const SizedBox(height: LARGE_SPACE),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(MEDIUM_SPACE),
            itemCount: steps.length,
            itemBuilder: (BuildContext context, int index) =>
                _buildTimelineStep(index, steps[index], theme),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(
                  height: VERY_LARGE_SPACE,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: stepIndicatorSize),
                      VerticalDivider(thickness: 1, color: Colors.grey),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(int index, String text, ThemeData theme) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: stepIndicatorSize,
          backgroundColor: theme.colorScheme.secondary,
          child: Text(
            '${index + 1}',
            style: TextStyle(color: theme.colorScheme.onSecondary),
          ),
        ),
        const SizedBox(width: MEDIUM_SPACE),
        Expanded(child: Text(text)),
      ],
    );
  }
}
