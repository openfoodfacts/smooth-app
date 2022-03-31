import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mailto/mailto.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_main_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/views/bottom_sheet_views/faq_handle_view.dart';
import 'package:smooth_app/views/bottom_sheet_views/social_handle_view.dart';
import 'package:smooth_app/views/bottom_sheet_views/user_contribution_view.dart';
import 'package:url_launcher/url_launcher.dart';

/// Collapsed/expanded display of settings for the preferences page.
class UserPreferencesSettings extends AbstractUserPreferences {
  UserPreferencesSettings({
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
    required this.themeProvider,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  final ThemeProvider themeProvider;

  static const List<String> _ORDERED_COLOR_TAGS = <String>[
    SmoothTheme.COLOR_TAG_BLUE,
    SmoothTheme.COLOR_TAG_GREEN,
    SmoothTheme.COLOR_TAG_BROWN,
  ];

  @override
  bool isCollapsedByDefault() => true;

  @override
  String getPreferenceFlagKey() => 'settings';

  @override
  Widget getTitle() => Text(
        appLocalizations.myPreferences_settings_title,
        style: themeData.textTheme.headline2,
      );

  @override
  Widget? getSubtitle() =>
      Text(appLocalizations.myPreferences_settings_subtitle);
  @override
  List<Widget> getBody() => <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                appLocalizations.darkmode,
                style: themeData.textTheme.headline4,
              ),
              DropdownButton<String>(
                value: themeProvider.currentTheme,
                elevation: 16,
                onChanged: (String? newValue) {
                  themeProvider.setTheme(newValue!);
                },
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(
                    // TODO(aman): translations
                    child: Text('System Default'),
                    value: THEME_SYSTEM_DEFAULT,
                  ),
                  DropdownMenuItem<String>(
                    child: Text(appLocalizations.darkmode_light),
                    value: THEME_LIGHT,
                  ),
                  DropdownMenuItem<String>(
                    child: Text(appLocalizations.darkmode_dark),
                    value: THEME_DARK,
                  )
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
          child: Text(
            appLocalizations.main_app_color,
            style: themeData.textTheme.headline4,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: VERY_SMALL_SPACE,
          ),
          child: Wrap(
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
        SmoothListTile(
          text: appLocalizations.support,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) => SmoothAlertDialog(
                close: false,
                body: Column(
                  children: <Widget>[
                    SmoothMainButton(
                      important: false,
                      text: appLocalizations.support_join_slack,
                      onPressed: () {
                        LaunchUrlHelper.launchURL(
                          'https://slack.openfoodfacts.org/',
                          false,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SmoothMainButton(
                      important: false,
                      text: appLocalizations.support_via_email,
                      onPressed: () async {
                        final PackageInfo packageInfo =
                            await PackageInfo.fromPlatform();
                        // TODO(M123): Change subject name when we have a different app name
                        final Mailto mailtoLink = Mailto(
                          to: <String>['contact@openfoodfacts.org'],
                          subject: 'Smoothie help',
                          body:
                              'Version:${packageInfo.version}+${packageInfo.buildNumber} running on ${Platform.operatingSystem}(${Platform.operatingSystemVersion})',
                        );
                        await launch('$mailtoLink');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SmoothListTile(
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
                        '${packageInfo.version}+${packageInfo.buildNumber}',
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
                actions: <SmoothActionButton>[
                  SmoothActionButton(
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
                  SmoothActionButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    text: appLocalizations.okay,
                    minWidth: 100,
                  ),
                ],
              ),
            );
          },
        ),
        SmoothListTile(
          text: AppLocalizations.of(context)!.connect_with_us,
          onPressed: () => showCupertinoModalBottomSheet<Widget>(
            expand: false,
            context: context,
            backgroundColor: Colors.transparent,
            bounce: true,
            builder: (BuildContext context) => SocialHandleView(),
          ),
        ),
        SmoothListTile(
          text: appLocalizations.faq,
          onPressed: () => showCupertinoModalBottomSheet<Widget>(
            expand: false,
            context: context,
            backgroundColor: Colors.transparent,
            bounce: true,
            builder: (BuildContext context) => FaqHandleView(),
          ),
        ),
      ];

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
}
