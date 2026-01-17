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
      );
    },
  );
}

class _SmoothAutoSizeModalContent<T> extends StatefulWidget {
  const _SmoothAutoSizeModalContent({
    required this.headerBuilder,
    required this.bodyBuilder,
    required this.maxHeightRatio,
  });

  final WidgetBuilder headerBuilder;
  final WidgetBuilder bodyBuilder;
  final double maxHeightRatio;

  @override
  State<_SmoothAutoSizeModalContent<T>> createState() =>
      _SmoothAutoSizeModalContentState<T>();
}

class _SmoothAutoSizeModalContentState<T>
    extends State<_SmoothAutoSizeModalContent<T>> {
  double? _headerHeight;
  double? _bodyHeight;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.heightOf(context);
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
        child: Column(
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
        ),
      );
    }

    final EdgeInsets screenPadding = SmoothViewPadding.of(context);
    final double maxHeight =
        (screenHeight - screenPadding.vertical) * widget.maxHeightRatio;
    final double realHeight =
        _headerHeight! + _bodyHeight! + screenPadding.bottom;
    final bool needsScroll = realHeight > maxHeight;

    final double contentDisplayHeight = needsScroll ? maxHeight : realHeight;

    final double initialRatio = contentDisplayHeight / screenHeight;
    final double maxRatio = math.min(
      1.0 - (screenPadding.top / MediaQuery.sizeOf(context).height),
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
        Widget bodyContent = Padding(
          padding: EdgeInsetsDirectional.only(bottom: screenPadding.bottom),
          child: body,
        );

        if (needsScroll) {
          bodyContent = SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(height: _bodyHeight, child: body),
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
