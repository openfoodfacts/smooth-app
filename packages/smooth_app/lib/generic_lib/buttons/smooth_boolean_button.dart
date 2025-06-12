import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SmoothTriStatesButton extends StatefulWidget {
  const SmoothTriStatesButton({
    required this.value,
    required this.onChanged,
    required this.positiveTooltip,
    required this.negativeTooltip,
  })  : assert(positiveTooltip.length > 0),
        assert(negativeTooltip.length > 0);

  final bool? value;
  final Function(bool?) onChanged;
  final String positiveTooltip;
  final String negativeTooltip;

  @override
  State<SmoothTriStatesButton> createState() => _SmoothTriStatesButtonState();
}

class _SmoothTriStatesButtonState extends State<SmoothTriStatesButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _startAnimation;
  late Animation<double> _endAnimation;
  late Animation<double> _horizontalAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SmoothAnimationsDuration.short,
      vsync: this,
    )..addListener(() => setState(() {}));

    _initAnimation(null, widget.value);
  }

  @override
  void didUpdateWidget(covariant SmoothTriStatesButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _initAnimation(oldWidget.value, widget.value);
      SmoothHapticFeedback.lightNotification();
    }
  }

  void _initAnimation(bool? oldValue, bool? newValue) {
    Tween<double> tweenStart;
    Tween<double> tweenEnd;
    Tween<double> tweenHorizontal;

    if (oldValue == null && newValue == null) {
      tweenStart = Tween<double>(begin: 0.0, end: 0.0);
      tweenEnd = Tween<double>(begin: 0.0, end: 0.0);
      tweenHorizontal = Tween<double>(begin: 0.0, end: 0.0);
    } else if (oldValue == null && newValue == true) {
      tweenStart = Tween<double>(begin: 0.0, end: 1.0);
      tweenEnd = Tween<double>(begin: 0.0, end: 0.0);
      tweenHorizontal = Tween<double>(begin: 0.0, end: 0.0);
    } else if (oldValue == null && newValue == false) {
      tweenStart = Tween<double>(begin: 0.0, end: 0.0);
      tweenEnd = Tween<double>(begin: 0.0, end: 1.0);
      tweenHorizontal = Tween<double>(begin: 1.0, end: 1.0);
    } else if (oldValue == false && newValue == true) {
      tweenStart = Tween<double>(begin: 0.0, end: 1.0);
      tweenEnd = Tween<double>(begin: 1.0, end: 0.0);
      tweenHorizontal = Tween<double>(begin: 1.0, end: 0.0);
    } else if (oldValue == true && newValue == false) {
      tweenStart = Tween<double>(begin: 1.0, end: 0.0);
      tweenEnd = Tween<double>(begin: 0.0, end: 1.0);
      tweenHorizontal = Tween<double>(begin: 0.0, end: 1.0);
    } else if (oldValue == true && newValue == null) {
      tweenStart = Tween<double>(begin: 1.0, end: 0.0);
      tweenEnd = Tween<double>(begin: 0.0, end: 0.0);
      tweenHorizontal = Tween<double>(begin: 1.0, end: 1.0);
    } else if (oldValue == false && newValue == null) {
      tweenStart = Tween<double>(begin: 0.0, end: 0.0);
      tweenEnd = Tween<double>(begin: 1.0, end: 1.0);
      tweenHorizontal = Tween<double>(begin: 1.0, end: 1.0);
    } else {
      throw Exception('Invalid state');
    }

    _startAnimation = tweenStart.animate(_controller);
    _endAnimation = tweenEnd.animate(_controller);
    _horizontalAnimation = tweenHorizontal.animate(_controller);

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return CustomPaint(
      painter: _SmoothTriStateItemBackgroundBorderPainter(
        startDefaultColor: Colors.white,
        startSelectedColor: extension.success,
        endDefaultColor: Colors.white,
        endSelectedColor: extension.error,
        startPercent: _startAnimation.value,
        endPercent: _endAnimation.value,
        horizontalPercent: _horizontalAnimation.value,
      ),
      foregroundPainter: _SmoothTriStateItemForegroundBorderPainter(
        borderColor: extension.greyMedium,
      ),
      child: SizedBox(
        height: 28.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SmoothTriStatesItem(
              icon: const icons.Check(),
              iconColor: Color.lerp(
                extension.greyMedium,
                Colors.white,
                _startAnimation.value,
              )!,
              iconSize: 12.0,
              position: SmoothTriStateButtonPosition.start,
              tooltip: widget.positiveTooltip,
              onTap: () {
                if (widget.value == null || widget.value == false) {
                  widget.onChanged(true);
                } else {
                  widget.onChanged(null);
                }
              },
            ),
            _SmoothTriStatesItem(
              icon: const icons.Close(),
              iconColor: Color.lerp(
                extension.greyMedium,
                Colors.white,
                _endAnimation.value,
              )!,
              iconSize: 12.0,
              position: SmoothTriStateButtonPosition.end,
              tooltip: widget.negativeTooltip,
              onTap: () {
                if (widget.value == null || widget.value == true) {
                  widget.onChanged(false);
                } else {
                  widget.onChanged(null);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SmoothTriStatesItem extends StatelessWidget {
  const _SmoothTriStatesItem({
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.onTap,
    required this.position,
    required this.tooltip,
  });

  final icons.AppIcon icon;
  final double iconSize;
  final Color iconColor;
  final VoidCallback onTap;
  final SmoothTriStateButtonPosition position;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12.0 * MediaQuery.textScalerOf(context).scale(1.0) +
          (LARGE_SPACE * 2) +
          2.0,
      child: Material(
        type: MaterialType.transparency,
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadiusDirectional.only(
              topStart: position == SmoothTriStateButtonPosition.start
                  ? const Radius.circular(LARGE_SPACE)
                  : Radius.zero,
              bottomStart: position == SmoothTriStateButtonPosition.start
                  ? const Radius.circular(LARGE_SPACE)
                  : Radius.zero,
              topEnd: position == SmoothTriStateButtonPosition.end
                  ? const Radius.circular(LARGE_SPACE)
                  : Radius.zero,
              bottomEnd: position == SmoothTriStateButtonPosition.end
                  ? const Radius.circular(LARGE_SPACE)
                  : Radius.zero,
            ).resolve(Directionality.of(context)),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 2.0),
              child: Center(
                child: icons.AppIconTheme(
                  size: iconSize,
                  color: iconColor,
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum SmoothTriStateButtonPosition {
  start,
  end,
}

class _SmoothTriStateItemBackgroundBorderPainter extends CustomPainter {
  _SmoothTriStateItemBackgroundBorderPainter({
    required this.startDefaultColor,
    required this.startSelectedColor,
    required this.endDefaultColor,
    required this.endSelectedColor,
    required this.startPercent,
    required this.endPercent,
    required this.horizontalPercent,
  });

  final Color startDefaultColor;
  final Color startSelectedColor;
  final Color endDefaultColor;
  final Color endSelectedColor;

  final double startPercent;
  final double endPercent;
  final double horizontalPercent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Start
    paint.color = _getColor(
      startDefaultColor,
      startSelectedColor,
      startPercent,
    );
    RRect roundedRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0.0, 0.0, size.width / 2, size.height),
      topLeft: const Radius.circular(LARGE_SPACE),
      bottomLeft: const Radius.circular(LARGE_SPACE),
    );
    canvas.drawRRect(roundedRect, paint);

    paint.color = _getColor(
      endDefaultColor,
      endSelectedColor,
      endPercent,
    );

    roundedRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width / 2, 0.0, size.width / 2, size.height),
      topRight: const Radius.circular(LARGE_SPACE),
      bottomRight: const Radius.circular(LARGE_SPACE),
    );
    canvas.drawRRect(roundedRect, paint);

    if (horizontalPercent > 0.0 && horizontalPercent < 1.0) {
      paint.color = Color.lerp(
        startSelectedColor,
        endSelectedColor,
        horizontalPercent,
      )!;
      roundedRect = RRect.fromRectAndCorners(
        Rect.fromLTWH((size.width / 2) * horizontalPercent, 0.0, size.width / 2,
            size.height),
        topLeft: Radius.circular(LARGE_SPACE * (1 - horizontalPercent)),
        bottomLeft: Radius.circular(LARGE_SPACE * (1 - horizontalPercent)),
        topRight: Radius.circular(LARGE_SPACE * horizontalPercent),
        bottomRight: Radius.circular(LARGE_SPACE * horizontalPercent),
      );
      canvas.drawRRect(roundedRect, paint);
    }
  }

  Color _getColor(Color defaultColor, Color selectedColor, double percent) {
    if (percent > 0.0 &&
        (horizontalPercent == 0.0 || horizontalPercent == 1.0)) {
      return Color.lerp(
        defaultColor,
        selectedColor,
        percent,
      )!;
    } else {
      return defaultColor;
    }
  }

  @override
  bool shouldRepaint(_SmoothTriStateItemBackgroundBorderPainter oldDelegate) =>
      startPercent != oldDelegate.startPercent ||
      endPercent != oldDelegate.endPercent ||
      horizontalPercent != oldDelegate.horizontalPercent;

  @override
  bool shouldRebuildSemantics(
          _SmoothTriStateItemBackgroundBorderPainter oldDelegate) =>
      false;
}

class _SmoothTriStateItemForegroundBorderPainter extends CustomPainter {
  _SmoothTriStateItemForegroundBorderPainter({
    required this.borderColor,
  });

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Separator
    canvas.drawLine(Offset(size.width / 2, 0.0),
        Offset(size.width / 2, size.height), paint);

    // Rounded borders
    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      const Radius.circular(LARGE_SPACE),
    );
    canvas.drawRRect(roundedRect, paint);
  }

  @override
  bool shouldRepaint(_SmoothTriStateItemForegroundBorderPainter oldDelegate) =>
      false;

  @override
  bool shouldRebuildSemantics(
          _SmoothTriStateItemForegroundBorderPainter oldDelegate) =>
      false;
}
