import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/settings_page.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/widgets/attribute_button.dart';
import 'package:smooth_app/widgets/attribute_helper.dart';

/// Preferences page for attribute importances
class UserPreferencesPage extends StatelessWidget {
  const UserPreferencesPage();

  static const List<String> _ORDERED_ATTRIBUTE_GROUP_IDS = <String>[
    AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
    AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
    AttributeGroup.ATTRIBUTE_GROUP_ENVIRONMENT,
    AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
    AttributeGroup.ATTRIBUTE_GROUP_LABELS,
    AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  ];

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final List<AttributeGroup> groups =
        _reorderGroups(productPreferences.attributeGroups!);
    final List<String> orderedImportantAttributeIds =
        productPreferences.getOrderedImportantAttributeIds();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.myPreferences),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.threesixty_outlined),
            tooltip: 'Check credentials',
            onPressed: () async {
              final bool correct =
                  await UserManagementHelper.checkAndReMountCredentials();

              final SnackBar snackBar = SnackBar(
                content: Text('It is $correct'),
                action: SnackBarAction(
                  label: 'Logout',
                  onPressed: () async {
                    UserManagementHelper.logout();
                  },
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          // TODO(M123-dev): Remove and replace with expandable mock
          IconButton(
            icon: const Icon(Icons.supervised_user_circle),
            tooltip: 'User management',
            onPressed: () {
              Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => const LoginPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.rotate_left),
            tooltip: appLocalizations.reset,
            onPressed: () => _confirmReset(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: appLocalizations.settingsTitle,
            onPressed: () => Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ProfilePage(),
              ),
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
            _reorderAttributes(groups[index], orderedImportantAttributeIds),
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
    final List<Attribute> orderedImportantAttributes,
  ) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(_TYPICAL_PADDING_OR_MARGIN),
            child: ListTile(
              title: Text(
                group.name ?? 'Unknown',
                style: Theme.of(context).textTheme.headline3,
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
                group.warning ?? 'Unknown',
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

  void _confirmReset(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmResetPreferences),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.yes),
              onPressed: () async {
                await context.read<ProductPreferences>().resetImportances();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(localizations.no),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  List<AttributeGroup> _reorderGroups(List<AttributeGroup> groups) {
    final List<AttributeGroup> result = <AttributeGroup>[];
    for (final String id in _ORDERED_ATTRIBUTE_GROUP_IDS) {
      result.addAll(groups.where((AttributeGroup g) => g.id == id));
    }
    result.addAll(groups.where(
        (AttributeGroup g) => !_ORDERED_ATTRIBUTE_GROUP_IDS.contains(g.id)));
    return result;
  }
}
