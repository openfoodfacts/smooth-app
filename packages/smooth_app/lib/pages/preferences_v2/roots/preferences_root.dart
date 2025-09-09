import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

class PreferencesRootSearchController extends SearchHelper {
  PreferencesRootSearchController();

  String? query;

  @override
  void search(
    BuildContext context,
    String? keywords, {
    required Function(String) searchQueryCallback,
  }) {
    query = keywords;
    notifyListeners();
  }

  @override
  String getHintText(AppLocalizations appLocalizations) {
    return appLocalizations.preferences_app_bar_search_hint;
  }

  @override
  String get historyKey => 'preferences_root_search_history';
}

/// Base class for all preference roots.
/// [PreferencesRoot] corresponds to a page where each root can have its own
/// app bar and cards.
/// The [getCards] method should be overridden to provide the cards for the root.
/// The [getExternalSearchTiles] method can be overridden to provide external
/// search tiles for the root which will be displayed in the search results only.
/// The [buildAppBar] method can be overridden to provide a custom app bar for
/// the root.
/// The [PreferencesRoot] also handles the search logic. When the user searches
/// for a tile, the cards are replaced by individual tiles that match the search
/// query.
/// The search query is performed deep in the widget tree.
abstract class PreferencesRoot extends StatelessWidget {
  const PreferencesRoot({
    super.key,
    this.title,
    this.customAppBar,
    this.changeStatusBarBrightness,
  }) : assert(
         title != null || customAppBar != null,
         'Either title or customAppBar must be provided',
       );

  final String? title;
  final Widget? customAppBar;
  final bool? changeStatusBarBrightness;

  List<PreferenceCard> getCards(BuildContext context);

  Widget getBottom(BuildContext context) => EMPTY_WIDGET;

  List<ExternalSearchPreferenceTile> getExternalSearchTiles(
    BuildContext context,
  ) => <ExternalSearchPreferenceTile>[];

  Widget buildAppBar(BuildContext context) =>
      customAppBar ??
      SliverPinnedHeader(
        child: SmoothTopBar2(
          title: title!,
          leadingAction: SmoothLeadingAction.back,
        ),
      );

  List<PreferenceTile> searchTiles(BuildContext context, String query) {
    final List<PreferenceTile> matchingTiles = <PreferenceTile>[];
    final List<PreferenceCard> cards = getCards(context);

    for (final PreferenceCard card in cards) {
      if (card.gridView) {
        continue;
      }

      for (final PreferenceTile tile in card.tiles) {
        if (tile.keywords.toLowerCase().contains(query.toLowerCase())) {
          matchingTiles.add(tile);
        }

        if (tile is NavigationPreferenceTile && tile.root != null) {
          matchingTiles.addAll(tile.root!.searchTiles(context, query));
        }
      }
    }

    return matchingTiles;
  }

  Widget buildSearchResults(BuildContext context, List<PreferenceTile> tiles) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) => tiles[index],
      separatorBuilder: (BuildContext context, _) => const Divider(),
      itemCount: tiles.length,
    );
  }

  Widget buildCardsList(BuildContext context, List<PreferenceCard> cards) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) => cards[index],
      separatorBuilder: (BuildContext context, _) =>
          const SizedBox(height: LARGE_SPACE),
      itemCount: cards.length,
    );
  }

  void prepareForBuild(BuildContext context) {}

  Widget buildScaffold(BuildContext context, Widget content) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    return SmoothScaffold(
      changeStatusBarBrightness: changeStatusBarBrightness ?? true,
      backgroundColor: !context.darkTheme()
          ? themeExtension.primaryLight
          : null,
      body: Stack(
        children: <Widget>[
          content,
          PositionedDirectional(
            bottom: 0.0,
            end: 0.0,
            start: 0.0,
            child: getBottom(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    prepareForBuild(context);

    final PreferencesRootSearchController searchController = context
        .watch<PreferencesRootSearchController>();

    final bool displayTiles =
        searchController.query != null && searchController.query!.isNotEmpty;

    List<PreferenceTile> tiles = <PreferenceTile>[];
    if (displayTiles) {
      tiles = <PreferenceTile>[
        ...searchTiles(context, searchController.query!),
        ...getExternalSearchTiles(context),
      ];
    }

    final Widget content = CustomScrollView(
      slivers: <Widget>[
        buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsetsDirectional.only(
            top: LARGE_SPACE,
            start: MEDIUM_SPACE,
            end: MEDIUM_SPACE,
            bottom: MEDIUM_SPACE,
          ),
          sliver: displayTiles
              ? buildSearchResults(context, tiles)
              : buildCardsList(context, getCards(context)),
        ),
      ],
    );

    return buildScaffold(context, content);
  }
}
