import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class OnboardingBottomHills extends StatelessWidget {
  const OnboardingBottomHills({required this.onTap, super.key});

  final VoidCallback onTap;

  static double height(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    return screenHeight * (0.12 + (bottomPadding / screenHeight));
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    if (bottomPadding == 0) {
      // Add a slight padding for devices without a transparent nav bar
      // (eg: iPhone SE)
      bottomPadding = 4.0;
    }

    final double maxHeight = OnboardingBottomHills.height(context);
    final SmoothColorsThemeExtension colors = Theme.of(
      context,
    ).extension<SmoothColorsThemeExtension>()!;

    return Positioned(
      top: null,
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      height: maxHeight,
      child: SizedBox(
        child: Stack(
          children: <Widget>[
            Positioned.directional(
              start: 0.0,
              bottom: 0.0,
              textDirection: textDirection,
              child: SvgPicture.asset(
                'assets/onboarding/hill_start.svg',
                height: maxHeight,
              ),
            ),
            Positioned.directional(
              end: 0.0,
              bottom: 0.0,
              textDirection: textDirection,
              child: SvgPicture.asset(
                'assets/onboarding/hill_end.svg',
                height: maxHeight * 0.965,
              ),
            ),
            Positioned.directional(
              textDirection: textDirection,
              bottom: bottomPadding + (Platform.isIOS ? 0.0 : 15.0),
              end: 15.0,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsetsDirectional.only(
                      start: LARGE_SPACE + 1.0,
                      end: LARGE_SPACE,
                      top: SMALL_SPACE,
                      bottom: SMALL_SPACE,
                    ),
                  ),
                  elevation: WidgetStateProperty.all<double>(4.0),
                  iconColor: WidgetStateProperty.all<Color>(
                    colors.secondaryVibrant,
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(
                    colors.secondaryVibrant,
                  ),
                  iconSize: WidgetStateProperty.all<double>(21.0),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  shadowColor: WidgetStateProperty.all<Color>(
                    Colors.black.withValues(alpha: 0.50),
                  ),
                ),
                onPressed: onTap,
                child: Row(
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).onboarding_continue_button,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                    const SizedBox(width: LARGE_SPACE),
                    const icons.Arrow.right(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
