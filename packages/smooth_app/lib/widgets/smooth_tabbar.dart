import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothTabBar<T> extends StatefulWidget {
  const SmoothTabBar({
    required this.tabController,
    required this.items,
    required this.onTabChanged,
    this.padding,
    super.key,
  }) : assert(items.length > 0);

  static const double TAB_BAR_HEIGHT = 46.0;

  final TabController tabController;
  final Iterable<SmoothTabBarItem<T>> items;
  final Function(T) onTabChanged;
  final EdgeInsetsGeometry? padding;

  @override
  State<SmoothTabBar<T>> createState() => _SmoothTabBarState<T>();
}

class _SmoothTabBarState<T> extends State<SmoothTabBar<T>> {
  double _horizontalProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return CustomPaint(
      painter: _ProductHeaderTabBarPainter(
        progress: _horizontalProgress,
        primaryColor: lightTheme ? theme.primaryLight : theme.primaryDark,
        bottomSeparatorColor: theme.primaryDark,
        backgroundColor: AppBarTheme.of(context).backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SizedBox(
        height: SmoothTabBar.TAB_BAR_HEIGHT,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notif) {
            onNextFrame(() {
              setState(() {
                _horizontalProgress =
                    notif.metrics.pixels / notif.metrics.maxScrollExtent;
              });
            });

            return false;
          },
          child: TabBar(
            controller: widget.tabController,
            tabs: widget.items
                .mapIndexed(
                  (int position, SmoothTabBarItem<T> item) => _SmoothTab<T>(
                    item: item,
                    selected: widget.tabController.index == position,
                  ),
                )
                .toList(growable: false),
            isScrollable: true,
            padding: widget.padding,
            labelPadding: EdgeInsets.zero,
            tabAlignment: TabAlignment.start,
            overlayColor: WidgetStatePropertyAll<Color>(
              theme.primaryLight,
            ),
            splashBorderRadius: const BorderRadius.vertical(
              top: Radius.circular(5.0),
            ),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: theme.primaryBlack,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: lightTheme ? theme.primarySemiDark : theme.primaryNormal,
            ),
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.primaryDark,
                  width: 3.0,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5.0),
              ),
              color: theme.primaryLight,
            ),
            onTap: (int position) => widget.onTabChanged.call(
              widget.items.elementAt(position).value,
            ),
          ),
        ),
      ),
    );
  }
}

class SmoothTabBarItem<T> {
  const SmoothTabBarItem({
    required this.label,
    required this.value,
  }) : assert(label.length > 0);

  final String label;
  final T value;
}

class _SmoothTab<T> extends StatelessWidget {
  const _SmoothTab({
    required this.item,
    required this.selected,
  });

  final SmoothTabBarItem<T> item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Center(
        child: Text(item.label),
      ),
    );
  }
}

class _ProductHeaderTabBarPainter extends CustomPainter {
  _ProductHeaderTabBarPainter({
    required this.progress,
    required this.primaryColor,
    required this.bottomSeparatorColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color primaryColor;
  final Color bottomSeparatorColor;
  final Color backgroundColor;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final double gradientSize = size.width * 0.1;

    if (progress > 0.0) {
      _paint.shader = ui.Gradient.linear(
        Offset.zero,
        Offset(gradientSize, 0.0),
        <Color>[
          primaryColor.withOpacity(
            progress.progressAndClamp(0.0, 0.3, 1.0),
          ),
          backgroundColor,
        ],
      );

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          gradientSize,
          size.height,
        ),
        _paint,
      );
    }

    if (progress < 1.0) {
      _paint.shader = ui.Gradient.linear(
        Offset(size.width - gradientSize, 0.0),
        Offset(size.width, 0.0),
        <Color>[
          backgroundColor,
          primaryColor.withOpacity(
            1 - progress.progressAndClamp(0.7, 1.0, 1.0),
          ),
        ],
      );

      canvas.drawRect(
        Rect.fromLTWH(
          size.width - gradientSize,
          0,
          size.width,
          size.height,
        ),
        _paint,
      );
    }

    _paint
      ..shader = null
      ..color = bottomSeparatorColor;
    canvas.drawLine(
      Offset(0, size.height - 1.0),
      Offset(size.width, size.height - 1.0),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_ProductHeaderTabBarPainter oldDelegate) =>
      oldDelegate.progress != progress;

  @override
  bool shouldRebuildSemantics(_ProductHeaderTabBarPainter oldDelegate) => true;
}
