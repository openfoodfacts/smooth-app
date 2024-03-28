import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';

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
            Flexible(
              fit: FlexFit.tight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: FloatingActionButton.extended(
                  heroTag: 'ranking_fab_${Random().nextInt(100)}',
                  elevation: 12.0,
                  icon: const Icon(rankingIconData),
                  label: AutoSizeText(
                    AppLocalizations.of(context).myPersonalizedRanking,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  onPressed: onPressed,
                ),
              ),
            ),
          ],
        ),
      );
}
