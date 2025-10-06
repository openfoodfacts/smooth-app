import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class GithubSearchPreferenceTile extends ExternalSearchPreferenceTile {
  const GithubSearchPreferenceTile() : super(icon: const icons.GitHub());

  @override
  String buildTitle(BuildContext context, String keyword) =>
      AppLocalizations.of(
        context,
      ).external_search_tile_title('GitHub', keyword);

  @override
  String getSearchUrl(BuildContext context, String keyword) =>
      'https://github.com/search?q=org%3Aopenfoodfacts+${Uri.encodeComponent(keyword)}&type=issues';
}
