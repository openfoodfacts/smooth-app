import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/widgets/smooth_view_padding.dart';
import 'package:smooth_app/widgets/widget_height.dart';

Future<T?> showSmoothAutoSizeModalSheet<T>({
  required BuildContext context,
  required SmoothModalSheetHeader header,
  required WidgetBuilder bodyBuilder,
  double? maxHeightRatio,
  bool? useRootNavigator,
  bool useSafeArea = true,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: ROUNDED_RADIUS),
    ),
    useRootNavigator: useRootNavigator ?? false,
    // We inject the safe area manually
    useSafeArea: false,
    builder: (BuildContext context) {
      return _SmoothAutoSizeModalContent<T>(
        headerBuilder: (_) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
          child: header,
        ),
        bodyBuilder: (BuildContext context) => bodyBuilder(context),
        maxHeightRatio: maxHeightRatio ?? 1.0,
        useSafeArea: useSafeArea,
      );
    },
  );
}

class _SmoothAutoSizeModalContent<T> extends StatefulWidget {
  const _SmoothAutoSizeModalContent({
    required this.headerBuilder,
    required this.bodyBuilder,
    required this.maxHeightRatio,
    required this.useSafeArea,
  });

  final WidgetBuilder headerBuilder;
  final WidgetBuilder bodyBuilder;
  final double maxHeightRatio;
  final bool useSafeArea;

  @override
  State<_SmoothAutoSizeModalContent<T>> createState() =>
      _SmoothAutoSizeModalContentState<T>();
}

class _SmoothAutoSizeModalContentState<T>
    extends State<_SmoothAutoSizeModalContent<T>> {
  late double _availableHeight;

  double? _headerHeight;
  double? _bodyHeight;

  @override
  Widget build(BuildContext context) {
    final Widget header = KeyedSubtree(
      key: const Key('autosize_header'),
      child: widget.headerBuilder(context),
    );
    final Widget body = KeyedSubtree(
      key: const Key('autosize_body'),
      child: widget.bodyBuilder(context),
    );

    if (_headerHeight == null || _bodyHeight == null) {
      return Offstage(
        child: LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            _availableHeight = constraints.maxHeight;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MeasureSize(
                  onChange: (Size size) =>
                      setState(() => _headerHeight = size.height),
                  child: header,
                ),
                MeasureSize(
                  onChange: (Size size) =>
                      setState(() => _bodyHeight = size.height),
                  child: body,
                ),
              ],
            );
          },
        ),
      );
    }

    final EdgeInsets screenPadding = SmoothViewPadding.of(context);
    final double maxHeight =
        (_availableHeight - screenPadding.vertical) * widget.maxHeightRatio;
    final double realHeight =
        _headerHeight! +
        _bodyHeight! +
        (widget.useSafeArea ? screenPadding.bottom : 0.0);
    final bool needsScroll = realHeight > maxHeight;

    final double contentDisplayHeight = needsScroll ? maxHeight : realHeight;

    final double initialRatio = contentDisplayHeight / _availableHeight;
    final double maxRatio = math.min(
      1.0 - (screenPadding.top / _availableHeight),
      widget.maxHeightRatio,
    );

    const double minRatio = 0.0;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialRatio.clamp(0.01, maxRatio),
      maxChildSize: maxRatio,
      minChildSize: minRatio,
      snap: true,
      snapSizes: const <double>[0.0],
      builder: (BuildContext context, ScrollController scrollController) {
        Widget bodyContent = body;

        if (needsScroll) {
          bodyContent = SingleChildScrollView(
            padding: widget.useSafeArea
                ? EdgeInsetsDirectional.only(bottom: screenPadding.bottom)
                : EdgeInsetsDirectional.zero,
            controller: scrollController,
            child: SizedBox(height: _bodyHeight, child: bodyContent),
          );
        } else if (widget.useSafeArea) {
          bodyContent = Padding(
            padding: EdgeInsetsDirectional.only(bottom: screenPadding.bottom),
            child: bodyContent,
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header,
            Expanded(child: bodyContent),
          ],
        );
      },
    );
  }
}
