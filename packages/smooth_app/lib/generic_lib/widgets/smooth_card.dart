import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Renders a Material card with elevation, shadow, Border radius etc...
/// Note: If the caller updates BoxDecoration of the [header] or [child] widget,
/// the caller must also set the borderRadius to [ROUNDED_RADIUS] in
/// BoxDecoration.
/// Note: [padding] applies to both header and body, if you want to have a
/// padding only for body and not for header (or vice versa) set it to zero here
/// and set the padding explicitly in the desired element.
class SmoothCard extends StatelessWidget {
  const SmoothCard({
    required this.child,
    this.color,
    this.margin = const EdgeInsets.symmetric(
      horizontal: SMALL_SPACE,
      vertical: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 8.0,
    this.borderRadius,
    this.ignoreDefaultSemantics = false,
    this.clipBehavior,
  });

  const SmoothCard.angular({
    required this.child,
    this.color,
    this.margin = const EdgeInsets.symmetric(
      horizontal: SMALL_SPACE,
      vertical: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 8.0,
    this.ignoreDefaultSemantics = false,
    this.clipBehavior,
  }) : borderRadius = ANGULAR_BORDER_RADIUS;

  const SmoothCard.flat({
    required this.child,
    this.color,
    this.margin = const EdgeInsetsDirectional.only(
      start: SMALL_SPACE,
      end: SMALL_SPACE,
      top: VERY_SMALL_SPACE,
      bottom: VERY_SMALL_SPACE,
    ),
    this.padding = const EdgeInsets.all(5.0),
    this.elevation = 0.0,
    this.borderRadius,
    this.ignoreDefaultSemantics = false,
    this.clipBehavior,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double elevation;
  final bool ignoreDefaultSemantics;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (padding != null) {
      result = Padding(
        padding: padding!,
        child: result,
      );
    }

    if (ignoreDefaultSemantics) {
      result = Semantics(
        container: false,
        explicitChildNodes: true,
        child: child,
      );
    }

    result = Material(
      elevation: elevation,
      shadowColor: const Color.fromARGB(25, 0, 0, 0),
      borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
      color: color ??
          (Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black),
      clipBehavior: clipBehavior ?? Clip.none,
      child: result,
    );

    return margin == null
        ? result
        : Padding(
            padding: margin!,
            child: result,
          );
  }
}

class SmoothCardWithRoundedHeader extends StatelessWidget {
  const SmoothCardWithRoundedHeader({
    required this.title,
    required this.child,
    this.leading,
    this.trailing,
    this.titleTextStyle,
    this.titlePadding,
    this.contentPadding,
    this.titleBackgroundColor,
    this.contentBackgroundColor,
    this.borderRadius,
  });

  final String title;

  final Widget? leading;
  final Widget? trailing;
  final Widget child;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final Color? titleBackgroundColor;
  final Color? contentBackgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final Color color = titleBackgroundColor ?? getHeaderColor(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 2.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Semantics(
            label: title,
            excludeSemantics: true,
            child: CustomPaint(
              painter: _SmoothCardWithRoundedHeaderBackgroundPainter(
                color: color,
                radius: borderRadius?.topRight ?? ROUNDED_RADIUS,
              ),
              child: Padding(
                padding: titlePadding ??
                    const EdgeInsetsDirectional.symmetric(
                      vertical: BALANCED_SPACE,
                      horizontal: LARGE_SPACE,
                    ),
                child: Row(
                  children: <Widget>[
                    if (leading != null)
                      IconTheme(
                        data: IconThemeData(
                          color: color,
                          size: 17.0,
                        ),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.all(6.0),
                            child: leading,
                          ),
                        ),
                      ),
                    const SizedBox(width: MEDIUM_SPACE),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (titleTextStyle ?? themeData.textTheme.displaySmall)
                                ?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (trailing != null) ...<Widget>[
                      const SizedBox(width: MEDIUM_SPACE),
                      IconTheme(
                        data: const IconThemeData(
                          color: Colors.white,
                          size: 20.0,
                        ),
                        child: trailing!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SmoothCard(
            margin: EdgeInsets.zero,
            padding: contentPadding ??
                const EdgeInsetsDirectional.only(
                  top: MEDIUM_SPACE,
                ),
            borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
            color: contentBackgroundColor ??
                (context.darkTheme() ? extension.primaryUltraBlack : null),
            child: child,
          ),
        ],
      ),
    );
  }

  static Color getHeaderColor(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    return context.lightTheme(listen: false)
        ? extension.primaryBlack
        : Colors.black;
  }
}

/// We need this [CustomPainter] to draw the background below the other card
class _SmoothCardWithRoundedHeaderBackgroundPainter extends CustomPainter {
  _SmoothCardWithRoundedHeaderBackgroundPainter({
    required Color color,
    required this.radius,
  }) : _paint = Paint()..color = color;

  final Radius radius;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
          0.0,
          0.0,
          size.width,
          size.height + radius.y,
        ),
        topLeft: radius,
        topRight: radius,
      ),
      _paint,
    );
  }

  @override
  bool shouldRepaint(
    _SmoothCardWithRoundedHeaderBackgroundPainter oldDelegate,
  ) =>
      false;

  @override
  bool shouldRebuildSemantics(
    _SmoothCardWithRoundedHeaderBackgroundPainter oldDelegate,
  ) =>
      false;
}

class SmoothCardHeaderButton extends StatelessWidget {
  const SmoothCardHeaderButton({
    required this.tooltip,
    required this.child,
    required this.onTap,
    this.padding,
    super.key,
  });

  final String tooltip;
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        label: tooltip,
        button: true,
        excludeSemantics: true,
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: padding ?? const EdgeInsetsDirectional.all(MEDIUM_SPACE),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
