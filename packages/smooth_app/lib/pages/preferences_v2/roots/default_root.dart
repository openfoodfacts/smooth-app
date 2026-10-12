import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';

class DefaultPreferencesRoot extends PreferencesRoot {
  const DefaultPreferencesRoot({
    required this.cards,
    super.customAppBar,
    this.externalSearchTiles = const <ExternalSearchPreferenceTile>[],
    this.header,
    this.footer,
    super.key,
  });

  final List<PreferenceCard> cards;
  final List<ExternalSearchPreferenceTile> externalSearchTiles;
  final WidgetBuilder? header;
  final WidgetBuilder? footer;

  @override
  List<PreferenceCard> getCards(BuildContext context) => cards;

  @override
  WidgetBuilder? getFooter() => footer;

  @override
  WidgetBuilder? getHeader() => header;

  @override
  List<ExternalSearchPreferenceTile> getExternalSearchTiles(
    BuildContext context,
  ) => externalSearchTiles;
}
