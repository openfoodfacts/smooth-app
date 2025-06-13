class ReorderableItem<T> {
  ReorderableItem({required this.data, this.visible = true});

  final T data;
  final bool visible;

  ReorderableItem<T> copyWith({bool? visible}) {
    return ReorderableItem<T>(
      data: data,
      visible: visible ?? this.visible,
    );
  }
}
