import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';

/// Floating Action Button dedicated to Personal Ranking
class RankingFloatingActionButton extends StatelessWidget {
  const RankingFloatingActionButton({
    required this.color,
    required this.onPressed,
  });

  final Color color;
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
              elevation: 12.0,
              icon: Icon(
                rankingIconData,
                color: color,
              ),
              label: Text(
                AppLocalizations.of(context)!.myPersonalizedRanking,
                style: TextStyle(color: color),
              ),
              backgroundColor: Colors.white,
              onPressed: onPressed,
            ),
          ],
        ),
      );
}
