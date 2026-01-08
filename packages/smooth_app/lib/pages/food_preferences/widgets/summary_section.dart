import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class SummarySection extends StatelessWidget {
  const SummarySection({
    required this.group,
    required this.selectedAttributes,
    required this.onEdit,
    super.key,
  });

  final AttributeGroup group;
  final List<Attribute> selectedAttributes;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String groupName = group.name ?? group.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
          ),
          color: theme.colorScheme.tertiaryContainer,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  groupName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
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
              children: selectedAttributes.map((Attribute attribute) {
                final String name =
                    attribute.settingName ?? attribute.name ?? '';
                return Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: SMALL_SPACE,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.arrow_circle_right_rounded,
                        size: 28.0,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: SMALL_SPACE),
                      Expanded(
                        child: Text(name, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
