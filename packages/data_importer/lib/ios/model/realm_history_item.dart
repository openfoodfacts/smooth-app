import 'package:realm/realm.dart';

part 'realm_history_item.g.dart';

/// Dart equivalent of the Swift POJO "HistoryItem"
/// [https://github.com/openfoodfacts/openfoodfacts-ios/blob/develop/Sources/Models/HistoryItem.swift]
///
/// Run `flutter pub run realm generate` to generate the .g.dart file
/// This library doesn't support final attributes, nor constructors
@RealmModel()
class _HistoryItem {
  @PrimaryKey()
  late final String barcode;
  String? productName;
  String? brand;
  String? quantity;
  String? packaging;
  String? labels;
  String? imageUrl;
  late DateTime timestamp;
  String? nutriscore;
  String? ecoscore;
  int? novaGroup;
}
