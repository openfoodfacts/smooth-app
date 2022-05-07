import 'dart:collection';

import 'package:collection/collection.dart';

/// List of [num] with a max length of [_maxCapacity], where we can easily
/// compute the average value
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
    }
  }

  @override
  void add(T element) {
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
