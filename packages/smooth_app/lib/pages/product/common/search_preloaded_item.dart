import 'package:flutter/material.dart';

/// Common search preloaded list item.
abstract class SearchPreloadedItem {
  /// Displays the list item.
  Widget getWidget(
    final BuildContext context, {
    final VoidCallback? onDismissItem,
  });

  /// Deletes this item from the preload list.
  Future<void> delete(final BuildContext context);
}
