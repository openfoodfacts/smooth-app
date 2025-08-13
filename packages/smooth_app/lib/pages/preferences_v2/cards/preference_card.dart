import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/square_preference_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    return SmoothCardWithRoundedHeader(
      leading: EMPTY_WIDGET,
      title: title,
      titleSpacing: MEDIUM_SPACE * 2,
      titleTextStyle: Theme.of(context).textTheme.bodyLarge,
      contentPadding: header != null ? EdgeInsets.zero : null,
      titleBackgroundColor: titleBackgroundColor,
      child: gridView
          ? GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: MEDIUM_SPACE,
                left: MEDIUM_SPACE,
                right: MEDIUM_SPACE,
              ),
              mainAxisSpacing: MEDIUM_SPACE,
              crossAxisSpacing: MEDIUM_SPACE,
              children: tiles,
            )
          : Column(
              children: <Widget>[
                if (header != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: ROUNDED_RADIUS,
                      topRight: ROUNDED_RADIUS,
                    ),
                    child: header,
                  ),
                ...tiles,
              ],
            ),
    );
  }
}
