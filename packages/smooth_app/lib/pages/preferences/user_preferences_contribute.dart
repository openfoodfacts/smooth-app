import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:smooth_app/pages/hunger_games/question_page.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/product/common/country_wiki_links.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

/// Display of "Contribute" for the preferences page.
class UserPreferencesContribute extends AbstractUserPreferences {
  UserPreferencesContribute({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.CONTRIBUTE;

  @override
  String getTitleString() => appLocalizations.contribute;

  @override
  IconData getLeadingIconData() => Icons.emoji_people;

  @override
  String? getHeaderAsset() => 'assets/preferences/contribute.svg';

  @override
  Color? getHeaderColor() => const Color(0xFFFFF2DF);

  @override
  List<UserPreferencesItem> getChildren() {
    final OpenFoodFactsCountry country = ProductQuery.getCountry();

    final TmpCountryWikiLinks links = TmpCountryWikiLinks();
    return <UserPreferencesItem>[
      _getListTile(
        'Hunger Games',
        () async => _hungerGames(),
        Icons.games,
      ),
      _getListTile(
        appLocalizations.contribute_improve_header,
        () async => _contribute(),
        Icons.data_saver_on,
      ),
      _getListTile(
        appLocalizations.contribute_sw_development,
        () async => _develop(),
        Icons.app_shortcut,
      ),
      _getListTile(
        appLocalizations.contribute_translate_header,
        () async => _translate(),
        Icons.translate,
      ),
      _getListTile(
        appLocalizations.how_to_contribute,
        () async => LaunchUrlHelper.launchURL(
          ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/contribute',
          ),
        ),
        Icons.volunteer_activism_outlined,
        externalLink: true,
      ),
      _getListTile(
        appLocalizations.contribute_join_skill_pool,
        () async => LaunchUrlHelper.launchURL(
          'https://connect.openfoodfacts.org/join-the-contributor-skill-pool-open-food-facts',
        ),
        Icons.group,
        externalLink: true,
      ),
      _getListTile(
        appLocalizations.contribute_share_header,
        () async => _share(appLocalizations.contribute_share_content),
        Icons.adaptive.share,
      ),
      if (links.wikiLinks.containsKey(country))
        _getListTile(
          appLocalizations.help_improve_country,
          () async {
            LaunchUrlHelper.launchURL(links.wikiLinks[country]!);
          },
          Icons.language,
          icon: UserPreferencesListTile.getTintedIcon(
            Icons.open_in_new,
            context,
          ),
          externalLink: true,
        ),
      if (GlobalVars.appStore.getEnrollInBetaURL() != null)
        _getListTile(
          appLocalizations.contribute_enroll_alpha,
          () async {
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
          },
          CupertinoIcons.lab_flask_solid,
          icon: UserPreferencesListTile.getTintedIcon(
            Icons.open_in_new,
            context,
          ),
          externalLink: true,
        ),
      _getListTile(
        appLocalizations.contributors_label,
        () async => _contributors(),
        Icons.emoji_people,
        description: appLocalizations.contributors_description,
      ),
    ];
  }

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
              ],
            ),
            positiveAction: SmoothActionButton(
              text: AppLocalizations.of(context)
                  .contribute_improve_ProductsToBeCompleted,
              onPressed: () async {
                final LocalDatabase localDatabase =
                    context.read<LocalDatabase>();
                Navigator.of(context).pop();
                ProductQueryPageHelper.openBestChoice(
                  name: appLocalizations.all_search_to_be_completed_title,
                  localDatabase: localDatabase,
                  productQuery: PagedToBeCompletedProductQuery(
                    // TODO(monsieurtanuki): only food?
                    productType: ProductType.food,
                  ),
                  // the other "context"s being popped
                  context: this.context,
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

  Future<void> _develop() => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          context.watch<UserPreferences>();
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
                const SizedBox(height: 10),
                UserPreferencesSwitchWidget(
                  title: appLocalizations.contribute_develop_dev_mode_title,
                  subtitle:
                      appLocalizations.contribute_develop_dev_mode_subtitle,
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
              onPressed: () async => LaunchUrlHelper.launchURL(
                'https://translate.openfoodfacts.org/',
              ),
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

  Future<void> _share(String content) async => Share.share(content);

  Future<void> _contributors() => showDialog<void>(
        context: context,
        builder: (BuildContext context) => _ContributorsDialog(),
      );

  Future<void> _hungerGames() async {
    // Track the hunger game analytics event
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.hungerGameOpened,
    );
    await openQuestionPage(context);
  }

  UserPreferencesItem _getListTile(
    final String title,
    final VoidCallback onTap,
    final IconData leading, {
    final Icon? icon,
    final String? description,
    final bool? externalLink = false,
  }) {
    final Widget tile = UserPreferencesListTile(
      title: Text(title),
      onTap: onTap,
      trailing: icon ?? getForwardIcon(),
      leading: UserPreferencesListTile.getTintedIcon(leading, context),
      externalLink: externalLink,
    );

    if (description != null) {
      return UserPreferencesItemSimple(
        labels: <String>[title, description],
        builder: (_) => Semantics(
          value: title,
          hint: description,
          button: true,
          excludeSemantics: true,
          child: tile,
        ),
      );
    }
    return UserPreferencesItemSimple(
      labels: <String>[title],
      builder: (_) => tile,
    );
  }
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
                  children: contributors.map((dynamic contributorsData) {
                    final ContributorsModel contributor =
                        ContributorsModel.fromJson(
                            contributorsData as Map<String, dynamic>);
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
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
                  }).toList(growable: false),
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
