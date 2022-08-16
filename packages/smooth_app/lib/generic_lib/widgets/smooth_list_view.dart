import 'package:flutter/widgets.dart';

class SmoothListView extends ListView {
  /// Represents a ListView that can be show progress by displaying a
  /// [loadingWidget] at the end of the list.
  ///
  /// [loading] controls the display of the [loadingWidget] at the end of
  /// the list.
  SmoothListView.builder({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    IndexedWidgetBuilder? loadingWidget,
    bool loading = false,
  })  : assert(loading == false || loadingWidget != null),
        super.builder(
          itemCount: loading ? itemCount + 1 : itemCount,
          itemBuilder: (BuildContext context, int index) =>
              loading && (index == itemCount)
                  // Render a loading card as the last card
                  ? loadingWidget!(context, index)
                  : itemBuilder(context, index),
        );
}
