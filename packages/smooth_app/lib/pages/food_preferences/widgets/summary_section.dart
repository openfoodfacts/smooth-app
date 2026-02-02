import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({
    required this.group,
    required this.selectedAttributes,
    required this.onEdit,
    this.unwantedIngredients = const <String>[],
    super.key,
  });

  final AttributeGroup group;
  final List<Attribute> selectedAttributes;
  final VoidCallback onEdit;
  final List<String> unwantedIngredients;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String groupName = group.name ?? group.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
          ),
          color: theme.primaryMedium,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  groupName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const icons.Edit(size: 20.0),
                onPressed: onEdit,
                tooltip: appLocalizations.edit,
              ),
            ],
          ),
        ),
        if (selectedAttributes.isEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
            child: Text(
              appLocalizations.food_preferences_no_selection,
              style: TextStyle(
                color: theme.greyMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: LARGE_SPACE,
              vertical: SMALL_SPACE,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedAttributes.expand((Attribute attribute) {
                final String name =
                    attribute.settingName ?? attribute.name ?? '';
                final bool isUnwantedIngredients =
                    attribute.id == Attribute.ATTRIBUTE_UNWANTED_INGREDIENTS;

                return <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: SMALL_SPACE,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          size: 28.0,
                          color: theme.primaryAccent,
                        ),
                        const SizedBox(width: SMALL_SPACE),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnwantedIngredients && unwantedIngredients.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 36.0,
                        bottom: SMALL_SPACE,
                      ),
                      child: Wrap(
                        spacing: SMALL_SPACE,
                        runSpacing: SMALL_SPACE,
                        children: unwantedIngredients.map((String ingredient) {
                          return Chip(
                            label: Text(ingredient),
                            backgroundColor: theme.primaryMedium,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                ];
              }).toList(),
            ),
          ),
      ],
    );
  }
}
