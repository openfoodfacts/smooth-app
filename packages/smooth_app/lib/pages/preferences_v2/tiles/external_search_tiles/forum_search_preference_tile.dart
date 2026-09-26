import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ForumSearchPreferenceTile extends ExternalSearchPreferenceTile {
  const ForumSearchPreferenceTile() : super(icon: const icons.Forum());

  @override
  String buildTitle(BuildContext context, String keyword) =>
      AppLocalizations.of(context).external_search_tile_title('Forum', keyword);

  @override
  String getSearchUrl(BuildContext context, String keyword) =>
      'https://forum.openfoodfacts.org/search?q=${Uri.encodeComponent(keyword)}';
}
