extension IterableExtensions<E> on Iterable<E> {
  int indexOf(E element, {int defaultValue = -1}) {
    int index = 0;
    for (final E item in this) {
      if (item == element) {
        return index;
      }
      index++;
    }
    return defaultValue;
  }

  Iterable<E> subList(int start, [int? end]) {
    final List<E> result = <E>[];
    int index = 0;
    for (final E item in this) {
      if (index >= start && (end == null || index < end)) {
        result.add(item);
      }
      index++;
      if (end != null && index >= end) {
        break;
      }
    }
    return result;
  }
}
