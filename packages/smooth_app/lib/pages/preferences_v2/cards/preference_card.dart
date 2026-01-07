import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/square_preference_tile.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A card that contains a list of [PreferenceTile].
/// It is used to group related preferences together.
/// Cards are then displayed as a list in a [PreferencesRoot].
class PreferenceCard extends StatelessWidget {
  PreferenceCard({
    required this.tiles,
    this.title,
    this.grid = false,
    this.header,
    this.titleBackgroundColor,
    this.bannerText,
    super.key,
  }) : assert(
         title == null || title.isNotEmpty,
         'PreferenceCard title must not be empty.',
       ),
       assert(
         tiles.isNotEmpty,
         'PreferenceCard must contain at least one tile.',
       ),
       assert(
         !grid ||
             tiles.every(
               (PreferenceTile tile) =>
                   tile.runtimeType == SquarePreferenceTile,
             ),
         'When gridView is true, all tiles must be of type SquarePreferenceTile.',
       ),
       assert(
         header == null || !grid,
         'Header must be null when gridView is true.',
       );

  final String? title;
  final List<PreferenceTile> tiles;
  final bool grid;
  final Widget? header;
  final Color? titleBackgroundColor;
  final String? bannerText;

  @override
  Widget build(BuildContext context) {
    const double leadingMargin = 6.0;

    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return SmoothCardWithRoundedHeader(
      leading: EMPTY_WIDGET,
      leadingMargin: const EdgeInsetsDirectional.only(start: leadingMargin),
      title: title,
      titlePadding: const EdgeInsetsDirectional.symmetric(
        vertical: 14.0,
        horizontal: LARGE_SPACE,
      ),
      titleTextStyle: Theme.of(
        context,
      ).textTheme.displaySmall!.copyWith(fontSize: 16.5),
      titleBackgroundColor:
          titleBackgroundColor ??
          context.nullableColorThemeValue(
            light: null,
            dark: Colors.black87,
            amoled: extension.primaryUltraBlack.withValues(alpha: 0.6),
          ),

      banner: bannerText != null
          ? Padding(
              padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
              child: Text(bannerText!),
            )
          : null,
      titleSpacing: MEDIUM_SPACE * 2 - leadingMargin / 2,
      contentPadding: !grid ? EdgeInsetsDirectional.zero : null,
      clipBehavior: Clip.antiAlias,
      contentBackgroundColor: context.colorThemeValue(
        light: Colors.white,
        dark: extension.primaryUltraBlack,
        amoled: extension.primaryUltraBlack,
      ),
      child: grid
          ? IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: MEDIUM_SPACE,
                  start: MEDIUM_SPACE,
                  end: MEDIUM_SPACE,
                ),
                child: Row(
                  spacing: MEDIUM_SPACE,
                  children: tiles
                      .map((PreferenceTile tile) => Expanded(child: tile))
                      .toList(growable: false),
                ),
              ),
            )
          : Column(
              children: <Widget>[
                if (header != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: ROUNDED_RADIUS,
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
          Divider(color: lightTheme ? Colors.grey[300] : Colors.grey[700]),
        );
      }
      tilesWithDividers.add(tiles[i]);
    }
    return tilesWithDividers;
  }
}
