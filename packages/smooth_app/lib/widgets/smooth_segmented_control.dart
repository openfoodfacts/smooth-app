import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SmoothSegmentedControl<T> extends StatefulWidget {
  const SmoothSegmentedControl({
    required this.currentValue,
    required this.labels,
    required this.onValueChanged,
    required this.values,
    this.backgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    super.key,
  }) : assert(
         labels.length == values.length,
         'Labels and values must have the same length',
       );

  final List<T> values;
  final List<String> labels;
  final T currentValue;
  final ValueChanged<T> onValueChanged;
  final Color? backgroundColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  @override
  State<SmoothSegmentedControl<T>> createState() =>
      _SmoothSegmentedControlState<T>();
}

class _SmoothSegmentedControlState<T> extends State<SmoothSegmentedControl<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _positionAnimation;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.short,
    );

    _previousIndex = widget.values.indexOf(widget.currentValue);
    _positionAnimation =
        Tween<double>(
          begin: _previousIndex.toDouble(),
          end: _previousIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void didUpdateWidget(SmoothSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentValue != widget.currentValue) {
      final int newIndex = widget.values.indexOf(widget.currentValue);

      _positionAnimation =
          Tween<double>(
            begin: _previousIndex.toDouble(),
            end: newIndex.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );

      _previousIndex = newIndex;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final int selectedIndex = widget.values.indexOf(widget.currentValue);

    return Material(
      shape: const RoundedRectangleBorder(borderRadius: MAX_BORDER_RADIUS),
      color: widget.backgroundColor ?? theme.primaryNormal,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(3.0),
        child: IntrinsicWidth(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: _SelectedSegmentPainter(
                  selectedIndex: selectedIndex,
                  segmentCount: widget.values.length,
                  animatedPosition: _positionAnimation.value,
                ),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(widget.values.length, (
                int index,
              ) {
                final T value = widget.values[index];
                final String label = widget.labels[index];
                final bool isSelected = value == widget.currentValue;

                return Expanded(
                  child: _SmoothSegmentedControlItem<T>(
                    value: value,
                    label: label,
                    isSelected: isSelected,
                    onTap: () => widget.onValueChanged(value),
                    selectedTextColor:
                        widget.selectedTextColor ?? theme.primaryDark,
                    unselectedTextColor:
                        widget.unselectedTextColor ?? Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _SmoothSegmentedControlItem<T> extends StatelessWidget {
  const _SmoothSegmentedControlItem({
    required this.isSelected,
    required this.label,
    required this.onTap,
    required this.value,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    super.key,
  });

  final T value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  final Color selectedTextColor;
  final Color unselectedTextColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: MAX_BORDER_RADIUS,
      onTap: !isSelected ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SMALL_SPACE,
          vertical: SMALL_SPACE,
        ),
        child: AnimatedDefaultTextStyle(
          duration: SmoothAnimationsDuration.medium,
          style: TextStyle(
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15.0,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// CustomPainter that draws a white rounded rectangle behind the selected segment
class _SelectedSegmentPainter extends CustomPainter {
  _SelectedSegmentPainter({
    required this.selectedIndex,
    required this.segmentCount,
    required this.animatedPosition,
  });

  final int selectedIndex;
  final int segmentCount;
  final double animatedPosition;

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedIndex < 0 || selectedIndex >= segmentCount) {
      return;
    }

    final double segmentWidth = size.width / segmentCount;
    final double segmentX = animatedPosition * segmentWidth;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(segmentX, 0, segmentWidth, size.height),
      MAX_BORDER_RADIUS.topLeft,
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _SelectedSegmentPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.segmentCount != segmentCount ||
        oldDelegate.animatedPosition != animatedPosition;
  }
}
