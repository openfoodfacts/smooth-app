import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/views/bottom_sheet_views/user_contribution_view.dart';
import 'package:smooth_app/widgets/attribute_button.dart';
import 'package:smooth_app/widgets/attribute_helper.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/widgets/smooth_list_tile.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

/// Preferences page for attribute importances
class UserPreferencesPage extends StatefulWidget {
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
  State<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  static const List<String> _ORDERED_COLOR_TAGS = <String>[
    SmoothTheme.COLOR_TAG_BLUE,
    SmoothTheme.COLOR_TAG_GREEN,
    SmoothTheme.COLOR_TAG_BROWN,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final List<AttributeGroup> groups =
        _reorderGroups(productPreferences.attributeGroups!);
    final List<String> orderedImportantAttributeIds =
        productPreferences.getOrderedImportantAttributeIds();

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.myPreferences)),
      body: ListView(
        children: List<Widget>.generate(
          _getTotalSize(groups, userPreferences),
          (int index) {
            for (int groupIndex = 0; groupIndex < 3; groupIndex++) {
              if (index-- == 0) {
                return _getGroupTitle(groupIndex, userPreferences, themeData);
              }
              if (!_isCollapsed(groupIndex, userPreferences)) {
                final int size = _getCollapsedSize(groupIndex, groups);
                if (index < size) {
                  return _getListItem(
                    groupIndex,
                    index,
                    appLocalizations,
                    themeProvider,
                    themeData,
                    userPreferences,
                    productPreferences,
                    groups,
                    orderedImportantAttributeIds,
                  );
                }
                index -= size;
              }
            }
            throw Exception('how did you get here: $index');
          },
        ),
      ),
    );
  }

  Widget _getListItemAttribute(
    final BuildContext context,
    final AttributeGroup group,
    final UserPreferences userPreferences,
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
            padding: const EdgeInsets.all(
                UserPreferencesPage._TYPICAL_PADDING_OR_MARGIN),
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
              padding: const EdgeInsets.all(
                  UserPreferencesPage._TYPICAL_PADDING_OR_MARGIN),
              margin: const EdgeInsets.all(
                  UserPreferencesPage._TYPICAL_PADDING_OR_MARGIN),
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
    for (final String id in UserPreferencesPage._ORDERED_ATTRIBUTE_GROUP_IDS) {
      result.addAll(groups.where((AttributeGroup g) => g.id == id));
    }
    result.addAll(groups.where((AttributeGroup g) =>
        !UserPreferencesPage._ORDERED_ATTRIBUTE_GROUP_IDS.contains(g.id)));
    return result;
  }

  Widget _getColorButton(
    final ColorScheme colorScheme,
    final String colorTag,
    final ThemeProvider themeProvider,
  ) =>
      TextButton(
        onPressed: () async => themeProvider.setColorTag(colorTag),
        style: TextButton.styleFrom(
          backgroundColor: SmoothTheme.getColor(
            colorScheme,
            SmoothTheme.MATERIAL_COLORS[colorTag]!,
            ColorDestination.BUTTON_BACKGROUND,
          ),
        ),
        child: Icon(
          Icons.palette,
          color: SmoothTheme.getColor(
            colorScheme,
            SmoothTheme.MATERIAL_COLORS[colorTag]!,
            ColorDestination.BUTTON_FOREGROUND,
          ),
        ),
      );

  String _getPreferenceFlagKey(final int groupIndex) {
    switch (groupIndex) {
      case 0:
        return 'profile';
      case 1:
        return 'food';
      case 2:
        return 'vrac';
    }
    throw Exception('unknown group index: $groupIndex');
  }

  bool _isCollapsed(
    final int groupIndex,
    final UserPreferences userPreferences,
  ) =>
      userPreferences.getFlag(_getPreferenceFlagKey(groupIndex)) ??
      // only group "food" is supposed to be expanded by default at init time
      groupIndex != 1;

  Future<void> _switchCollapsed(
    final int groupIndex,
    final UserPreferences userPreferences,
  ) async =>
      userPreferences.setFlag(
        _getPreferenceFlagKey(groupIndex),
        !_isCollapsed(
          groupIndex,
          userPreferences,
        ),
      );

  Widget _getGroupTitle(
    final int groupIndex,
    final UserPreferences userPreferences,
    final ThemeData themeData,
  ) {
    final String label;
    final String subLabel;
    final bool extra = groupIndex == 0;
    switch (groupIndex) {
      case 0:
        label = 'Your Profile';
        subLabel = 'Set app settings and find out advices and blah blah';
        break;
      case 1:
        label = 'Food Preferences';
        subLabel = 'Choose what information about food matters most to you';
        break;
      case 2:
        label = 'App Settings';
        subLabel = 'Dark mode, country, color, ...';
        break;
      default:
        throw Exception('unknown group index: $groupIndex');
    }
    Widget title = Text(label, style: themeData.textTheme.headline2);
    if (extra) {
      title = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          Container(
            width: 15,
            height: 15,
            child: Center(
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    }
    return ListTile(
      title: title,
      subtitle: Text(subLabel),
      trailing: Icon(_isCollapsed(groupIndex, userPreferences)
          ? Icons.expand_more
          : Icons.expand_less),
      onTap: () {
        _switchCollapsed(groupIndex, userPreferences);
        setState(() {});
      },
    );
  }

  int _getCollapsedSize(
      final int groupIndex, final List<AttributeGroup> groups) {
    switch (groupIndex) {
      case 0:
        return 5;
      case 1:
        return groups.length;
      case 2:
        return 3;
    }
    throw Exception('unknown group index: $groupIndex');
  }

  int _getTotalSize(
    final List<AttributeGroup> groups,
    final UserPreferences userPreferences,
  ) {
    int result = 0;
    for (int i = 0; i < 3; i++) {
      result++;
      if (!_isCollapsed(i, userPreferences)) {
        result += _getCollapsedSize(i, groups);
      }
    }
    return result;
  }

  Widget _getListItem(
    final int groupIndex,
    final int index,
    final AppLocalizations appLocalizations,
    final ThemeProvider themeProvider,
    final ThemeData themeData,
    final UserPreferences userPreferences,
    final ProductPreferences productPreferences,
    final List<AttributeGroup> groups,
    final List<String> orderedImportantAttributeIds,
  ) {
    switch (groupIndex) {
      case 0:
        return _getListItemSettings(
          index,
          appLocalizations,
          themeProvider,
          themeData,
        );
      case 1:
        return _getListItemAttribute(
          context,
          groups[index],
          userPreferences,
          productPreferences,
          _reorderAttributes(groups[index], orderedImportantAttributeIds),
          appLocalizations,
          themeData,
        );
      case 2:
        return _getListItemVrac(index, appLocalizations);
    }
    throw Exception('unknown group index: $groupIndex');
  }

  Widget _getListItemSettings(
    int index,
    final AppLocalizations appLocalizations,
    final ThemeProvider themeProvider,
    final ThemeData themeData,
  ) {
    if (index-- == 0) {
      return SmoothListTile(
        text: appLocalizations.darkmode,
        onPressed: null,
        leadingWidget: SmoothToggle(
          value: themeProvider.darkTheme,
          width: 85.0,
          height: 38.0,
          textRight: appLocalizations.darkmode_light,
          textLeft: appLocalizations.darkmode_dark,
          colorRight: Colors.blue,
          colorLeft: Colors.blueGrey.shade700,
          iconRight: const Icon(Icons.wb_sunny_rounded),
          iconLeft: const Icon(
            Icons.nightlight_round,
            color: Colors.black,
          ),
          onChanged: (bool newValue) async =>
              themeProvider.setDarkTheme(newValue),
        ),
      );
    }
    if (index-- == 0) {
      return SmoothListTile(
        leadingWidget: Container(),
        title: Wrap(
          spacing: 8.0,
          children: List<Widget>.generate(
            _ORDERED_COLOR_TAGS.length,
            (final int index) => _getColorButton(
              themeData.colorScheme,
              _ORDERED_COLOR_TAGS[index],
              themeProvider,
            ),
          ),
        ),
      );
    }
    if (index-- == 0) {
      return SmoothListTile(
        text: appLocalizations.contribute,
        onPressed: () => showCupertinoModalBottomSheet<Widget>(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          bounce: true,
          builder: (BuildContext context) => UserContributionView(),
        ),
      );
    }
    if (index-- == 0) {
      return SmoothListTile(
        text: appLocalizations.support,
        leadingWidget: const Icon(Icons.launch),
        onPressed: () => LaunchUrlHelper.launchURL(
            'https://slack.openfoodfacts.org/', false),
      );
    }
    if (index-- == 0) {
      return SmoothListTile(
        text: appLocalizations.about_this_app,
        onPressed: () async {
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          showDialog<void>(
            context: context,
            builder: (BuildContext context) => SmoothAlertDialog(
              close: false,
              body: Column(
                children: <Widget>[
                  ListTile(
                    leading:
                        Image.asset('assets/app/smoothie-icon.1200x1200.png'),
                    title: Text(
                      packageInfo.appName,
                      style: themeData.textTheme.headline1,
                    ),
                    subtitle: Text(
                      packageInfo.version,
                      style: themeData.textTheme.subtitle2,
                    ),
                  ),
                  Divider(color: themeData.colorScheme.onSurface),
                  const SizedBox(height: 20),
                  Text(appLocalizations.whatIsOff),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => LaunchUrlHelper.launchURL(
                            'https://openfoodfacts.org/who-we-are', true),
                        child: Text(
                          appLocalizations.learnMore,
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => LaunchUrlHelper.launchURL(
                            'https://openfoodfacts.org/terms-of-use', true),
                        child: Text(
                          appLocalizations.termsOfUse,
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              actions: <SmoothSimpleButton>[
                SmoothSimpleButton(
                  onPressed: () async {
                    showLicensePage(
                      context: context,
                      applicationName: packageInfo.appName,
                      applicationVersion: packageInfo.version,
                      applicationIcon: Image.asset(
                        'assets/app/smoothie-icon.1200x1200.png',
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                    );
                  },
                  text: appLocalizations.licenses,
                  minWidth: 100,
                ),
                SmoothSimpleButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  text: appLocalizations.okay,
                  minWidth: 100,
                ),
              ],
            ),
          );
        },
      );
    }
    throw Exception('unknown index: $index');
  }

  Widget _getListItemVrac(
    int index,
    final AppLocalizations appLocalizations,
  ) {
    if (index-- == 0) {
      return ListTile(
        leading: const Icon(Icons.threesixty_outlined),
        title: const Text('Check credentials'),
        onTap: () async {
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
      );
    }
    if (index-- == 0) {
      return ListTile(
        leading: const Icon(Icons.supervised_user_circle),
        title: const Text('User management'),
        onTap: () => Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => const LoginPage(),
          ),
        ),
      );
    }
    if (index-- == 0) {
      return ListTile(
        leading: const Icon(Icons.rotate_left),
        title: Text(appLocalizations.reset),
        onTap: () => _confirmReset(context),
      );
    }
    throw Exception('unknown index: $index');
  }
}
