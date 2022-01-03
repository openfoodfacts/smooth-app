import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/widgets/attribute_button.dart';
import 'package:smooth_app/widgets/attribute_helper.dart';

/// Collapsed/expanded display of an attribute group for the preferences page.
class UserPreferencesAttributeGroup extends AbstractUserPreferences {
  UserPreferencesAttributeGroup({
    required this.productPreferences,
    required this.group,
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  final ProductPreferences productPreferences;
  final AttributeGroup group;

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  @override
  bool isCollapsedByDefault() => false;

  @override
  String getPreferenceFlagKey() => 'attribute:${group.id}';

  @override
  Widget getTitle() => Text(
        group.name ?? appLocalizations.unknown,
        style: themeData.textTheme.headline3,
      );

  @override
  Widget? getSubtitle() => null;

  @override
  List<Widget> getBody() {
    final List<String> orderedImportantAttributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    final List<Widget> result = <Widget>[];
    final List<Attribute> orderedImportantAttributes =
        _reorderAttributes(group, orderedImportantAttributeIds);
    if (group.warning != null) {
      result.add(
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
      );
    }
    result.addAll(
      List<Widget>.generate(
        orderedImportantAttributes.length,
        (int index) => Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AttributeButton(
            orderedImportantAttributes[index],
            productPreferences,
          ),
        ),
      ),
    );
    return result;
  }

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
}
