import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';

class NewNutriscoreHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool lightTheme = context.lightTheme();

    return Stack(
      children: <Widget>[
        Material(
          color: const Color(0xFF219653),
          child: InkWell(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const GuideNutriscoreV2(),
              ),
            ),
            child: SizedBox(
              height: 128.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(LARGE_SPACE),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(SMALL_SPACE),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(40),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: const Center(
                                    child: icons.LightBulb(color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: SMALL_SPACE,
                                    end: MEDIUM_SPACE,
                                  ),
                                  child: Text(
                                    appLocalizations.preferences_tips,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: lightTheme ? Colors.white : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            appLocalizations.tips_discover_nutriscore,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              wordSpacing: 0.4,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Stack(
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
                              angle: pi / 3,
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
                              angle: pi / 6,
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
                            'assets/cache/nutriscore-a-new-en.svg',
                            width: 86.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MEDIUM_SPACE,
          right: LARGE_SPACE,
          child: Container(
            width: 32.0,
            height: 32.0,
            padding: const EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              bottom: SMALL_SPACE,
              start: SMALL_SPACE,
              end: SMALL_SPACE - 2.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: const icons.Chevron.right(color: Colors.white, size: 14.0),
          ),
        ),
      ],
    );
  }
}
