import 'package:flutter/widgets.dart';

/// A [SliverChildBuilderDelegate] that can show progress by displaying
/// [loadingWidget]s.
///
/// When [loading] is `true`, [loadingCount] of [loadingWidget] will be
/// displayed.
class LoadingSliverChildBuilderDelegate extends SliverChildBuilderDelegate {
  LoadingSliverChildBuilderDelegate({
    required IndexedWidgetBuilder childBuilder,
    required int childCount,
    Widget? loadingWidget,
    int loadingCount = 4,
    bool loading = false,
  }) : assert(loading == false || loadingWidget != null),
       super(
         (BuildContext context, int index) =>
             loading ? loadingWidget : childBuilder(context, index),
         childCount: loading ? loadingCount : childCount,
       );
}
