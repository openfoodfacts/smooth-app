import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class WikiSearchPreferenceTile extends ExternalSearchPreferenceTile {
  const WikiSearchPreferenceTile() : super(icon: const icons.Countries());

  @override
  String buildTitle(BuildContext context, String keyword) =>
      AppLocalizations.of(context).external_search_tile_title('Wiki', keyword);

  @override
  String getSearchUrl(BuildContext context, String keyword) =>
      'https://wiki.openfoodfacts.org/index.php?search=${Uri.encodeComponent(keyword)}&title=Special%3ASearch&go=Lire';
}
