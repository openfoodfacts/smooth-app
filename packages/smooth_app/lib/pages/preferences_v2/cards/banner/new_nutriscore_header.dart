import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class NutriScoreV2Banner extends StatelessWidget {
  const NutriScoreV2Banner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 128.0),
      child: Material(
        color: extension.success,
        child: InkWell(
          onTap: () =>
              AppNavigator.of(context).push(AppRoutes.GUIDE_NUTRISCORE_V2),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 55,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _TipsWidget(),
                        SizedBox(
                          height:
                              MediaQuery.textScalerOf(context).scale(18.0) * 3,
                          child: Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: AutoSizeText(
                              appLocalizations.tips_discover_nutriscore,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                wordSpacing: 0.4,
                                letterSpacing: 0.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  flex: 45,
                  child: Stack(
                    children: <Widget>[
                      _IllustrationWidget(),
                      PositionedDirectional(
                        bottom: MEDIUM_SPACE,
                        end: MEDIUM_SPACE,
                        child: _ChevronWidget(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipsWidget extends StatelessWidget {
  const _TipsWidget();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 7.0,
              end: 7.0,
              top: 6.0,
              bottom: 7.0,
            ),
            decoration: BoxDecoration(
              color: extension.success.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: const icons.LightBulb(color: Colors.white, size: 20.0),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: BALANCED_SPACE,
              end: LARGE_SPACE,
              bottom: 1.5,
            ),
            child: Text(
              appLocalizations.preferences_tips,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
                color: context.lightTheme() ? Colors.white : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationWidget extends StatelessWidget {
  const _IllustrationWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                Colors.white70,
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        PositionedDirectional(
          top: 24.0,
          end: 32.0,
          child: Transform.rotate(
            angle: math.pi / 3,
            child: Opacity(
              opacity: 0.4,
              child: SvgPicture.asset(
                'assets/cache/nutriscore-e.svg',
                width: 42.0,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: 24.0,
          end: 48.0,
          child: Transform.rotate(
            angle: math.pi / 6,
            child: Opacity(
              opacity: 0.75,
              child: SvgPicture.asset(
                'assets/cache/nutriscore-a.svg',
                width: 56.0,
              ),
            ),
          ),
        ),
        SvgPicture.asset(
          SvgCache.getAssetsCacheForNutriscore(NutriScoreValue.a, true),
          width: 86.0,
        ),
      ],
    );
  }
}

class _ChevronWidget extends StatelessWidget {
  const _ChevronWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 32.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: const Padding(
          padding: EdgeInsetsDirectional.only(
            top: SMALL_SPACE,
            bottom: SMALL_SPACE,
            start: SMALL_SPACE,
            end: SMALL_SPACE - 2.0,
          ),
          child: icons.Chevron.right(color: Colors.white, size: 14.0),
        ),
      ),
    );
  }
}
