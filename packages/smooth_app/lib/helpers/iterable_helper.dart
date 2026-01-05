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
}
