import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({required this.attributeGroups, super.key});

  final List<AttributeGroup> attributeGroups;

  static const double stepIndicatorSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // Get step names from attribute groups
    final List<String> steps = attributeGroups
        .map((AttributeGroup group) => group.name ?? group.id ?? '')
        .where((String name) => name.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: VERY_LARGE_SPACE * 2,
      ),
      child: Column(
        children: <Widget>[
          Text(appLocalizations.food_preferences_introduction_description),
          const SizedBox(height: LARGE_SPACE),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
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
