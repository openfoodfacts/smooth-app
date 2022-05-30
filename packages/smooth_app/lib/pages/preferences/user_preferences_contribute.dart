import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_app/data_models/github_contributors_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';

/// Display of "Contribute" for the preferences page.
class UserPreferencesContribute extends AbstractUserPreferences {
  UserPreferencesContribute({
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

  @override
  PreferencePageType? getPreferencePageType() => PreferencePageType.CONTRIBUTE;

  @override
  String getTitleString() => appLocalizations.contribute;

  @override
  Widget? getSubtitle() => null;

  @override
  IconData getLeadingIconData() => Icons.emoji_people;

  @override
  String? getHeaderAsset() => 'assets/preferences/contribute.svg';

  @override
  Color? getHeaderColor() => const Color(0xFFFFF2DF);

  @override
  List<Widget> getBody() => <Widget>[
        _getListTile(
          appLocalizations.contribute_improve_header,
          () => _contribute(),
          Icons.data_saver_on,
        ),
        _getListTile(
          appLocalizations.contribute_sw_development,
          () => _develop(),
          Icons.app_shortcut,
        ),
        _getListTile(
          appLocalizations.contribute_translate_header,
          () => _translate(),
          Icons.translate,
        ),
        _getListTile(
          appLocalizations.contribute_donate_header,
          () => _donate(),
          Icons.volunteer_activism,
          icon:
              UserPreferencesListTile.getTintedIcon(Icons.open_in_new, context),
        ),
        _getListTile(
          appLocalizations.contributors,
          () => _contributors(),
          Icons.emoji_people,
        ),
      ];

  Future<void> _contribute() => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          return SmoothAlertDialog(
            title: appLocalizations.contribute_improve_header,
            body: Column(
              children: <Widget>[
                Text(
                  appLocalizations.contribute_improve_text,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () => LaunchUrlHelper.launchURL(
                      'https://world.openfoodfacts.org/state/to-be-completed',
                      false),
                  child: Text(
                    appLocalizations.contribute_improve_ProductsToBeCompleted,
                  ),
                ),
              ],
            ),
            positiveAction: SmoothActionButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              text: appLocalizations.okay,
              minWidth: 100,
            ),
          );
        },
      );

  Future<void> _develop() => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          return SmoothAlertDialog(
            title: appLocalizations.contribute_sw_development,
            body: Column(
              children: <Widget>[
                Text(appLocalizations.contribute_develop_text),
                const SizedBox(height: 20),
                Text(appLocalizations.contribute_develop_text_2),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => LaunchUrlHelper.launchURL(
                          'https://slack.openfoodfacts.org/', false),
                      child: const Text(
                        'Slack',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () => LaunchUrlHelper.launchURL(
                          'https://github.com/openfoodfacts', false),
                      child: const Text(
                        'Github',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                )
              ],
            ),
            positiveAction: SmoothActionButton(
              onPressed: () => Navigator.pop(context),
              text: appLocalizations.okay,
              minWidth: 100,
            ),
          );
        },
      );

  Future<void> _translate() => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          return SmoothAlertDialog(
            title: appLocalizations.contribute_translate_header,
            body: Column(
              children: <Widget>[
                Text(
                  appLocalizations.contribute_translate_text,
                ),
                Text(
                  appLocalizations.contribute_translate_text_2,
                ),
              ],
            ),
            positiveAction: SmoothActionButton(
              onPressed: () => LaunchUrlHelper.launchURL(
                  'https://translate.openfoodfacts.org/', false),
              text: appLocalizations.contribute_translate_link_text,
            ),
          );
        },
      );

  Future<void> _donate() async => LaunchUrlHelper.launchURL(
        AppLocalizations.of(context).donate_url,
        false,
      );

  Future<void> _contributors() => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SmoothAlertDialog(
            title: AppLocalizations.of(context).contributors,
            body: FutureBuilder<http.Response>(
              future: http.get(
                Uri.https(
                  'api.github.com',
                  '/repos/openfoodfacts/smooth-app/contributors',
                ),
              ),
              builder:
                  (BuildContext context, AsyncSnapshot<http.Response> snap) {
                if (snap.hasData) {
                  final List<dynamic> contributors =
                      jsonDecode(snap.data!.body) as List<dynamic>;
                  return SingleChildScrollView(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: contributors.map((dynamic contributorsData) {
                        final ContributorsModel contributor =
                            ContributorsModel.fromJson(
                                contributorsData as Map<String, dynamic>);
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              LaunchUrlHelper.launchURL(
                                contributor.profilePath,
                                false,
                              );
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    contributor.avatarUrl,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              width: 40.0,
                              height: 40.0,
                            ),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  );
                }

                return const CircularProgressIndicator();
              },
            ),
            positiveAction: SmoothActionButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              text: appLocalizations.close,
              minWidth: 100,
            ),
            negativeAction: SmoothActionButton(
              onPressed: () => LaunchUrlHelper.launchURL(
                  'https://github.com/openfoodfacts/smooth-app', false),
              text: AppLocalizations.of(context).contribute,
              minWidth: 200,
            ),
          );
        },
      );

  Widget _getListTile(
    final String title,
    final VoidCallback onTap,
    final IconData leading, {
    final Icon? icon,
  }) =>
      UserPreferencesListTile(
        title: Text(title),
        onTap: onTap,
        trailing: icon ?? getForwardIcon(),
        leading: UserPreferencesListTile.getTintedIcon(leading, context),
      );
}
