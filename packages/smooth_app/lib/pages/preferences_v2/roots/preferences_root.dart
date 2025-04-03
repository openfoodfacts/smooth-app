import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
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

class PreferencesRoot extends StatelessWidget {
  const PreferencesRoot({
    this.appBar,
    required this.cards,
    this.title,
    super.key,
  });

  final Widget? appBar;
  final List<PreferenceCard> cards;
  final String? title;

  List<PreferenceTile> searchTiles(String query) {
    final List<PreferenceTile> matchingTiles = <PreferenceTile>[];

    for (final PreferenceCard card in cards) {
      for (final PreferenceTile tile in card.tiles) {
        if (tile.keywords.toLowerCase().contains(query.toLowerCase())) {
          matchingTiles.add(tile);
        }

        if (tile.runtimeType == NavigationPreferenceTile &&
            (tile as NavigationPreferenceTile).root != null) {
          matchingTiles.addAll(tile.root!.searchTiles(query));
        }
      }
    }

    return matchingTiles;
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    final PreferencesRootSearchController searchController =
        context.watch<PreferencesRootSearchController>();

    final bool displayTiles =
        searchController.query != null && searchController.query!.isNotEmpty;

    List<PreferenceTile> tiles = <PreferenceTile>[];

    if (displayTiles) {
      tiles = searchTiles(searchController.query!);
    }

    return Scaffold(
      backgroundColor: themeExtension.primaryLight,
      body: CustomScrollView(
        slivers: <Widget>[
          appBar ??
              SliverPinnedHeader(
                child: SmoothTopBar2(
                  title: title ?? 'Preferences',
                  leadingAction: SmoothTopBarLeadingAction.back,
                ),
              ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.only(
              top: LARGE_SPACE,
              start: MEDIUM_SPACE,
              end: MEDIUM_SPACE,
              bottom: MEDIUM_SPACE,
            ),
            sliver: displayTiles
                ? SliverList.separated(
                    itemBuilder: (BuildContext context, int index) =>
                        tiles[index],
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: SMALL_SPACE),
                    itemCount: tiles.length,
                  )
                : SliverList.separated(
                    itemBuilder: (BuildContext context, int index) =>
                        cards[index],
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: LARGE_SPACE),
                    itemCount: cards.length,
                  ),
          ),
        ],
      ),
    );
  }
}
