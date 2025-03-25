import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class PreferencesRoot extends StatelessWidget {
  const PreferencesRoot({
    this.appBar,
    required this.cards,
    super.key,
  });

  final SliverAppBar? appBar;
  final List<PreferenceCard> cards;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar ??
              SliverAppBar(
                title: const Text('Paramètres'),
                pinned: true,
                floating: true,
                backgroundColor: theme.dialogBackgroundColor,
              ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.separated(
              itemBuilder: (BuildContext context, int index) => cards[index],
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
              itemCount: cards.length,
            ),
          ),
        ],
      ),
    );
  }

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
