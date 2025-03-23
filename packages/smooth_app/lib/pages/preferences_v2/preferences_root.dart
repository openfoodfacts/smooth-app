import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class PreferencesRoot extends StatelessWidget {
  const PreferencesRoot({
    required this.cards,
    super.key,
  });

  final List<PreferenceCard> cards;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) => cards[index],
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12.0),
      itemCount: cards.length,
    );
  }

  /// Searches for tiles that match the given query.
  List<PreferenceTile> searchTiles(String query) {
    final List<PreferenceTile> matchingTiles = <PreferenceTile>[];

    for (PreferenceCard card in cards) {
      for (PreferenceTile tile in card.tiles) {
        if (tile.keywords.toLowerCase().contains(query.toLowerCase())) {
          matchingTiles.add(tile);
        }

        if (tile.runtimeType == NavigationPreferenceTile) {
          final NavigationPreferenceTile navigationTile =
              tile as NavigationPreferenceTile;
          if (navigationTile.keywords
              .toLowerCase()
              .contains(query.toLowerCase())) {
            matchingTiles.add(tile);
          }
        }
      }
    }
  }
}
