import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/github_contributors_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

class ContributeUIHelper {
  const ContributeUIHelper._();

  static Future<void> showDevelopBottomSheet(BuildContext context) async {
    return showSmoothModalSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final UserPreferences userPreferences = context
            .watch<UserPreferences>();
        return SmoothModalSheet(
          title: appLocalizations.contribute_sw_development,
          prefixIndicator: true,
          body: Column(
            children: <Widget>[
              Text(appLocalizations.contribute_develop_text),
              const SizedBox(height: VERY_LARGE_SPACE),
              Text(appLocalizations.contribute_develop_text_2),
              const SizedBox(height: BALANCED_SPACE),
              SmoothAlertContentButton(
                label: 'Slack',
                icon: Icons.open_in_new,
                onPressed: () async => LaunchUrlHelper.launchURL(
                  'https://slack.openfoodfacts.org/',
                ),
              ),
              const SizedBox(height: SMALL_SPACE),
              SmoothAlertContentButton(
                label: 'GitHub',
                icon: Icons.open_in_new,
                onPressed: () async => LaunchUrlHelper.launchURL(
                  'https://github.com/openfoodfacts',
                ),
              ),
              const SizedBox(height: BALANCED_SPACE),
              SwitchListTile.adaptive(
                title: Text(appLocalizations.contribute_develop_dev_mode_title),
                subtitle: Text(
                  appLocalizations.contribute_develop_dev_mode_subtitle,
                ),
                value: userPreferences.devMode != 0,
                onChanged: (final bool devMode) async =>
                    userPreferences.setDevMode(devMode ? 1 : 0),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showTranslateBottomSheet(BuildContext context) async {
    return showSmoothModalSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        return SmoothModalSheet(
          title: appLocalizations.contribute_translate_header,
          prefixIndicator: true,
          body: Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(appLocalizations.contribute_translate_text),
                  Text(appLocalizations.contribute_translate_text_2),
                ],
              ),
              const SizedBox(height: LARGE_SPACE),
              SmoothSimpleButton(
                onPressed: () async => LaunchUrlHelper.launchURL(
                  'https://translate.openfoodfacts.org/',
                ),
                minWidth: 150,
                child: Text(
                  appLocalizations.contribute_translate_link_text.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showContributorsBottomSheet(BuildContext context) async {
    return showSmoothModalSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        return SmoothModalSheet(
          title: appLocalizations.contributors_dialog_title,
          prefixIndicator: true,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FutureBuilder<http.Response>(
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
                        return Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: contributors
                              .map((dynamic contributorsData) {
                                final ContributorsModel contributor =
                                    ContributorsModel.fromJson(
                                      contributorsData as Map<String, dynamic>,
                                    );
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Semantics(
                                    value: appLocalizations
                                        .contributors_dialog_entry_description(
                                          contributor.login,
                                        ),
                                    excludeSemantics: true,
                                    child: Tooltip(
                                      message: contributor.login,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () async =>
                                            LaunchUrlHelper.launchURL(
                                              contributor.profilePath,
                                            ),
                                        child: Ink(
                                          width: 48.0,
                                          height: 48.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                contributor.avatarUrl,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(growable: false),
                        );
                      }

                      return const Padding(
                        padding: EdgeInsetsDirectional.all(LARGE_SPACE),
                        child: CircularProgressIndicator.adaptive(),
                      );
                    },
              ),
              const SizedBox(height: LARGE_SPACE),
              SmoothSimpleButton(
                onPressed: () async => LaunchUrlHelper.launchURL(
                  'https://github.com/openfoodfacts/smooth-app',
                ),
                minWidth: 150,
                child: Text(
                  appLocalizations.contribute.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
