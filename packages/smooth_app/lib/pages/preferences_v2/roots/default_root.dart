import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class DefaultPreferencesRoot extends PreferencesRoot {
  const DefaultPreferencesRoot({
    required this.cards,
    super.customAppBar,
    this.externalSearchTiles = const <ExternalSearchPreferenceTile>[],
    this.searchRoots = const <PreferencesRoot>[],
    this.header,
    this.footer,
    super.key,
  });

  final List<PreferenceCard> cards;
  final List<ExternalSearchPreferenceTile> externalSearchTiles;
  final List<PreferencesRoot> searchRoots;
  final WidgetBuilder? header;
  final WidgetBuilder? footer;

  @override
  State<PreferencesRoot> createState() => PreferencesRootState();

  @override
  List<PreferenceCard> getCards(BuildContext context) => cards;

  @override
  List<PreferenceTile> searchTiles(BuildContext context, String query) {
    final List<PreferenceTile> tiles = <PreferenceTile>[
      ...super.searchTiles(context, query),
      for (final PreferencesRoot root in searchRoots)
        ...root.searchTiles(context, query),
    ];
    final Set<Key> seenKeys = <Key>{};
    return tiles.where((PreferenceTile tile) {
      if (tile.key != null) {
        return seenKeys.add(tile.key!);
      }
      return true;
    }).toList();
  }

  @override
  WidgetBuilder? getFooter() => footer;

  @override
  WidgetBuilder? getHeader() => header;

  @override
  List<ExternalSearchPreferenceTile> getExternalSearchTiles(
    BuildContext context,
  ) => externalSearchTiles;
}
