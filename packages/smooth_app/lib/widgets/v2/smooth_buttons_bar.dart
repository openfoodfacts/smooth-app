import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothButtonsBar2 extends StatelessWidget {
  const SmoothButtonsBar2({
    required this.positiveButton,
    this.negativeButton,
    super.key,
  });

  final SmoothActionButton2 positiveButton;
  final SmoothActionButton2? negativeButton;

  @override
  Widget build(BuildContext context) {
    final double viewPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      constraints: const BoxConstraints(),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.darkTheme() ? Colors.white10 : Colors.black12,
            blurRadius: 6.0,
            offset: const Offset(0.0, -4.0),
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.only(
        start: BALANCED_SPACE,
        end: BALANCED_SPACE,
        top: MEDIUM_SPACE,
        bottom: VERY_SMALL_SPACE + viewPadding,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SmoothPositiveButton2(
              data: positiveButton,
            ),
          ),
          if (negativeButton != null) ...<Widget>[
            const SizedBox(width: MEDIUM_SPACE),
            Expanded(
              child: _SmoothNegativeButton2(
                data: negativeButton!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SmoothActionButton2 {
  SmoothActionButton2({
    required this.text,
    required this.onPressed,
    this.icon,
  }) : assert(text.isNotEmpty);

  final String text;
  final Widget? icon;
  final VoidCallback? onPressed;
}

class _SmoothPositiveButton2 extends StatelessWidget {
  const _SmoothPositiveButton2({required this.data});

  final SmoothActionButton2 data;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: colors.primaryBlack,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: CIRCULAR_BORDER_RADIUS,
        ),
      ),
      onPressed: data.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          AutoSizeText(
            data.text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
            maxLines: 1,
          ),
          if (data.icon != null) ...<Widget>[
            const SizedBox(width: SMALL_SPACE),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 0.5),
              child: SizedBox(
                height: 13.0,
                child: FittedBox(
                  child: data.icon,
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}

// TODO(g123k): Not implemented
class _SmoothNegativeButton2 extends StatelessWidget {
  const _SmoothNegativeButton2({required this.data});

  final SmoothActionButton2 data;

  @override
  Widget build(BuildContext context) {
    throw Exception('Not implemented!');
  }
}
