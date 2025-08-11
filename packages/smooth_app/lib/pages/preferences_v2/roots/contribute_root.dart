import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/github_contributors_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/hunger_games/question_page.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

class ContributeRoot extends PreferencesRoot {
  const ContributeRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OpenFoodFactsCountry country = ProductQuery.getCountry();

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.contribute,
        tiles: <PreferenceTile>[
          PreferenceTile(
            icon: Icons.games,
            title: 'Hunger Games',
            onTap: () async => _hungerGames(context),
          ),
          PreferenceTile(
            icon: Icons.data_saver_on,
            title: appLocalizations.contribute_improve_header,
            onTap: () async => _contribute(context),
          ),
          PreferenceTile(
            icon: Icons.app_shortcut,
            title: appLocalizations.contribute_sw_development,
            onTap: () async => _develop(context),
          ),
          PreferenceTile(
            icon: Icons.translate,
            title: appLocalizations.contribute_translate_header,
            onTap: () async => _translate(context),
          ),
          UrlPreferenceTile(
            icon: Icons.cleaning_services,
            title: appLocalizations.contribute_data_quality,
            url: 'https://wiki.openfoodfacts.org/Data_quality',
          ),
          UrlPreferenceTile(
            icon: Icons.volunteer_activism_outlined,
            title: appLocalizations.how_to_contribute,
            url: ProductQuery.replaceSubdomain(
              'https://world.openfoodfacts.org/contribute',
            ),
          ),
          UrlPreferenceTile(
            icon: Icons.group,
            title: appLocalizations.contribute_join_skill_pool,
            url:
                'https://connect.openfoodfacts.org/join-the-contributor-skill-pool-open-food-facts',
          ),
          PreferenceTile(
            icon: Icons.adaptive.share,
            title: appLocalizations.contribute_share_header,
            onTap: () async =>
                _share(appLocalizations.contribute_share_content),
          ),
          if (country.wikiUrl != null)
            UrlPreferenceTile(
              icon: Icons.language,
              title: appLocalizations.help_improve_country,
              url: country.wikiUrl!,
            ),
          if (GlobalVars.appStore.getEnrollInBetaURL() != null)
            PreferenceTile(
              icon: CupertinoIcons.lab_flask_solid,
              title: appLocalizations.contribute_enroll_alpha,
              onTap: () async => _enrollInBeta(context),
            ),
          PreferenceTile(
            icon: Icons.emoji_people,
            title: appLocalizations.contributors_label,
            subtitleText: appLocalizations.contributors_description,
            onTap: () async => _contributors(context),
          ),
        ],
      ),
    ];
  }

  Future<void> _hungerGames(BuildContext context) async {
    // Track the hunger game analytics event
    AnalyticsHelper.trackEvent(AnalyticsEvent.hungerGameOpened);

    await Navigator.push<int>(
      context,
      MaterialPageRoute<int>(
        builder: (BuildContext context) => const QuestionsPage(),
      ),
    );
  }

  Future<void> _contribute(BuildContext context) => showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      return SmoothAlertDialog(
        title: appLocalizations.contribute_improve_header,
        body: Column(
          children: <Widget>[
            Text(appLocalizations.contribute_improve_text),
            const SizedBox(height: 10),
          ],
        ),
        positiveAction: SmoothActionButton(
          text: AppLocalizations.of(
            context,
          ).contribute_improve_ProductsToBeCompleted,
          onPressed: () async {
            final LocalDatabase localDatabase = context.read<LocalDatabase>();
            Navigator.of(context).pop();
            ProductQueryPageHelper.openBestChoice(
              name: appLocalizations.all_search_to_be_completed_title,
              localDatabase: localDatabase,
              productQuery: PagedToBeCompletedProductQuery(
                // TODO(monsieurtanuki): only food?
                productType: ProductType.food,
              ),
              context: context,
              editableAppBarTitle: false,
            );
          },
        ),
        negativeAction: SmoothActionButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          text: appLocalizations.close,
          minWidth: 100,
        ),
        actionsAxis: Axis.vertical,
        actionsOrder: SmoothButtonsBarOrder.auto,
      );
    },
  );

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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          text: appLocalizations.close,
          minWidth: 100,
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
            Navigator.of(context, rootNavigator: true).pop('dialog');
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

  Future<void> _enrollInBeta(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.contribute_enroll_alpha,
        body: Text(appLocalizations.contribute_enroll_alpha_warning),
        negativeAction: SmoothActionButton(
          text: appLocalizations.close,
          onPressed: () => Navigator.pop(context, false),
        ),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.pop(context, true),
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
    builder: (BuildContext context) => _ContributorsDialog(),
  );
}

class _ContributorsDialog extends StatelessWidget {
  _ContributorsDialog();

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
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
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
            padding: EdgeInsets.all(LARGE_SPACE),
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
        minWidth: 100,
      ),
      actionsAxis: Axis.vertical,
      actionsOrder: SmoothButtonsBarOrder.auto,
    );
  }
}
