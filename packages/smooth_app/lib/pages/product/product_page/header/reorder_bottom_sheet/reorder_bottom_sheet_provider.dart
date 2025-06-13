import 'package:flutter/material.dart';
import 'package:smooth_app/pages/product/product_page/header/reorder_bottom_sheet/reorderable_item.dart';

class ReorderBottomSheetProvider<T> extends ChangeNotifier {
  ReorderBottomSheetProvider(this.items);

  List<ReorderableItem<T>> items;

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final ReorderableItem<T> item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    notifyListeners();
  }

  void toggleVisibility(ReorderableItem<T> item) {
    final int index = items.indexOf(item);
    if (index != -1) {
      items[index] = item.copyWith(visible: !item.visible);
      notifyListeners();
    }
  }
}
