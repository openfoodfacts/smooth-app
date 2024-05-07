import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
            Flexible(
              child: SizedBox(
                height: MINIMUM_TOUCH_SIZE,
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                    ),
                  ),
                  icon: const Icon(rankingIconData),
                  label: AutoSizeText(
                    AppLocalizations.of(context).myPersonalizedRanking,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
          ],
        ),
      );
}
