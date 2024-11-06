import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_draggable_bottom_sheet_route.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

Future<T?> showSmoothModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? minHeight,
}) {
  return showModalBottomSheet<T>(
    constraints:
        minHeight != null ? BoxConstraints(minHeight: minHeight) : null,
    isScrollControlled: minHeight != null,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: ROUNDED_RADIUS),
    ),
    builder: builder,
    useSafeArea: true,
  );
}

Future<T?> showSmoothDraggableModalSheet<T>({
  required BuildContext context,
  required SmoothModalSheetHeader header,

  /// You must return a Sliver Widget
  required WidgetBuilder bodyBuilder,
  double? initHeight,
}) {
  return showDraggableModalSheet<T>(
    context: context,
    borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
    headerBuilder: (_) => header,
    headerHeight: header.computeHeight(context),
    bodyBuilder: bodyBuilder,
    initHeight: initHeight,
  );
}

/// A non scrollable modal sheet
class SmoothModalSheet extends StatelessWidget {
  SmoothModalSheet({
    required String title,
    required this.body,
    bool closeButton = true,
    this.bodyPadding,
    double? closeButtonSemanticsOrder,
  }) : header = SmoothModalSheetHeader(
          title: title,
          suffix: closeButton
              ? SmoothModalSheetHeaderCloseButton(
                  semanticsOrder: closeButtonSemanticsOrder,
                )
              : null,
        );

  final SmoothModalSheetHeader header;
  final Widget body;
  final EdgeInsetsGeometry? bodyPadding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
      child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: ROUNDED_RADIUS),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              header,
              Padding(
                padding: bodyPadding ?? const EdgeInsets.all(MEDIUM_SPACE),
                child: body,
              ),
            ],
          )),
    );
  }

  double computeHeaderHeight(BuildContext context) =>
      header.computeHeight(context);
}

class SmoothModalSheetHeader extends StatelessWidget implements SizeWidget {
  const SmoothModalSheetHeader({
    required this.title,
    this.prefix,
    this.suffix,
    this.foregroundColor,
    this.backgroundColor,
  });

  static const double MIN_HEIGHT = 55.0;

  final String title;
  final SizeWidget? prefix;
  final SizeWidget? suffix;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!.primaryDark;
    final Color tintColor = foregroundColor ?? Colors.white;

    return IconTheme(
      data: IconThemeData(color: tintColor),
      child: Container(
        height: suffix is SmoothModalSheetHeaderButton ? double.infinity : null,
        color: backgroundColor ?? primaryColor,
        constraints: const BoxConstraints(minHeight: MIN_HEIGHT),
        padding: EdgeInsetsDirectional.only(
          start: (prefix?.requiresPadding == true ? 0 : VERY_LARGE_SPACE),
          top: VERY_SMALL_SPACE,
          bottom: VERY_SMALL_SPACE,
          end: VERY_LARGE_SPACE -
              (suffix?.requiresPadding == true ? 0 : LARGE_SPACE),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (prefix != null)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(end: BALANCED_SPACE),
                  child: prefix,
                ),
              Expanded(
                child: Semantics(
                  sortKey: const OrdinalSortKey(1.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: tintColor,
                        ),
                  ),
                ),
              ),
              if (suffix != null) suffix!
            ],
          ),
        ),
      ),
    );
  }

  double computeHeight(BuildContext context) {
    return math.max(
      widgetHeight(context),
      suffix?.widgetHeight(context) ?? 0.0,
    );
  }

  @override
  double widgetHeight(BuildContext context) {
    final double size = VERY_SMALL_SPACE * 2 +
        (Theme.of(context).textTheme.titleLarge?.fontSize ?? 15.0);

    return math.max(MIN_HEIGHT, size);
  }

  @override
  bool get requiresPadding => true;
}

class SmoothModalSheetHeaderButton extends StatelessWidget
    implements SizeWidget {
  const SmoothModalSheetHeaderButton({
    required this.label,
    this.prefix,
    this.suffix,
    this.onTap,
    this.tooltip,
  });

  static const EdgeInsetsGeometry _padding = EdgeInsetsDirectional.symmetric(
    horizontal: 15.0,
    vertical: 10.0,
  );

  final String label;
  final Widget? prefix;
  final Widget? suffix;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: tooltip,
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip ?? '',
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: _padding,
            shape: const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            iconColor: Colors.white,
          ),
          child: IconTheme(
            data: const IconThemeData(
              color: Colors.white,
              size: 20.0,
            ),
            child: Row(
              children: <Widget>[
                if (prefix != null) ...<Widget>[
                  prefix!,
                  const SizedBox(
                    width: SMALL_SPACE,
                  ),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                  ),
                  maxLines: 1,
                ),
                if (suffix != null) ...<Widget>[
                  const SizedBox(
                    width: SMALL_SPACE,
                  ),
                  suffix!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double widgetHeight(BuildContext context) {
    return math.max(MediaQuery.textScalerOf(context).scale(17.0),
            suffix is Icon || prefix is Icon ? 20.0 : 0.0) +
        _padding.vertical;
  }

  @override
  bool get requiresPadding => true;
}

class SmoothModalSheetHeaderCloseButton extends StatelessWidget
    implements SizeWidget {
  const SmoothModalSheetHeaderCloseButton({
    this.semanticsOrder,
    this.addPadding,
    this.circled = true,
  });

  final double? semanticsOrder;
  final bool? addPadding;
  final bool circled;

  @override
  Widget build(BuildContext context) {
    final Widget icon;

    if (circled == true) {
      icon = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: IconTheme.of(context).color ?? Colors.white,
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.all(VERY_SMALL_SPACE),
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: const icons.Close(
          size: 13.0,
        ),
      );
    } else {
      icon = const Padding(
        padding: EdgeInsets.all(MEDIUM_SPACE),
        child: icons.Close(
          size: 15.0,
        ),
      );
    }

    return Semantics(
      value: MaterialLocalizations.of(context).closeButtonTooltip,
      button: true,
      excludeSemantics: true,
      sortKey: OrdinalSortKey(semanticsOrder ?? 2.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: SMALL_SPACE),
        child: Tooltip(
          message: MaterialLocalizations.of(context).closeButtonTooltip,
          enableFeedback: true,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            customBorder: const CircleBorder(),
            child: icon,
          ),
        ),
      ),
    );
  }

  @override
  double widgetHeight(BuildContext context) =>
      (MEDIUM_SPACE * 2) + (Theme.of(context).iconTheme.size ?? 20.0);

  @override
  bool get requiresPadding => addPadding ?? false;
}

class SmoothModalSheetHeaderPrefixIndicator extends StatelessWidget
    implements SizeWidget {
  const SmoothModalSheetHeaderPrefixIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        color: extension.secondaryNormal,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  bool get requiresPadding => false;

  @override
  double widgetHeight(BuildContext context) => 10.0;
}

abstract class SizeWidget implements Widget {
  double widgetHeight(BuildContext context);

  bool get requiresPadding;
}
