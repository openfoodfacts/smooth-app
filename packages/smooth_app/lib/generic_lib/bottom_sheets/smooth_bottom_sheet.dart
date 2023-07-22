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
}) {
  return showDraggableModalSheet<T>(
    context: context,
    borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
    headerBuilder: (_) => header,
    headerHeight:
        SmoothModalSheetHeader.computeHeight(context, header.closeButton),
    bodyBuilder: bodyBuilder,
  );
}

/// A non scrollable modal sheet
class SmoothModalSheet extends StatelessWidget {
  const SmoothModalSheet({
    required this.title,
    required this.body,
    this.closeButton = true,
    this.bodyPadding,
    this.closeButtonSemanticsOrder,
  });

  final String title;
  final bool closeButton;
  final double? closeButtonSemanticsOrder;
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
              SmoothModalSheetHeader(
                title: title,
                closeButton: closeButton,
                closeButtonSemanticsOrder: closeButtonSemanticsOrder,
              ),
              Padding(
                padding: bodyPadding ?? const EdgeInsets.all(MEDIUM_SPACE),
                child: body,
              ),
            ],
          )),
    );
  }
}

class SmoothModalSheetHeader extends StatelessWidget {
  const SmoothModalSheetHeader({
    required this.title,
    this.closeButton = true,
    this.closeButtonSemanticsOrder,
  });

  final String title;
  final bool closeButton;
  final double? closeButtonSemanticsOrder;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      color: primaryColor.withOpacity(0.2),
      padding: EdgeInsetsDirectional.only(
        start: VERY_LARGE_SPACE,
        top: VERY_SMALL_SPACE,
        bottom: VERY_SMALL_SPACE,
        end: VERY_LARGE_SPACE - (closeButton ? LARGE_SPACE : 0),
      ),
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
          if (closeButton)
            Semantics(
              value: MaterialLocalizations.of(context).closeButtonTooltip,
              button: true,
              excludeSemantics: true,
              onScrollDown: () {},
              sortKey: OrdinalSortKey(closeButtonSemanticsOrder ?? 2.0),
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
            )
        ],
      ),
    );
  }

  static double computeHeight(
    BuildContext context,
    bool hasCloseButton,
  ) {
    double size = VERY_SMALL_SPACE * 2;

    if (hasCloseButton == true) {
      size += (MEDIUM_SPACE * 2) + (Theme.of(context).iconTheme.size ?? 20.0);
    } else {
      size += Theme.of(context).textTheme.titleLarge?.fontSize ?? 15.0;
    }

    return size;
  }
}
