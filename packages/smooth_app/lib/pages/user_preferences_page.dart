import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/attribute_button.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

/// Preferences page for attribute importances
class UserPreferencesPage extends StatelessWidget {
  const UserPreferencesPage();

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final List<AttributeGroup> groups = productPreferences.attributeGroups;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).myPreferences),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => userPreferences.resetImportances(
              productPreferences,
            ),
          ),
        ],
      ),
      body: ListView(
        children: List<Widget>.generate(
          groups.length,
          (int index) => _generateGroup(
            context,
            groups[index],
            userPreferences,
            productPreferences,
          ),
        ),
      ),
    );
  }

  Widget _generateGroup(
    final BuildContext context,
    final AttributeGroup group,
    final UserPreferences userPreferences,
    final ProductPreferences productPreferences,
  ) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
            child: ListTile(title: Text(group.name)),
          ),
          if (group.warning != null)
            Container(
              color: SmoothTheme.getColor(
                Theme.of(context).colorScheme,
                AttributeButton.WARNING_COLOR,
                ColorDestination.BUTTON_BACKGROUND,
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
              margin: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
              child: Text(
                group.warning,
                style: TextStyle(
                  color: SmoothTheme.getColor(
                    Theme.of(context).colorScheme,
                    AttributeButton.WARNING_COLOR,
                    ColorDestination.BUTTON_FOREGROUND,
                  ),
                ),
              ),
            ),
          Wrap(
            children: List<Widget>.generate(
              group.attributes.length,
              (int index) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AttributeButton(
                  group.attributes[index],
                  productPreferences,
                ),
              ),
            ),
          )
        ],
      );
}
