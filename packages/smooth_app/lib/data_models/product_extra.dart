import 'dart:convert';

/// Extra data attached to a Product when it belongs to a ProductList
class ProductExtra {
  ProductExtra(
    this.intValue,
    this.stringValue,
  );

  int intValue;
  String stringValue;

  /// Decode the string into a List<int>, when applicable
  /// To be used for timestamps like history or scans
  List<int> decodeStringAsIntList() =>
      (jsonDecode(stringValue) as List<dynamic>).cast<int>();

  @override
  String toString() => '$intValue ; $stringValue';
}
