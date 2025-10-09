import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/github_contributors_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ContributeRoot extends PreferencesRoot {
  const ContributeRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OpenFoodFactsCountry country = ProductQuery.getCountry();

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_contribute_active_volunteer_title,
        tiles: <PreferenceTile>[
          _buildSkillPoolTile(appLocalizations),
          _buildHowToContributeTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_mobile_dev_title,
        tiles: <PreferenceTile>[
          _buildSoftwareDevelopmentTile(context, appLocalizations),
          if (GlobalVars.appStore.getEnrollInBetaURL() != null)
            _buildEnrollAlphaTile(context, appLocalizations),
          _buildContributorsTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_local_community_title,
        tiles: <PreferenceTile>[
          _buildTranslateTile(context, appLocalizations),
          _buildShareTile(appLocalizations),
          if (country.wikiUrl != null)
            _buildCountryImproveTile(appLocalizations, country),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_contribute_data_quality_title,
        tiles: <PreferenceTile>[_buildDataQualityTile(appLocalizations)],
      ),
    ];
  }

  // Active Volunteer section
  UrlPreferenceTile _buildSkillPoolTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.Student(),
      title: appLocalizations.contribute_join_skill_pool,
      subtitleText: appLocalizations.preferences_contribute_skill_pool_subtitle,
      url:
          'https://connect.openfoodfacts.org/join-the-contributor-skill-pool-open-food-facts',
    );
  }

  UrlPreferenceTile _buildHowToContributeTile(
    AppLocalizations appLocalizations,
  ) {
    return UrlPreferenceTile(
      leading: const icons.Book(),
      title: appLocalizations.how_to_contribute,
      subtitleText: appLocalizations.preferences_contribute_how_to_subtitle,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/contribute',
      ),
    );
  }

  // Mobile Development section
  PreferenceTile _buildSoftwareDevelopmentTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Construction(),
      title: appLocalizations.contribute_sw_development,
      subtitleText: appLocalizations.preferences_contribute_sw_dev_subtitle,
      onTap: () async => _develop(context),
    );
  }

  PreferenceTile _buildEnrollAlphaTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Lab.alt(),
      title: appLocalizations.preferences_contribute_enroll_alpha,
      subtitleText: appLocalizations.preferences_contribute_alpha_subtitle,
      onTap: () async => _enrollInInternal(context),
    );
  }

  PreferenceTile _buildContributorsTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: const icons.CrossWalk(),
      title: appLocalizations.contributors_label,
      subtitleText: appLocalizations.contributors_description,
      onTap: () async => _contributors(context),
    );
  }

  // Local Community section
  PreferenceTile _buildTranslateTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      leading: const icons.Language(),
      title: appLocalizations.preferences_contribute_translate_header,
      subtitleText: appLocalizations.preferences_contribute_translate_subtitle,
      onTap: () async => _translate(context),
    );
  }

  PreferenceTile _buildShareTile(AppLocalizations appLocalizations) {
    return PreferenceTile(
      leading: const icons.Coffee.love(),
      title: appLocalizations.contribute_share_header,
      subtitleText: appLocalizations.preferences_contribute_share_subtitle,
      onTap: () async => _share(appLocalizations.contribute_share_content),
    );
  }

  UrlPreferenceTile _buildCountryImproveTile(
    AppLocalizations appLocalizations,
    OpenFoodFactsCountry country,
  ) {
    return UrlPreferenceTile(
      leading: const icons.World.help(),
      title: appLocalizations.help_improve_country,
      subtitleText: appLocalizations.preferences_contribute_country_subtitle,
      url: country.wikiUrl!,
    );
  }

  // Data Quality section
  UrlPreferenceTile _buildDataQualityTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.Certificate(),
      title: appLocalizations.preferences_contribute_data_quality_team_title,
      subtitleText:
          appLocalizations.preferences_contribute_data_quality_team_subtitle,
      url: 'https://wiki.openfoodfacts.org/Data_quality',
    );
  }

  Future<void> _develop(BuildContext context) => showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      final UserPreferences userPreferences = context.watch<UserPreferences>();
      return SmoothAlertDialog(
        title: appLocalizations.contribute_sw_development,
        body: Column(
          children: <Widget>[
            Text(appLocalizations.contribute_develop_text),
            const SizedBox(height: VERY_LARGE_SPACE),
            Text(appLocalizations.contribute_develop_text_2),
            const SizedBox(height: BALANCED_SPACE),
            SmoothAlertContentButton(
              label: 'Slack',
              icon: Icons.open_in_new,
              onPressed: () async =>
                  LaunchUrlHelper.launchURL('https://slack.openfoodfacts.org/'),
            ),
            const SizedBox(height: SMALL_SPACE),
            SmoothAlertContentButton(
              label: 'GitHub',
              icon: Icons.open_in_new,
              onPressed: () async =>
                  LaunchUrlHelper.launchURL('https://github.com/openfoodfacts'),
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
        negativeAction: SmoothActionButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          text: appLocalizations.close,
          minWidth: 100.0,
        ),
      );
    },
  );

  Future<void> _translate(BuildContext context) => showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      return SmoothAlertDialog(
        title: appLocalizations.contribute_translate_header,
        body: Column(
          children: <Widget>[
            Text(appLocalizations.contribute_translate_text),
            Text(appLocalizations.contribute_translate_text_2),
          ],
        ),
        positiveAction: SmoothActionButton(
          onPressed: () async =>
              LaunchUrlHelper.launchURL('https://translate.openfoodfacts.org/'),
          text: appLocalizations.contribute_translate_link_text,
        ),
        negativeAction: SmoothActionButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          text: appLocalizations.close,
          minWidth: 100,
        ),
        actionsAxis: Axis.vertical,
        actionsOrder: SmoothButtonsBarOrder.auto,
      );
    },
  );

  Future<void> _share(String content) async =>
      SharePlus.instance.share(ShareParams(text: content));

  Future<void> _enrollInInternal(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.preferences_contribute_enroll_alpha,
        body: Text(appLocalizations.contribute_enroll_alpha_warning),
        negativeAction: SmoothActionButton(
          text: appLocalizations.close,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (result == true) {
      await LaunchUrlHelper.launchURL(
        GlobalVars.appStore.getEnrollInBetaURL()!,
      );
    }
  }

  Future<void> _contributors(BuildContext context) => showDialog<void>(
    context: context,
    builder: (BuildContext context) => const _ContributorsDialog(),
  );
}

class _ContributorsDialog extends StatefulWidget {
  const _ContributorsDialog();

  @override
  State<_ContributorsDialog> createState() => _ContributorsDialogState();
}

class _ContributorsDialogState extends State<_ContributorsDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothAlertDialog(
      title: appLocalizations.contributors_dialog_title,
      body: FutureBuilder<http.Response>(
        future: http.get(
          Uri.https(
            'api.github.com',
            '/repos/openfoodfacts/smooth-app/contributors',
          ),
        ),
        builder: (BuildContext context, AsyncSnapshot<http.Response> snap) {
          if (snap.hasData) {
            final List<dynamic> contributors =
                jsonDecode(snap.data!.body) as List<dynamic>;
            return Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Wrap(
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
                                onTap: () async => LaunchUrlHelper.launchURL(
                                  contributor.profilePath,
                                ),
                                child: Ink(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    borderRadius: ROUNDED_BORDER_RADIUS,
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
                ),
              ),
            );
          }

          return const Padding(
            padding: EdgeInsetsDirectional.all(LARGE_SPACE),
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
      positiveAction: SmoothActionButton(
        onPressed: () async => LaunchUrlHelper.launchURL(
          'https://github.com/openfoodfacts/smooth-app',
        ),
        text: AppLocalizations.of(context).contribute,
        minWidth: 150,
      ),
      negativeAction: SmoothActionButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
        text: appLocalizations.close,
        minWidth: 100.0,
      ),
      actionsAxis: Axis.vertical,
      actionsOrder: SmoothButtonsBarOrder.auto,
    );
  }
}
