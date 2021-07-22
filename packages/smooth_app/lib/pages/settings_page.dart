// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

// Project imports:
import 'package:smooth_app/bottom_sheet_views/user_contribution_view.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  static const List<String> _ORDERED_COLOR_TAGS = <String>[
    SmoothTheme.COLOR_TAG_BLUE,
    SmoothTheme.COLOR_TAG_GREEN,
    SmoothTheme.COLOR_TAG_BROWN,
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Launcher launcher = Launcher();
    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.settingsTitle)),
      body: ListView(
        children: <Widget>[
          //Darkmode
          SmoothListTile(
            text: appLocalizations.darkmode,
            onPressed: null,
            leadingWidget: SmoothToggle(
              value: themeProvider.darkTheme,
              width: 85.0,
              height: 38.0,
              textRight: 'Light',
              textLeft: 'Dark',
              colorRight: Colors.blue,
              colorLeft: Colors.blueGrey.shade700,
              iconRight: const Icon(Icons.wb_sunny_rounded),
              iconLeft: const Icon(
                Icons.nightlight_round,
                color: Colors.black,
              ),
              onChanged: (bool newValue) async =>
                  await themeProvider.setDarkTheme(newValue),
            ),
          ),

          //Configure Preferences
          SmoothListTile(
            text: appLocalizations.configurePreferences,
            onPressed: () async => await Navigator.push<Widget>(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const UserPreferencesPage(),
              ),
            ),
          ),

          // Palettes
          SmoothListTile(
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
          ),

          //Contribute
          SmoothListTile(
            text: appLocalizations.contribute,
            onPressed: () => showCupertinoModalBottomSheet<Widget>(
              expand: false,
              context: context,
              backgroundColor: Colors.transparent,
              bounce: true,
              builder: (BuildContext context) => UserContributionView(),
            ),
          ),

          //Support
          SmoothListTile(
            text: appLocalizations.support,
            leadingWidget: const Icon(Icons.launch),
            onPressed: () => launcher.launchURL(
                context, 'https://slack.openfoodfacts.org/', false),
          ),

          //About
          SmoothListTile(
            text: appLocalizations.about,
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  //ToDo: Show App Icon  !!! 2x !!! + onTap open App in Store https://pub.dev/packages/open_appstore

                  return SmoothAlertDialog(
                    close: false,
                    body: Column(
                      children: <Widget>[
                        FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (BuildContext context,
                                AsyncSnapshot<PackageInfo> snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('${appLocalizations.error} #0'),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data == null)
                                return Center(
                                    child: Text(
                                  '${appLocalizations.error} #1',
                                ));

                              return Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.no_sim_outlined),
                                    title: Text(
                                      snapshot.data!.appName.toString(),
                                      style: themeData.textTheme.headline1,
                                    ),
                                    subtitle: Text(
                                      snapshot.data!.version.toString(),
                                      style: themeData.textTheme.subtitle2,
                                    ),
                                  ),
                                  Divider(
                                    color: themeData.colorScheme.onSurface,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(appLocalizations.whatIsOff),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          launcher.launchURL(
                                              context,
                                              'https://openfoodfacts.org/who-we-are',
                                              true);
                                        },
                                        child: Text(
                                          appLocalizations.learnMore,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => launcher.launchURL(
                                            context,
                                            'https://openfoodfacts.org/terms-of-use',
                                            true),
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
                              );
                            }),
                      ],
                    ),
                    actions: <SmoothSimpleButton>[
                      SmoothSimpleButton(
                        onPressed: () {
                          showLicensePage(context: context);
                        },
                        text: appLocalizations.licenses,
                        minWidth: 100,
                      ),
                      SmoothSimpleButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        },
                        text: appLocalizations.okay,
                        minWidth: 100,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getColorButton(
    final ColorScheme colorScheme,
    final String colorTag,
    final ThemeProvider themeProvider,
  ) =>
      TextButton(
        onPressed: () async => await themeProvider.setColorTag(colorTag),
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
}
