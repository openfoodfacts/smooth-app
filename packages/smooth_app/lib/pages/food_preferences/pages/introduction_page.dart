import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/widgets/timeline_step.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({required this.attributeGroups, super.key});

  final List<AttributeGroup> attributeGroups;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // Get step names from attribute groups
    final List<String> steps = attributeGroups
        .map((AttributeGroup group) => group.name ?? group.id ?? '')
        .where((String name) => name.isNotEmpty)
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: VERY_LARGE_SPACE * 2,
      ),
      child: Column(
        children: <Widget>[
          TextWithBoldParts(
            text: appLocalizations.food_preferences_introduction_description,
          ),
          const SizedBox(height: LARGE_SPACE),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
              itemCount: steps.length,
              itemBuilder: (BuildContext context, int index) =>
                  TimelineStep(index: index, text: steps[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                    height: VERY_LARGE_SPACE,
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: TimelineStep.stepIndicatorSize),
                        VerticalDivider(thickness: 1, color: Color(0xFF979797)),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
