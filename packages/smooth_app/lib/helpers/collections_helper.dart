import 'dart:collection';

import 'package:collection/collection.dart';

/// List of [num] with a max length of [_maxCapacity], where we can easily
/// compute the average value of all elements.
class AverageList<T extends num> with ListMixin<T> {
  static const int _maxCapacity = 10;
  final List<T> _elements = <T>[];

  int average(int defaultValueIfEmpty) {
    if (_elements.isEmpty) {
      return defaultValueIfEmpty;
    } else {
      return _elements.average.floor();
    }
  }

  @override
  int get length => _elements.length;

  @override
  T operator [](int index) => throw UnsupportedError(
        'Please only use the "add" method',
      );

  @override
  void operator []=(int index, T value) {
    if (index > _maxCapacity) {
      throw UnsupportedError('The index is above the capacity!');
    } else {
      _elements[index] = value;
    }
  }

  @override
  void add(T element) {
    // The first element is always the latest added
    _elements.insert(0, element);

    if (_elements.length >= _maxCapacity) {
      _elements.removeLast();
    }
  }

  @override
  set length(int newLength) {
    throw UnimplementedError('This list has a fixed size of $_maxCapacity');
  }
}

extension ListExtensions<T> on List<T> {
  void addAllSafe(Iterable<T>? elements) {
    if (elements != null) {
      addAll(elements);
    }
  }
}

extension SetExtensions<T> on Set<T> {
  void addAllSafe(Iterable<T>? elements) {
    if (elements != null) {
      addAll(elements);
    }
  }

  Iterable<Set<T>> split(int capacity) {
    final List<Set<T>> res = <Set<T>>[];

    int consumedCapacity = 0;
    do {
      res.add(skip(consumedCapacity).take(capacity).toSet());
      consumedCapacity += capacity;
    } while (consumedCapacity < length);

    return res;
  }
}

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final T element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

extension MapStringKeyExtensions<V> on Map<String, V> {
  String? keyStartingWith(String key, {bool ignoreCase = false}) {
    final String searchKey;

    if (ignoreCase) {
      searchKey = key.toLowerCase();
    } else {
      searchKey = key;
    }

    for (String mapKey in keys) {
      if (ignoreCase) {
        mapKey = mapKey.toLowerCase();
      }

      if (mapKey.startsWith(searchKey)) {
        return mapKey;
      }
    }
    return null;
  }

  V? getValueByKeyStartWith(String key, {bool ignoreCase = false}) {
    final String? mapKey = keyStartingWith(key, ignoreCase: ignoreCase);
    return this[mapKey];
  }
}
