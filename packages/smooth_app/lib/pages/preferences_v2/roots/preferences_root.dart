import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
  const PreferencesRoot({super.key, this.title, this.customAppBar})
    : assert(
        title != null || customAppBar != null,
        'Either title or customAppBar must be provided',
      );

  final String? title;
  final Widget? customAppBar;

  List<PreferenceCard> getCards(BuildContext context);

  WidgetBuilder? getHeader() => null;

  WidgetBuilder? getFooter() => null;

  List<ExternalSearchPreferenceTile> getExternalSearchTiles(
    BuildContext context,
  ) => <ExternalSearchPreferenceTile>[];

  Widget buildAppBar(BuildContext context) {
    if (customAppBar != null) {
      return customAppBar!;
    }

    return SliverPinnedHeader(
      child: SmoothAppBar(
        title: Text(title!),
        leading: const SmoothBackButton(),
      ),
    );
  }

  List<PreferenceTile> searchTiles(BuildContext context, String query) {
    final List<PreferenceTile> matchingTiles = <PreferenceTile>[];
    final List<PreferenceCard> cards = getCards(context);

    for (final PreferenceCard card in cards) {
      if (card.grid) {
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
    final ThemeData theme = Theme.of(context);

    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) => tiles[index],
      separatorBuilder: (BuildContext context, _) =>
          Divider(color: theme.dividerColor),
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
      backgroundColor: !context.darkTheme()
          ? themeExtension.primaryLight
          : null,
      body: content,
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

    final WidgetBuilder? header = getHeader();
    final WidgetBuilder? footer = getFooter();

    final Widget content = CustomScrollView(
      slivers: <Widget>[
        buildAppBar(context),
        if (header != null) SliverToBoxAdapter(child: header.call(context)),
        SliverPadding(
          padding: EdgeInsetsDirectional.only(
            top: LARGE_SPACE,
            start: displayTiles ? 0.0 : MEDIUM_SPACE,
            end: displayTiles ? 0.0 : MEDIUM_SPACE,
            bottom: VERY_LARGE_SPACE,
          ),
          sliver: displayTiles
              ? buildSearchResults(context, tiles)
              : buildCardsList(context, getCards(context)),
        ),
        if (footer != null) ...<Widget>[
          SliverFillRemaining(
            fillOverscroll: false,
            hasScrollBody: false,
            child: Column(
              children: <Widget>[const Spacer(), footer.call(context)],
            ),
          ),
        ],
      ],
    );

    return buildScaffold(context, content);
  }
}
