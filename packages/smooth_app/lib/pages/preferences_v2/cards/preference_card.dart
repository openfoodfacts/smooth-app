import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/square_preference_tile.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A card that contains a list of [PreferenceTile].
/// It is used to group related preferences together.
/// Cards are then displayed as a list in a [PreferencesRoot].
class PreferenceCard extends StatelessWidget {
  PreferenceCard({
    required this.title,
    required this.tiles,
    this.gridView = false,
    this.header,
    this.titleBackgroundColor,
    this.bannerText,
    super.key,
  }) : assert(title.isNotEmpty, 'PreferenceCard title must not be empty.'),
       assert(
         tiles.isNotEmpty,
         'PreferenceCard must contain at least one tile.',
       ),
       assert(
         !gridView ||
             tiles.every(
               (PreferenceTile tile) =>
                   tile.runtimeType == SquarePreferenceTile,
             ),
         'When gridView is true, all tiles must be of type SquarePreferenceTile.',
       ),
       assert(
         header == null || !gridView,
         'Header must be null when gridView is true.',
       );

  final String title;
  final List<PreferenceTile> tiles;
  final bool gridView;
  final Widget? header;
  final Color? titleBackgroundColor;
  final String? bannerText;

  @override
  Widget build(BuildContext context) {
    const double leadingMargin = 6.0;

    return SmoothCardWithRoundedHeader(
      leading: EMPTY_WIDGET,
      leadingMargin: const EdgeInsetsDirectional.only(start: leadingMargin),
      title: title,
      banner: bannerText != null
          ? Padding(
              padding: const EdgeInsets.all(MEDIUM_SPACE),
              child: Text(bannerText!),
            )
          : null,
      titleSpacing: MEDIUM_SPACE * 2 - leadingMargin / 2,
      contentPadding: !gridView ? EdgeInsets.zero : null,
      clipBehavior: Clip.antiAlias,
      titleBackgroundColor:
          titleBackgroundColor ??
          (context.lightTheme() ? null : const Color(0xFF322219)),
      child: gridView
          ? GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.only(
                bottom: MEDIUM_SPACE,
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
              ),
              mainAxisSpacing: MEDIUM_SPACE,
              crossAxisSpacing: MEDIUM_SPACE,
              children: tiles,
            )
          : Column(
              children: <Widget>[
                if (header != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: ROUNDED_RADIUS,
                      bottom: ROUNDED_RADIUS,
                    ),
                    child: header,
                  ),
                ..._getTilesWithDividers(context),
              ],
            ),
    );
  }

  // This function adds a divider between each tile
  List<Widget> _getTilesWithDividers(BuildContext context) {
    final bool lightTheme = context.lightTheme();

    final List<Widget> tilesWithDividers = <Widget>[];
    for (int i = 0; i < tiles.length; i++) {
      if (i > 0) {
        tilesWithDividers.add(
          Divider(color: lightTheme ? Colors.grey[300] : Colors.grey[800]),
        );
      }
      tilesWithDividers.add(tiles[i]);
    }
    return tilesWithDividers;
  }
}
