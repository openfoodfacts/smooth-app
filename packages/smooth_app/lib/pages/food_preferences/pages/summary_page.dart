import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/models/pending_preferences.dart';
import 'package:smooth_app/pages/food_preferences/widgets/summary_section.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({required this.onEditGroup, super.key});

  final void Function(int groupIndex) onEditGroup;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Consumer<PendingPreferences>(
      builder:
          (
            BuildContext context,
            PendingPreferences pendingPreferences,
            Widget? child,
          ) {
            final List<AttributeGroup> attributeGroups =
                pendingPreferences.attributeGroups;
            final List<String> unwantedIngredients =
                pendingPreferences.unwantedIngredients;

            return ListView.builder(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: MEDIUM_SPACE,
              ),
              itemCount: attributeGroups.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: LARGE_SPACE,
                      vertical: SMALL_SPACE,
                    ),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            appLocalizations
                                .food_preferences_summary_description,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                index--;

                final AttributeGroup group = attributeGroups[index];
                final List<Attribute> selectedAttributes = pendingPreferences
                    .getSelectedAttributesForGroup(group);

                return SummarySection(
                  group: group,
                  selectedAttributes: selectedAttributes,
                  unwantedIngredients: unwantedIngredients,
                  onEdit: () => onEditGroup(index),
                );
              },
            );
          },
    );
  }
}
