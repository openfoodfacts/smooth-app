import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/attribute_button.dart';
import 'package:smooth_app/widgets/attribute_helper.dart';

/// Collapsed/expanded display of attributes for the preferences page.
class UserPreferencesAttributeGroup extends AbstractUserPreferences {
  UserPreferencesAttributeGroup(
    final Function(Function()) setState,
    this.productPreferences,
  ) : super(setState);

  final ProductPreferences productPreferences;

  @override
  bool isCollapsedByDefault() => false;

  @override
  String getPreferenceFlagKey() => 'attributes';

  @override
  String getTitle() => 'Food Preferences';

  @override
  String getSubtitle() =>
      'Choose what information about food matters most to you';

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
    AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  @override
  List<Widget> getBody(
    final BuildContext context,
    final AppLocalizations appLocalizations,
    final ThemeProvider themeProvider,
    final ThemeData themeData,
  ) {
    final List<AttributeGroup> groups =
        _reorderGroups(productPreferences.attributeGroups!);
    final List<String> orderedImportantAttributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    final List<Widget> result = <Widget>[];
    for (final AttributeGroup group in groups) {
      final List<Attribute> orderedImportantAttributes =
          _reorderAttributes(group, orderedImportantAttributeIds);
      result.add(
        _getListItemAttribute(context, group, productPreferences,
            orderedImportantAttributes, appLocalizations, themeData),
      );
    }
    return result;
  }

  Widget _getListItemAttribute(
    final BuildContext context,
    final AttributeGroup group,
    final ProductPreferences productPreferences,
    final List<Attribute> orderedImportantAttributes,
    final AppLocalizations appLocalizations,
    final ThemeData themeData,
  ) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
            child: ListTile(
              title: Text(
                group.name ?? appLocalizations.unknown,
                style: themeData.textTheme.headline3,
              ),
            ),
          ),
          if (group.warning != null)
            Container(
              color: SmoothTheme.getColor(
                Theme.of(context).colorScheme,
                WARNING_COLOR,
                ColorDestination.BUTTON_BACKGROUND,
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
              margin: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
              child: Text(
                group.warning ?? appLocalizations.unknown,
                style: TextStyle(
                  color: SmoothTheme.getColor(
                    Theme.of(context).colorScheme,
                    WARNING_COLOR,
                    ColorDestination.BUTTON_FOREGROUND,
                  ),
                ),
              ),
            ),
          Wrap(
            children: List<Widget>.generate(
              orderedImportantAttributes.length,
              (int index) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AttributeButton(
                  orderedImportantAttributes[index],
                  productPreferences,
                ),
              ),
            ),
          )
        ],
      );

  /// Returns a list of the attributes in the preferences order.
  ///
  /// First, the attributes ordered by id designated by [orderedAttributeIds],
  /// if they belong to the [group].
  /// Then, the remaining attributes of the group in the initial group order.
  List<Attribute> _reorderAttributes(
    final AttributeGroup group,
    final List<String> orderedAttributeIds,
  ) {
    if (orderedAttributeIds.isEmpty) {
      return group.attributes!;
    }
    final List<Attribute> importantAttributes = <Attribute>[];
    final List<Attribute> otherAttributes = <Attribute>[];
    for (final Attribute attribute in group.attributes!) {
      if (orderedAttributeIds.contains(attribute.id)) {
        importantAttributes.add(attribute);
      } else {
        otherAttributes.add(attribute);
      }
    }
    if (importantAttributes.isEmpty) {
      return otherAttributes;
    }
    importantAttributes.sort(
      (Attribute a, Attribute b) => orderedAttributeIds
          .indexOf(a.id!)
          .compareTo(orderedAttributeIds.indexOf(b.id!)),
    );
    importantAttributes.addAll(otherAttributes);
    return importantAttributes;
  }

  List<AttributeGroup> _reorderGroups(List<AttributeGroup> groups) {
    final List<AttributeGroup> result = <AttributeGroup>[];
    for (final String id in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      result.addAll(groups.where((AttributeGroup g) => g.id == id));
    }
    result.addAll(groups.where(
        (AttributeGroup g) => _ORDERED_ATTRIBUTE_GROUP_IDS.contains(g.id)));
    return result;
  }
}
