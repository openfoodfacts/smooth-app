import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:smooth_app/bottom_sheet_views/user_contribution_view.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_AlertDialog.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';

Launcher launcher = Launcher();

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final DarkThemeProvider themeChange = context.watch<DarkThemeProvider>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 46.0, right: 16.0, left: 16.0, bottom: 4.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).testerSettingTitle,
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),

          //useMLKit
          SmoothListTile(
            text: AppLocalizations.of(context).useMLKitText,
            onPressed: null,
            leadingWidget: SmoothToggle(
                value: userPreferences.getMlKitState(),
                width: 80.0,
                height: 38.0,
                textLeft: AppLocalizations.of(context).yes,
                textRight: AppLocalizations.of(context).no,
                onChanged: (bool newValue) async =>
                    userPreferences.setMlKitState(newValue)),
          ),

          //Darkmode
          SmoothListTile(
            text: AppLocalizations.of(context).darkmode,
            onPressed: null,
            leadingWidget: SmoothToggle(
                value: themeChange.darkTheme,
                width: 80.0,
                height: 38.0,
                textLeft: AppLocalizations.of(context).yes,
                textRight: AppLocalizations.of(context).no,
                onChanged: (bool newValue) async {
                  themeChange.darkTheme = newValue;
                }),
          ),

          //Configure Preferences
          SmoothListTile(
            text: AppLocalizations.of(context).configurePreferences,
            onPressed: () => showCupertinoModalBottomSheet<Widget>(
              expand: false,
              context: context,
              backgroundColor: Colors.transparent,
              bounce: true,
              barrierColor: Colors.black45,
              builder:
                  (BuildContext context, ScrollController scrollController) =>
                      UserPreferencesView(scrollController),
            ),
          ),

          //Contribute
          SmoothListTile(
            text: AppLocalizations.of(context).contribute,
            onPressed: () => showCupertinoModalBottomSheet<Widget>(
              expand: false,
              context: context,
              backgroundColor: Colors.transparent,
              bounce: true,
              barrierColor: Colors.black45,
              builder:
                  (BuildContext context, ScrollController scrollController) =>
                      UserContributionView(scrollController),
            ),
          ),

          //Support
          SmoothListTile(
            text: AppLocalizations.of(context).support,
            leadingWidget:
                Icon(Icons.launch, color: Theme.of(context).accentColor),
            onPressed: () => launcher.launchURL(
                context, 'https://openfoodfacts.uservoice.com/', false),
          ),

          //About
          SmoothListTile(
            text: AppLocalizations.of(context).about,
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  //ToDo: Show App Icon  !!! 2x !!! + onTap open App in Store https://pub.dev/packages/open_appstore

                  return SmoothAlertDialog(
                    close: false,
                    context: context,
                    body: Column(
                      children: <Widget>[
                        FutureBuilder<PackageInfo>(
                            future: _getPubspecData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<PackageInfo> snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        '${AppLocalizations.of(context).error} #0'));
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData)
                                return Center(
                                    child: Text(
                                  '${AppLocalizations.of(context).error} #1',
                                ));

                              return Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.no_sim_outlined,
                                        color: Theme.of(context).accentColor),
                                    title: Text(
                                      snapshot.data.appName.toString(),
                                      style:
                                          Theme.of(context).textTheme.headline1,
                                    ),
                                    subtitle: Text(
                                      snapshot.data.version.toString(),
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    '${AppLocalizations.of(context).whatIsOff}',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      launcher.launchURL(
                                          context,
                                          'https://openfoodfacts.org/who-we-are',
                                          true);
                                    },
                                    child: Text(
                                      '${AppLocalizations.of(context).learnMore}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () => launcher.launchURL(
                                        context,
                                        'https://openfoodfacts.org/terms-of-use',
                                        true),
                                    child: Text(
                                      '${AppLocalizations.of(context).termsOfUse}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }),
                      ],
                    ),
                    actions: <SmoothSimpleButton>[
                      SmoothSimpleButton(
                        context: context,
                        onPressed: () {
                          showLicensePage(context: context);
                        },
                        text: '${AppLocalizations.of(context).licenses}',
                        width: 100,
                      ),
                      SmoothSimpleButton(
                        context: context,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        },
                        text: '${AppLocalizations.of(context).okay}',
                        width: 100,
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

  Future<PackageInfo> _getPubspecData() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo;
  }
}
