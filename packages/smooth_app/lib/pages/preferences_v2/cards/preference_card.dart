import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

/// A card that contains a list of preference tiles.
/// It is used to group related preferences together.
/// Cards are then displayed as a list in a preferences root.
class PreferenceCard extends StatelessWidget {
  PreferenceCard({required this.title, required this.tiles, super.key})
    : assert(title.isNotEmpty, 'PreferenceCard title must not be empty.'),
      assert(
        tiles.isNotEmpty,
        'PreferenceCard must contain at least one tile.',
      );

  final String title;
  final List<PreferenceTile> tiles;

  @override
  Widget build(BuildContext context) {
    return SmoothCardWithRoundedHeader(
      leading: EMPTY_WIDGET,
      title: title,
      titleTextStyle: Theme.of(context).textTheme.bodyLarge,
      child: Column(children: tiles),
    );
  }
}
