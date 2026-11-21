/// Stable (List.sort is not): pinned items first, relative order kept.
List<T> sortPinnedFirst<T>(List<T> items, bool Function(T) isPinned) {
  final List<T> pinned = <T>[];
  final List<T> others = <T>[];
  for (final T item in items) {
    (isPinned(item) ? pinned : others).add(item);
  }
  return <T>[...pinned, ...others];
}
