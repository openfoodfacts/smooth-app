import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/external_search_tiles/external_search_preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart';

class GithubSearchPreferenceTile extends ExternalSearchPreferenceTile {
  GithubSearchPreferenceTile() : super(icon: const GitHub().icon);

  @override
  String buildTitle(BuildContext context, String keyword) {
    return AppLocalizations.of(context).external_search_tile_title(
      'GitHub',
      keyword,
    );
  }

  @override
  String getSearchUrl(BuildContext context, String? keyword) {
    return 'https://github.com/search?q=org%3Aopenfoodfacts+$keyword&type=repositories';
  }
}
