import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

// TODO(monsieurtanuki): we should probably remove that class to avoid confusion with the "compare" button
/// Floating Action Button dedicated to Personal Ranking
class RankingFloatingActionButton extends StatelessWidget {
  const RankingFloatingActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SmoothRevealAnimation(
    animationCurve: Curves.easeInOutBack,
    startOffset: const Offset(0.0, 1.0),
    child: Container(
      height: MINIMUM_TOUCH_SIZE,
      margin: EdgeInsetsDirectional.only(
        start: MediaQuery.widthOf(context) * 0.09,
      ),
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(borderRadius: CIRCULAR_BORDER_RADIUS),
          ),
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(64.0, MINIMUM_TOUCH_SIZE),
          ),
        ),
        icon: const icons.Trophy(),
        label: AutoSizeText(
          AppLocalizations.of(context).myPersonalizedRanking,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}
