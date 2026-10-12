import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/homepage/header/homepage_flexible_header.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// App logo + scan icon
class HomePageHeaderLogo extends StatelessWidget {
  const HomePageHeaderLogo({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: HomePageFlexibleHeader.CONTENT_PADDING,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: HomePageAppLogo(progress: progress)),
            HomePageHeaderSuffixButton(progress: progress),
          ],
        ),
      ),
    );
  }
}

class HomePageHeaderSuffixButton extends StatelessWidget {
  const HomePageHeaderSuffixButton({required this.progress});

  static const double SIZE_WITHOUT_PREFIX = 48.0;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Positioned.directional(
      top: 0.0,
      bottom: 0.0,
      end: 2.0,
      textDirection: Directionality.of(context),
      child: SizedBox.square(
        dimension:
            SIZE_WITHOUT_PREFIX *
            progress.progressAndClamp(
              // Those values are clearly hand-crafted
              0.55,
              0.90,
              1.0,
            ),
        child: Semantics(
          value: AppLocalizations.of(context).homepage_header_barcode_tooltip,
          excludeSemantics: true,
          child: IconButton(
            icon: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return IconTheme(
                  data: IconThemeData(
                    color: Colors.black,
                    size: math.min(28.0, constraints.minSide),
                  ),
                  child: const icons.Barcode(),
                );
              },
            ),
            onPressed: () => HomePage.of(
              context,
            ).expandCamera(duration: const Duration(milliseconds: 1500)),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                lightTheme ? Colors.white : theme.primaryLight,
              ),
              side: WidgetStateProperty.all(
                BorderSide(color: theme.primaryBlack),
              ),
              foregroundColor: WidgetStateProperty.all(Colors.black),
              shape: WidgetStateProperty.all(const CircleBorder()),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageAppLogo extends StatelessWidget {
  const HomePageAppLogo({required this.progress, super.key});

  /// The image max width
  static const double MAX_WIDTH = 311.0;

  /// The image min height
  static const double MIN_HEIGHT = 35.0;

  /// The image max height
  static const double MAX_HEIGHT = 58.0;

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: HomePageFlexibleHeader.LOGO_CONTENT_PADDING,
      child: SizedBox(
        width: double.infinity,
        height: 60.0,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            double imageWidth = HomePageAppLogo.MAX_WIDTH;

            if (imageWidth > width * 0.8) {
              final double tmp =
                  width - HomePageHeaderSuffixButton.SIZE_WITHOUT_PREFIX;
              imageWidth = math.min(width * 0.8, tmp);
            }

            return Container(
              width: imageWidth,
              height: math.max(
                HomePageAppLogo.MAX_HEIGHT * (1 - progress),
                HomePageAppLogo.MIN_HEIGHT,
              ),
              margin: EdgeInsetsDirectional.only(
                start: math.max(
                  (1 - progress) * ((width - imageWidth) / 2),
                  10.0,
                ),
                bottom: 5.0,
              ),
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: imageWidth * progress.progress2(1.0, 1.0),
                child: SvgPicture(
                  AssetBytesLoader(
                    'assets/app/logo_text_${context.lightTheme() ? 'black' : 'white'}.svg.vec',
                  ),
                  width: 311.0,
                  height: 58.0,
                  alignment: AlignmentDirectional.centerStart,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
