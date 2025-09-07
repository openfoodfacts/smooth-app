import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SearchBottomBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<SearchBottomBar> createState() => _SearchBottomBarState();

  @override
  Size get preferredSize => const Size.fromHeight(SEARCH_BOTTOM_HEIGHT);
}

class _SearchBottomBarState extends State<SearchBottomBar> {
  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();

    final bool lightTheme = context.lightTheme();

    return CustomPaint(
      size: const Size.fromHeight(SEARCH_BOTTOM_HEIGHT),
      painter: _SearchBottomBarBackgroundPainter(
        color: lightTheme
            ? themeExtension.primaryMedium
            : themeExtension.primaryDark,
        radius: ROUNDED_RADIUS,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: LARGE_SPACE + MEDIUM_SPACE,
          start: MEDIUM_SPACE,
          end: MEDIUM_SPACE,
          bottom: BALANCED_SPACE,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: SearchField(
                searchHelper: context.read<PreferencesRootSearchController>(),
                showNavigationButton: false,
                searchOnChange: true,
                hintTextStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBottomBarBackgroundPainter extends CustomPainter {
  _SearchBottomBarBackgroundPainter({
    required Color color,
    required this.radius,
  }) : _paint = Paint()..color = color;

  final Radius radius;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..arcToPoint(Offset(radius.x, radius.y), radius: radius, clockwise: false)
      ..lineTo(size.width - radius.x, radius.y)
      ..arcToPoint(Offset(size.width, 0.0), radius: radius, clockwise: false)
      ..lineTo(size.width, size.height - radius.y)
      ..arcToPoint(
        Offset(size.width - radius.x, size.height),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(radius.x, size.height)
      ..arcToPoint(
        Offset(0.0, size.height - radius.y),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(0.0, 0.0)
      ..close();

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(_SearchBottomBarBackgroundPainter oldDelegate) =>
      radius != oldDelegate.radius || _paint.color != oldDelegate._paint.color;

  @override
  bool shouldRebuildSemantics(_SearchBottomBarBackgroundPainter oldDelegate) =>
      false;
}
