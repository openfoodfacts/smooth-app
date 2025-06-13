import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/product_page/header/reorder_bottom_sheet/reorder_bottom_sheet_provider.dart';
import 'package:smooth_app/pages/product/product_page/header/reorder_bottom_sheet/reorderable_item.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

typedef LabelBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

class ReorderBottomSheet<T> extends StatelessWidget {
  ReorderBottomSheet({
    required List<T> items,
    required this.onReorder,
    required this.labelBuilder,
    this.onVisibilityToggle,
    required this.title,
  }) : _items = items
            .map((T data) => ReorderableItem<T>(data: data))
            .toList(growable: true);

  final List<ReorderableItem<T>> _items;
  final ValueChanged<List<T>> onReorder;
  final LabelBuilder<T> labelBuilder;
  final ValueChanged<T>? onVisibilityToggle;
  final String title;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return ChangeNotifierProvider<ReorderBottomSheetProvider<T>>(
      create: (_) => ReorderBottomSheetProvider<T>(_items),
      child: Consumer<ReorderBottomSheetProvider<T>>(
        builder:
            (BuildContext context, ReorderBottomSheetProvider<T> provider, _) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (_, ScrollController scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SmoothModalSheetHeader(
                        title: title,
                      ),
                      Expanded(
                        child: ReorderableListView.builder(
                          scrollController: scrollController,
                          padding: const EdgeInsets.all(MEDIUM_SPACE),
                          proxyDecorator: (
                            Widget child,
                            int index,
                            Animation<double> animation,
                          ) =>
                              Transform.scale(
                            scale: 1.0 + (0.05 * animation.value),
                            child: Opacity(
                              opacity: 0.8,
                              child: child,
                            ),
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final ReorderableItem<T> item =
                                provider.items[index];
                            return Container(
                              key: ValueKey<T>(item.data),
                              margin: const EdgeInsetsDirectional.only(
                                bottom: MEDIUM_SPACE,
                              ),
                              padding:
                                  const EdgeInsetsDirectional.all(MEDIUM_SPACE),
                              decoration: BoxDecoration(
                                color: lightTheme
                                    ? (item.visible
                                        ? theme.primaryMedium
                                        : theme.primaryLight)
                                    : (item.visible
                                        ? theme.primaryDark
                                        : theme.primarySemiDark),
                                borderRadius: ROUNDED_BORDER_RADIUS,
                              ),
                              child: Row(
                                children: <Widget>[
                                  if (onVisibilityToggle != null)
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: lightTheme
                                            ? theme.primarySemiDark
                                            : theme.primaryLight,
                                      ),
                                      child: IconButton(
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 16.0,
                                        icon: icons.Eye.visible(
                                          color: lightTheme
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        onPressed: () =>
                                            onVisibilityToggle?.call(item.data),
                                      ),
                                    ),
                                  if (onVisibilityToggle != null)
                                    const SizedBox(width: MEDIUM_SPACE),
                                  labelBuilder(context, item.data, index),
                                  const Spacer(),
                                  Icon(
                                    Icons.drag_handle,
                                    color: lightTheme
                                        ? theme.primaryDark
                                        : theme.primaryLight,
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: provider.items.length,
                          onReorder: (int oldIndex, int newIndex) {
                            provider.reorder(oldIndex, newIndex);
                            onReorder(provider.items
                                .map((ReorderableItem<T> item) => item.data)
                                .toList(growable: false));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
