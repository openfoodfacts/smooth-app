import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/widget_height.dart';

class SmoothNavigationBar extends StatefulWidget {
  const SmoothNavigationBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    super.key,
  }) : assert(selectedIndex >= 0 && selectedIndex < destinations.length);

  final int selectedIndex;
  final List<SmoothNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<SmoothNavigationBar> createState() => _SmoothNavigationBarState();
}

class _SmoothNavigationBarState extends State<SmoothNavigationBar> {
  PointerDownEvent? _lastEvent;
  Size? _size;

  @override
  Widget build(BuildContext context) {
    return MeasureSize(
      onChange: (Size size) => _size = size,
      child: SizedBox(
        width: double.infinity,
        child: ColoredBox(
          color: context.lightTheme()
              ? const Color(0xFFEFE8EA)
              : Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: math.max(
                0,
                MediaQuery.viewPaddingOf(context).bottom -
                    (Platform.isIOS ? 5.0 : 0.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.destinations.mapIndexed((
                int position,
                SmoothNavigationDestination destination,
              ) {
                final int index = widget.destinations.indexOf(destination);
                return Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Listener(
                      onPointerDown: (PointerDownEvent event) =>
                          _lastEvent = event,
                      child: InkWell(
                        onTap: () => widget.onDestinationSelected(index),
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              MediaQuery.sizeOf(context).width / 2,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: _SmoothNavigationBarItem(
                            destination: destination,
                            selected: index == widget.selectedIndex,
                            lastPointerEvent: _lastEvent,
                            coordinates: _size != null
                                ? Rect.fromLTWH(
                                    position *
                                        _size!.width /
                                        widget.destinations.length,
                                    0.0,
                                    _size!.width / widget.destinations.length,
                                    _size!.height,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmoothNavigationBarItem extends StatefulWidget {
  const _SmoothNavigationBarItem({
    required this.destination,
    required this.selected,
    required this.coordinates,
    this.lastPointerEvent,
  });

  final SmoothNavigationDestination destination;
  final bool selected;
  final Rect? coordinates;
  final PointerDownEvent? lastPointerEvent;

  @override
  State<_SmoothNavigationBarItem> createState() =>
      _SmoothNavigationBarItemState();
}

class _SmoothNavigationBarItemState extends State<_SmoothNavigationBarItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _iconColorAnimation;
  late Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    _iconColorAnimation = ColorTween(
      begin: lightTheme ? extension.primaryDark : extension.primaryMedium,
      end: lightTheme ? Colors.white : extension.primaryBlack,
    ).animate(_controller);
    _textColorAnimation = ColorTween(
      begin: lightTheme ? extension.primaryDark : extension.primaryMedium,
      end: lightTheme ? extension.primaryBlack : extension.primaryLight,
    ).animate(_controller);

    if (widget.selected) {
      _controller.forward(from: 1.0);
    }
  }

  @override
  void didUpdateWidget(covariant _SmoothNavigationBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: MEDIUM_SPACE,
        top: SMALL_SPACE,
        bottom: 6.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme(
            data: IconThemeData(
              color: _iconColorAnimation.value,
              size: 24.0,
            ),
            child: SizedBox(
              width: 64.0,
              height: 32.0,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SmoothNavigationBarIconPainter(
                        defaultColor: lightTheme
                            ? const Color(0xFFEEDAD3)
                            : extension.primarySemiDark.withOpacity(0.4),
                        selectedColor: lightTheme
                            ? extension.primaryDark
                            : extension.primaryMedium,
                        progress: _controller.value.progressAndClamp(
                          0.0,
                          0.5,
                          1.0,
                        ),
                        dimensions: widget.coordinates,
                        animationStartPosition:
                            widget.lastPointerEvent?.position.dx,
                      ),
                    ),
                  ),
                  Positioned.fill(child: widget.destination.icon),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3.0),
          DefaultTextStyle.merge(
            style: TextStyle(
              color: _textColorAnimation.value,
              fontSize: 14.5,
              fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w600,
            ),
            child: Text(
              widget.destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SmoothNavigationBarIconPainter extends CustomPainter {
  _SmoothNavigationBarIconPainter({
    required this.defaultColor,
    required this.selectedColor,
    required this.progress,
    required this.animationStartPosition,
    required this.dimensions,
  });

  final Color defaultColor;
  final Color selectedColor;
  final double progress;
  final double? animationStartPosition;
  final Rect? dimensions;

  static const Radius BORDER_RADIUS = Radius.circular(16.0);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = defaultColor;

    if (progress < 1.0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          BORDER_RADIUS,
        ),
        paint,
      );
    }

    paint.color = selectedColor.withOpacity(progress);
    if (progress == 1.0) {
      _paintSelected(canvas, size, paint);
    } else if (progress > 0.0) {
      double startPosition;
      if (animationStartPosition == null || dimensions == null) {
        startPosition = size.width / 2;
      } else {
        if (animationStartPosition! < dimensions!.left ||
            animationStartPosition! > dimensions!.right) {
          startPosition = size.width / 2;
        } else {
          final double padding = (dimensions!.width - size.width) / 2;
          final double innerPosition =
              animationStartPosition! - dimensions!.left;
          if (innerPosition < padding) {
            startPosition = 0.0;
          } else if (innerPosition > padding + size.width) {
            startPosition = size.width;
          } else {
            startPosition = innerPosition - padding;
          }
        }
      }

      final double width = size.width * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startPosition * (1 - progress),
            (size.height / 2) * (1 - progress),
            width * progress,
            size.height * progress,
          ),
          Radius.circular(BORDER_RADIUS.x * progress),
        ),
        paint,
      );
    }
  }

  void _paintSelected(Canvas canvas, Size size, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        BORDER_RADIUS,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SmoothNavigationBarIconPainter oldDelegate) =>
      defaultColor != oldDelegate.defaultColor ||
      selectedColor != oldDelegate.selectedColor ||
      progress != oldDelegate.progress;

  @override
  bool shouldRebuildSemantics(_SmoothNavigationBarIconPainter oldDelegate) =>
      false;
}

class SmoothNavigationDestination {
  const SmoothNavigationDestination({
    required this.icon,
    required this.label,
  });

  final Widget icon;
  final String label;
}
