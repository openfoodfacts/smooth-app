import 'package:flutter/material.dart';

class DataProvider<T> with ChangeNotifier {
  DataProvider(this._value);

  T _value;

  T get value => _value;

  void setValue(T newValue) {
    _value = newValue;
    notifyListeners();
  }
}
