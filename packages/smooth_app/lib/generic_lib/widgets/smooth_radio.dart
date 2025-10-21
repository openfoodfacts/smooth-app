import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothRadioGroup<T> extends StatefulWidget {
  const SmoothRadioGroup({
    required this.groupValue,
    required this.onChanged,
    required this.items,
    super.key,
  });

  final T groupValue;
  final ValueChanged<T?> onChanged;
  final List<SmoothRadioItem<T>> items;

  @override
  State<SmoothRadioGroup<T>> createState() => _SmoothRadioGroupState<T>();
}

class _SmoothRadioGroupState<T> extends State<SmoothRadioGroup<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _selectedItemPosition;
  int _previousIndex = -1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: SmoothAnimationsDuration.medium,
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(SmoothRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    final int position = widget.items.indexWhere(
      (SmoothRadioItem<T> item) => item.value == widget.groupValue,
    );

    if (position == _previousIndex) {
      return;
    }

    _selectedItemPosition = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: position.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint));
    _previousIndex = position;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return CustomPaint(
      painter: _SmoothRadioGroupBackgroundPainter(
        items: widget.items.length,
        selectedItem: _selectedItemPosition.value,
        backgroundColor: lightTheme
            ? extension.primaryLight
            : extension.primaryTone,
        selectedColor: lightTheme
            ? extension.primaryMedium
            : extension.primaryAccent,
        selectedBorderColor: extension.primaryDark,
        radius: ROUNDED_RADIUS,
      ),
      child: RadioGroup<T>(
        groupValue: widget.groupValue,
        onChanged: widget.onChanged,
        child: IntrinsicHeight(
          child: Row(
            children: widget.items
                .mapIndexed<Widget>(
                  (int index, SmoothRadioItem<T> item) => Expanded(
                    child: _SmoothRadio<T>(item: widget.items.elementAt(index)),
                  ),
                )
                .toList(growable: false),
          ),
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

class _SmoothRadio<T> extends StatefulWidget {
  const _SmoothRadio({required this.item, super.key});

  final SmoothRadioItem<T> item;

  @override
  State<_SmoothRadio<T>> createState() => _SmoothRadioState<T>();
}

class _SmoothRadioState<T> extends State<_SmoothRadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<TextStyle> _textStyleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: SmoothAnimationsDuration.short,
      vsync: this,
    )..addListener(() => setState(() {}));
    _textStyleAnimation = TextStyleTween(
      begin: const TextStyle(fontWeight: FontWeight.normal),
      end: const TextStyle(fontWeight: FontWeight.bold),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant _SmoothRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    final bool selected = _isSelected;
    if (selected && _controller.value < 1.0) {
      _controller.forward();
    } else if (!selected && _controller.value > 0.0) {
      _controller.reverse();
    }
  }

  bool get _isSelected =>
      RadioGroup.maybeOf<T>(context)?.groupValue == widget.item.value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => RadioGroup.maybeOf<T>(context)?.onChanged(widget.item.value),
      borderRadius: ROUNDED_BORDER_RADIUS,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: BALANCED_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Column(
          spacing: VERY_SMALL_SPACE,
          children: <Widget>[
            widget.item.icon,
            Text(
              widget.item.label,
              textAlign: TextAlign.center,
              style: _textStyleAnimation.value,
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

@immutable
class SmoothRadioItem<T> {
  const SmoothRadioItem({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final Widget icon;
  final T value;
}

class _SmoothRadioGroupBackgroundPainter extends CustomPainter {
  _SmoothRadioGroupBackgroundPainter({
    required this.items,
    required this.selectedItem,
    required this.backgroundColor,
    required this.selectedColor,
    required this.selectedBorderColor,
    required this.radius,
  });

  final int items;
  final double selectedItem;

  final Color backgroundColor;
  final Color selectedColor;
  final Color selectedBorderColor;

  final Radius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = backgroundColor;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      paint,
    );

    // Selected item
    final double itemWidth = size.width / items;
    final Rect selectedRect = Rect.fromLTWH(
      selectedItem * itemWidth,
      0,
      itemWidth,
      size.height,
    );

    // Fill
    paint.color = selectedColor;
    canvas.drawRRect(RRect.fromRectAndRadius(selectedRect, radius), paint);

    // Border
    paint
      ..color = selectedBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(selectedRect, radius), paint);
  }

  @override
  bool shouldRepaint(_SmoothRadioGroupBackgroundPainter oldDelegate) =>
      items != oldDelegate.items ||
      selectedItem != oldDelegate.selectedItem ||
      backgroundColor != oldDelegate.backgroundColor ||
      selectedColor != oldDelegate.selectedColor ||
      selectedBorderColor != oldDelegate.selectedBorderColor ||
      radius != oldDelegate.radius;
}
