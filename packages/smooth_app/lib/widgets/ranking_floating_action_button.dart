import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';

// TODO(monsieurtanuki): we should probably remove that class to avoid confusion with the "compare" button
/// Floating Action Button dedicated to Personal Ranking
class RankingFloatingActionButton extends StatelessWidget {
  const RankingFloatingActionButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  static const IconData rankingIconData = Icons.emoji_events_outlined;

  @override
  Widget build(BuildContext context) => SmoothRevealAnimation(
        animationCurve: Curves.easeInOutBack,
        startOffset: const Offset(0.0, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: MediaQuery.of(context).size.width * 0.09),
            FloatingActionButton.extended(
              heroTag: 'ranking_fab_${Random(100)}',
              elevation: 12.0,
              icon: const Icon(rankingIconData),
              label: Text(AppLocalizations.of(context).myPersonalizedRanking),
              onPressed: onPressed,
            ),
          ],
        ),
      );
}
