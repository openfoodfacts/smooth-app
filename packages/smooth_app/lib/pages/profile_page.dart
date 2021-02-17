import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:smooth_app/bottom_sheet_views/user_contribution_view.dart';
import 'package:smooth_app/bottom_sheet_views/user_preferences_view.dart';
import 'package:smooth_app/functions/launchURL.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DarkThemeProvider themeChange = context.watch<DarkThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    final Launcher launcher = Launcher();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).testerSettingTitle,
          style: TextStyle(color: themeData.colorScheme.onBackground),
        ),
        iconTheme: IconThemeData(color: themeData.colorScheme.onBackground),
      ),
      body: Column(
        children: <Widget>[
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
                  //themeChange.darkTheme = newValue,
                  if (themeChange.darkTheme != newValue) {
                    themeChange.darkTheme = newValue;
                  }
                }),
          ),

          //Configure Preferences
          SmoothListTile(
            text: AppLocalizations.of(context).configurePreferences,
            onPressed: () => UserPreferencesView.showModal(context),
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
              builder: (BuildContext context) => UserContributionView(
                ModalScrollController.of(context),
              ),
            ),
          ),

          //Support
          SmoothListTile(
            text: AppLocalizations.of(context).support,
            leadingWidget: const Icon(Icons.launch),
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
                    body: Column(
                      children: <Widget>[
                        FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
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
                                    leading: const Icon(Icons.no_sim_outlined),
                                    title: Text(
                                      snapshot.data.appName.toString(),
                                      style: themeData.textTheme.headline1,
                                    ),
                                    subtitle: Text(
                                      snapshot.data.version.toString(),
                                      style: themeData.textTheme.subtitle2,
                                    ),
                                  ),
                                  Divider(
                                    color: themeData.colorScheme.onSurface,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(AppLocalizations.of(context).whatIsOff),
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
                        onPressed: () {
                          showLicensePage(context: context);
                        },
                        text: '${AppLocalizations.of(context).licenses}',
                        width: 100,
                      ),
                      SmoothSimpleButton(
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
}
