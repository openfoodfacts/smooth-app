import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_draggable_bottom_sheet_route.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
    this.suffix,
  });

  static const double MIN_HEIGHT = 50.0;

  final String title;
  final SizeWidget? suffix;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: suffix is SmoothModalSheetHeaderButton ? double.infinity : null,
      color: primaryColor.withOpacity(0.2),
      constraints: const BoxConstraints(minHeight: MIN_HEIGHT),
      padding: EdgeInsetsDirectional.only(
        start: VERY_LARGE_SPACE,
        top: VERY_SMALL_SPACE,
        bottom: VERY_SMALL_SPACE,
        end: VERY_LARGE_SPACE -
            (suffix?.requiresPadding == true ? 0 : LARGE_SPACE),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                sortKey: const OrdinalSortKey(1.0),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            if (suffix != null) suffix!
          ],
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
    vertical: 20.0,
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
    return math.max(17.0 * MediaQuery.textScaleFactorOf(context),
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
  });

  final double? semanticsOrder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: MaterialLocalizations.of(context).closeButtonTooltip,
      button: true,
      excludeSemantics: true,
      sortKey: OrdinalSortKey(semanticsOrder ?? 2.0),
      child: Tooltip(
        message: MaterialLocalizations.of(context).closeButtonTooltip,
        enableFeedback: true,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(MEDIUM_SPACE),
            child: Icon(Icons.clear),
          ),
        ),
      ),
    );
  }

  @override
  double widgetHeight(BuildContext context) =>
      (MEDIUM_SPACE * 2) + (Theme.of(context).iconTheme.size ?? 20.0);

  @override
  bool get requiresPadding => false;
}

abstract class SizeWidget implements Widget {
  double widgetHeight(BuildContext context);

  bool get requiresPadding;
}
