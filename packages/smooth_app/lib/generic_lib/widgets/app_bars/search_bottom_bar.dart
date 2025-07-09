import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
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
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool lightTheme = context.lightTheme();

    return SizedBox(
      height: SEARCH_BOTTOM_HEIGHT,
      child: CustomPaint(
        painter: _SearchBottomBarBackgroundPainter(
          color: lightTheme
              ? themeExtension.primaryMedium
              : themeExtension.primaryDark,
          radius: ROUNDED_RADIUS,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: LARGE_SPACE * 2,
            start: MEDIUM_SPACE,
            end: MEDIUM_SPACE,
            bottom: MEDIUM_SPACE,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SmoothTextFormField(
                  type: TextFieldTypes.PLAIN_TEXT,
                  controller: _controller,
                  hintText: appLocalizations.preferences_app_bar_search_hint,
                  maxLines: 1,
                  outlined: true,
                  suffixIcon: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: ROUNDED_BORDER_RADIUS,
                      color: theme.primaryColor,
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                  onChanged: (String? value) {
                    context.read<PreferencesRootSearchController>().search(
                      value,
                    );
                  },
                ),
              ),
            ],
          ),
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
      ..moveTo(0, 0)
      ..arcToPoint(Offset(radius.x, radius.y), radius: radius, clockwise: false)
      ..lineTo(size.width - radius.x, radius.y)
      ..arcToPoint(Offset(size.width, 0), radius: radius, clockwise: false)
      ..lineTo(size.width, size.height - radius.y)
      ..arcToPoint(
        Offset(size.width - radius.x, size.height),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(radius.x, size.height)
      ..arcToPoint(
        Offset(0, size.height - radius.y),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(_SearchBottomBarBackgroundPainter oldDelegate) =>
      radius != oldDelegate.radius;

  @override
  bool shouldRebuildSemantics(_SearchBottomBarBackgroundPainter oldDelegate) =>
      false;
}
