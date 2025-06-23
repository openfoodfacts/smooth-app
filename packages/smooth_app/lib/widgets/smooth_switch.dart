import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SmoothSwitch extends StatefulWidget {
  SmoothSwitch({
    required this.value,
    required this.onChanged,
    this.size,
    this.padding,
    this.thumbActiveColor,
    this.thumbInactiveColor,
    this.backgroundActiveColor,
    this.backgroundInactiveColor,
    super.key,
  }) : assert(size == null || (size.width >= 52.0 && size.height >= 30.0));

  final bool value;
  final ValueChanged<bool> onChanged;
  final Size? size;
  final EdgeInsetsGeometry? padding;
  final Color? thumbActiveColor;
  final Color? thumbInactiveColor;
  final Color? backgroundActiveColor;
  final Color? backgroundInactiveColor;

  @override
  State<SmoothSwitch> createState() => _SmoothSwitchState();
}

class _SmoothSwitchState extends State<SmoothSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.short,
    )..addListener(() => setState(() {}));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );

    if (widget.value) {
      _animationController.forward(from: 1.0);
    }
  }

  @override
  void didUpdateWidget(covariant SmoothSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SwitchThemeData switchTheme = Theme.of(context).switchTheme;
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return Semantics(
      toggled: widget.value,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          widget.onChanged(!widget.value);
        },
        child: Padding(
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: SMALL_SPACE,
                vertical: SMALL_SPACE,
              ),
          child: CustomPaint(
            size: widget.size ?? const Size(52.0, 30.0),
            painter: _SmoothSwitchPainter(
              progress: _progressAnimation.value,
              thumbActiveColor:
                  widget.thumbActiveColor ??
                  switchTheme.thumbColor?.resolve(<WidgetState>{
                    WidgetState.selected,
                  }) ??
                  theme.primaryDark,
              thumbInactiveColor:
                  widget.thumbInactiveColor ??
                  switchTheme.thumbColor?.resolve(<WidgetState>{
                    WidgetState.disabled,
                  }) ??
                  const Color(0xFFC2B5B0),
              backgroundActiveColor:
                  widget.backgroundActiveColor ??
                  switchTheme.trackColor?.resolve(<WidgetState>{
                    WidgetState.selected,
                  }) ??
                  theme.primaryMedium,
              backgroundInactiveColor:
                  widget.backgroundInactiveColor ??
                  switchTheme.trackColor?.resolve(<WidgetState>{
                    WidgetState.disabled,
                  }) ??
                  theme.primaryMedium,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('active', value: widget.value));
  }
}

class _SmoothSwitchPainter extends CustomPainter {
  _SmoothSwitchPainter({
    required this.progress,
    required this.thumbActiveColor,
    required this.thumbInactiveColor,
    required this.backgroundActiveColor,
    required this.backgroundInactiveColor,
  });

  final double progress;
  final Color thumbActiveColor;
  final Color thumbInactiveColor;
  final Color backgroundActiveColor;
  final Color backgroundInactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color.lerp(
        backgroundInactiveColor,
        backgroundActiveColor,
        progress,
      )!
      ..style = PaintingStyle.fill;

    final double radius = size.height / 2.0;
    final double thumbRadius = radius;

    final double thumbPosition = progress * (size.width - 2 * radius) + radius;

    final Rect rect = Rect.fromLTWH(0.0, 2.0, size.width, size.height - 4.0);
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(rrect, paint);

    paint.color = Color.lerp(thumbInactiveColor, thumbActiveColor, progress)!;

    canvas.drawCircle(Offset(thumbPosition, radius), thumbRadius, paint);
  }

  @override
  bool shouldRepaint(_SmoothSwitchPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.thumbActiveColor != thumbActiveColor ||
      oldDelegate.thumbInactiveColor != thumbInactiveColor ||
      oldDelegate.backgroundActiveColor != backgroundActiveColor ||
      oldDelegate.backgroundInactiveColor != backgroundInactiveColor;

  @override
  bool shouldRebuildSemantics(_SmoothSwitchPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
