import 'package:flutter/material.dart';

/// Common search preloaded list item.
abstract class SearchPreloadedItem {
  /// Displays the list item.
  ///
  /// [onDeleteItem] is called when the user asks to remove the item. Without
  /// it, the item cannot be removed.
  /// [onFavoriteChanged] is called once the item changed its favorite status.
  Widget getWidget(
    BuildContext context, {
    VoidCallback? onDeleteItem,
    VoidCallback? onFavoriteChanged,
  });

  /// Whether this item must be displayed before the others.
  bool isPinned(BuildContext context) => false;

  /// Deletes this item from the preload list.
  Future<void> delete(BuildContext context);
}
