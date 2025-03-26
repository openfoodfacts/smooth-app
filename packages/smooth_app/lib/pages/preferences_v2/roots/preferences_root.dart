import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/navigation_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class PreferencesRootSearchController extends ChangeNotifier {
  PreferencesRootSearchController();

  String? query;

  void search(String? keywords) {
    query = keywords;
    notifyListeners();
  }
}

class PreferencesRoot extends StatefulWidget {
  const PreferencesRoot({
    this.searchController,
    this.appBar,
    required this.cards,
    super.key,
  });

  final PreferencesRootSearchController? searchController;
  final Widget? appBar;
  final List<PreferenceCard> cards;

  @override
  State<PreferencesRoot> createState() => _PreferencesRootState();

  List<PreferenceTile> searchTiles(String query) {
    final List<PreferenceTile> matchingTiles = <PreferenceTile>[];

    for (final PreferenceCard card in cards) {
      for (final PreferenceTile tile in card.tiles) {
        if (tile.keywords.toLowerCase().contains(query.toLowerCase())) {
          matchingTiles.add(tile);
        }

        if (tile.runtimeType == NavigationPreferenceTile) {
          matchingTiles.addAll(
            (tile as NavigationPreferenceTile).root.searchTiles(query),
          );
        }
      }
    }

    return matchingTiles;
  }
}

class _PreferencesRootState extends State<PreferencesRoot> {
  @override
  void initState() {
    super.initState();

    widget.searchController?.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension =
        context.extension<SmoothColorsThemeExtension>();

    final bool displayTiles = widget.searchController != null &&
        widget.searchController!.query != null &&
        widget.searchController!.query!.isNotEmpty;

    List<PreferenceTile> tiles = [];

    if (displayTiles) {
      tiles = widget.searchTiles(widget.searchController!.query!);
    }

    return Scaffold(
      backgroundColor: themeExtension.primaryLight,
      body: CustomScrollView(
        slivers: <Widget>[
          widget.appBar ??
              SliverAppBar(
                title: const Text('Paramètres'),
                pinned: true,
                floating: true,
                backgroundColor: themeExtension.primaryMedium,
                collapsedHeight: 86.0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: ROUNDED_RADIUS,
                  ),
                ),
              ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
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
                        widget.cards[index],
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: LARGE_SPACE),
                    itemCount: widget.cards.length,
                  ),
          ),
        ],
      ),
    );
  }
}
