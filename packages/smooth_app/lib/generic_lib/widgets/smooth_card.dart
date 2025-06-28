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
      result = Padding(padding: padding!, child: result);
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
      color:
          color ??
          (Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black),
      clipBehavior: clipBehavior ?? Clip.none,
      child: result,
    );

    return margin == null ? result : Padding(padding: margin!, child: result);
  }
}

class SmoothCardWithRoundedHeader extends StatelessWidget {
  const SmoothCardWithRoundedHeader({
    required this.title,
    required this.child,
    this.leading,
    this.leadingIconSize,
    this.leadingPadding,
    this.trailing,
    this.titleTextStyle,
    this.titlePadding,
    this.contentPadding,
    this.titleBackgroundColor,
    this.contentBackgroundColor,
    this.borderRadius,
    this.includeShadow = true,
    super.key,
  });

  final String title;
  final Widget? leading;
  final double? leadingIconSize;
  final EdgeInsetsGeometry? leadingPadding;
  final Widget? trailing;
  final Widget child;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final Color? titleBackgroundColor;
  final Color? contentBackgroundColor;
  final BorderRadius? borderRadius;
  final bool includeShadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
        boxShadow: includeShadow
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 2.0),
                ),
              ]
            : null,
      ),
      child: Column(
        children: <Widget>[
          SmoothCardWithRoundedHeaderTop(
            title: title,
            titleBackgroundColor: titleBackgroundColor,
            leading: leading,
            leadingIconSize: leadingIconSize,
            leadingPadding: leadingPadding,
            trailing: trailing,
            titleTextStyle: titleTextStyle,
            titlePadding: titlePadding,
            borderRadius: borderRadius,
          ),
          SmoothCardWithRoundedHeaderBody(
            contentBackgroundColor: contentBackgroundColor,
            contentPadding: contentPadding,
            borderRadius: borderRadius,
            child: child,
          ),
        ],
      ),
    );
  }
}

class SmoothCardWithRoundedHeaderBanner extends StatelessWidget {
  const SmoothCardWithRoundedHeaderBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return CustomPaint(
      painter: _SmoothCardWithRoundedHeaderBackgroundPainter(
        color: context.lightTheme() ? extension.greyLight : extension.greyDark,
        radius: ROUNDED_RADIUS,
        shadowElevation:
            SmoothCardWithRoundedHeaderTopShadowProvider.of(context)?.shadow ??
            0.0,
      ),
      child: child,
    );
  }
}

class SmoothCardWithRoundedHeaderTop extends StatelessWidget {
  const SmoothCardWithRoundedHeaderTop({
    required this.title,
    this.titleBackgroundColor,
    this.leading,
    this.leadingIconSize,
    this.leadingPadding,
    this.trailing,
    this.titleTextStyle,
    this.titlePadding,
    this.borderRadius,
    this.banner,
  });

  final String title;
  final Color? titleBackgroundColor;
  final Widget? leading;
  final double? leadingIconSize;
  final EdgeInsetsGeometry? leadingPadding;
  final Widget? trailing;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry? titlePadding;
  final BorderRadius? borderRadius;
  final Widget? banner;

  static const double _DEFAULT_LEADING_ICON_SIZE = 17.0;

  @override
  Widget build(BuildContext context) {
    final Color color = titleBackgroundColor ?? getHeaderColor(context);

    return Semantics(
      label: title,
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          if (banner != null) SmoothCardWithRoundedHeaderBanner(child: banner!),
          CustomPaint(
            painter: _SmoothCardWithRoundedHeaderBackgroundPainter(
              color: color,
              radius: borderRadius?.topRight ?? ROUNDED_RADIUS,
              shadowElevation:
                  SmoothCardWithRoundedHeaderTopShadowProvider.of(
                    context,
                  )?.shadow ??
                  0.0,
            ),
            child: Padding(
              padding:
                  titlePadding ??
                  (trailing != null
                      ? const EdgeInsetsDirectional.only(
                          top: 2.0,
                          start: LARGE_SPACE,
                          end: SMALL_SPACE,
                          bottom: 2.0,
                        )
                      : const EdgeInsetsDirectional.symmetric(
                          vertical: BALANCED_SPACE,
                          horizontal: LARGE_SPACE,
                        )),
              child: Row(
                children: <Widget>[
                  if (leading != null)
                    IconTheme(
                      data: IconThemeData(
                        color: titleBackgroundColor,
                        size: leadingIconSize ?? _DEFAULT_LEADING_ICON_SIZE,
                      ),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding:
                              leadingPadding ??
                              const EdgeInsetsDirectional.all(6.0),
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
                          (titleTextStyle ??
                                  Theme.of(context).textTheme.displaySmall)
                              ?.copyWith(color: Colors.white),
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
        ],
      ),
    );
  }

  static Color getHeaderColor(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    return context.lightTheme(listen: false)
        ? extension.primaryBlack
        : Colors.black;
  }
}

class SmoothCardWithRoundedHeaderTopShadowProvider extends InheritedWidget {
  const SmoothCardWithRoundedHeaderTopShadowProvider({
    required this.shadow,
    required super.child,
    super.key,
  });

  final double shadow;

  static SmoothCardWithRoundedHeaderTopShadowProvider? of(
    BuildContext context,
  ) {
    final SmoothCardWithRoundedHeaderTopShadowProvider? result = context
        .dependOnInheritedWidgetOfExactType<
          SmoothCardWithRoundedHeaderTopShadowProvider
        >();
    return result;
  }

  @override
  bool updateShouldNotify(
    SmoothCardWithRoundedHeaderTopShadowProvider oldWidget,
  ) {
    return oldWidget.shadow != shadow;
  }
}

class SmoothCardWithRoundedHeaderBody extends StatelessWidget {
  const SmoothCardWithRoundedHeaderBody({
    required this.child,
    this.contentPadding,
    this.contentBackgroundColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? contentPadding;
  final Color? contentBackgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SmoothCard(
      margin: EdgeInsets.zero,
      padding:
          contentPadding ?? const EdgeInsetsDirectional.only(top: MEDIUM_SPACE),
      borderRadius: borderRadius ?? ROUNDED_BORDER_RADIUS,
      color:
          contentBackgroundColor ??
          (context.darkTheme()
              ? context
                    .extension<SmoothColorsThemeExtension>()
                    .primaryUltraBlack
              : null),
      child: child,
    );
  }
}

/// We need this [CustomPainter] to draw the background below the other card
class _SmoothCardWithRoundedHeaderBackgroundPainter extends CustomPainter {
  _SmoothCardWithRoundedHeaderBackgroundPainter({
    required Color color,
    required this.radius,
    required this.shadowElevation,
  }) : _paint = Paint()..color = color;

  final Radius radius;
  final Paint _paint;
  final double shadowElevation;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, radius.y)
      ..lineTo(0, size.height + radius.y)
      ..arcToPoint(
        Offset(radius.x, size.height),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(size.width - radius.x, size.height)
      ..arcToPoint(
        Offset(size.width, size.height + radius.y),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(size.width, radius.y)
      ..arcToPoint(
        Offset(size.width - radius.x, 0),
        radius: radius,
        clockwise: false,
      )
      ..lineTo(radius.x, 0)
      ..arcToPoint(Offset(0, radius.y), radius: radius, clockwise: false)
      ..close();

    if (shadowElevation > 0.0) {
      canvas.drawShadow(
        path,
        Colors.black.withValues(alpha: shadowElevation),
        2.0,
        false,
      );
    }
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(
    _SmoothCardWithRoundedHeaderBackgroundPainter oldDelegate,
  ) => shadowElevation != oldDelegate.shadowElevation;

  @override
  bool shouldRebuildSemantics(
    _SmoothCardWithRoundedHeaderBackgroundPainter oldDelegate,
  ) => false;
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
