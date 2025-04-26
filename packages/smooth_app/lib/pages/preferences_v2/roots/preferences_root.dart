import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

class PreferencesRootSearchController extends ChangeNotifier {
  PreferencesRootSearchController();

  String? query;

  void search(String? keywords) {
    query = keywords;
    notifyListeners();
  }
}

abstract class PreferencesRoot extends StatelessWidget {
  const PreferencesRoot({
    super.key,
    this.title,
    this.customAppBar,
  });

  final String? title;
  final Widget? customAppBar;

  List<PreferenceCard> getCards(BuildContext context);

  List<ExternalSearchPreferenceTile> getExternalSearchTiles(
          BuildContext context) =>
      <ExternalSearchPreferenceTile>[];

  Widget buildAppBar(BuildContext context) =>
      customAppBar ??
      SliverPinnedHeader(
        child: SmoothTopBar2(
          title: title ?? 'Preferences',
          leadingAction: SmoothTopBarLeadingAction.back,
        ),
      );

  List<PreferenceTile> searchTiles(BuildContext context, String query) {
    final List<PreferenceTile> matchingTiles = <PreferenceTile>[];
    final List<PreferenceCard> cards = getCards(context);

    for (final PreferenceCard card in cards) {
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
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: SMALL_SPACE),
      itemCount: tiles.length,
    );
  }

  Widget buildCardsList(BuildContext context, List<PreferenceCard> cards) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) => cards[index],
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: LARGE_SPACE),
      itemCount: cards.length,
    );
  }

  void prepareForBuild(BuildContext context) {}

  Widget buildScaffold(BuildContext context, Widget content) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    return Scaffold(
      backgroundColor: themeExtension.primaryLight,
      body: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    prepareForBuild(context);

    final PreferencesRootSearchController searchController =
        context.watch<PreferencesRootSearchController>();

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
