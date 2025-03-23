import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class PreferenceCard extends StatelessWidget {
  const PreferenceCard({
    required this.title,
    required this.tiles,
    super.key,
  });

  final String title;
  final List<PreferenceTile> tiles;

  @override
  Widget build(BuildContext context) {
    return SmoothCardWithRoundedHeader(
      leading: const SizedBox.square(dimension: 0.0),
      title: title,
      child: Column(
        children: tiles.map((PreferenceTile tile) => tile).toList(),
      ),
    );
  }
}
