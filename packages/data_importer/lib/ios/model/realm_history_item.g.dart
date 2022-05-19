// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_history_item.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class HistoryItem extends _HistoryItem with RealmEntity, RealmObject {
  HistoryItem(
    String barcode,
    DateTime timestamp, {
    String? productName,
    String? brand,
    String? quantity,
    String? packaging,
    String? labels,
    String? imageUrl,
    String? nutriscore,
    String? ecoscore,
    int? novaGroup,
  }) {
    RealmObject.set(this, 'barcode', barcode);
    RealmObject.set(this, 'productName', productName);
    RealmObject.set(this, 'brand', brand);
    RealmObject.set(this, 'quantity', quantity);
    RealmObject.set(this, 'packaging', packaging);
    RealmObject.set(this, 'labels', labels);
    RealmObject.set(this, 'imageUrl', imageUrl);
    RealmObject.set(this, 'timestamp', timestamp);
    RealmObject.set(this, 'nutriscore', nutriscore);
    RealmObject.set(this, 'ecoscore', ecoscore);
    RealmObject.set(this, 'novaGroup', novaGroup);
  }

  HistoryItem._();

  @override
  String get barcode => RealmObject.get<String>(this, 'barcode') as String;
  @override
  set barcode(String value) => throw RealmUnsupportedSetError();

  @override
  String? get productName =>
      RealmObject.get<String>(this, 'productName') as String?;
  @override
  set productName(String? value) => RealmObject.set(this, 'productName', value);

  @override
  String? get brand => RealmObject.get<String>(this, 'brand') as String?;
  @override
  set brand(String? value) => RealmObject.set(this, 'brand', value);

  @override
  String? get quantity => RealmObject.get<String>(this, 'quantity') as String?;
  @override
  set quantity(String? value) => RealmObject.set(this, 'quantity', value);

  @override
  String? get packaging =>
      RealmObject.get<String>(this, 'packaging') as String?;
  @override
  set packaging(String? value) => RealmObject.set(this, 'packaging', value);

  @override
  String? get labels => RealmObject.get<String>(this, 'labels') as String?;
  @override
  set labels(String? value) => RealmObject.set(this, 'labels', value);

  @override
  String? get imageUrl => RealmObject.get<String>(this, 'imageUrl') as String?;
  @override
  set imageUrl(String? value) => RealmObject.set(this, 'imageUrl', value);

  @override
  DateTime get timestamp =>
      RealmObject.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) => RealmObject.set(this, 'timestamp', value);

  @override
  String? get nutriscore =>
      RealmObject.get<String>(this, 'nutriscore') as String?;
  @override
  set nutriscore(String? value) => RealmObject.set(this, 'nutriscore', value);

  @override
  String? get ecoscore => RealmObject.get<String>(this, 'ecoscore') as String?;
  @override
  set ecoscore(String? value) => RealmObject.set(this, 'ecoscore', value);

  @override
  int? get novaGroup => RealmObject.get<int>(this, 'novaGroup') as int?;
  @override
  set novaGroup(int? value) => RealmObject.set(this, 'novaGroup', value);

  @override
  Stream<RealmObjectChanges<HistoryItem>> get changes =>
      RealmObject.getChanges<HistoryItem>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(HistoryItem._);
    return const SchemaObject(HistoryItem, [
      SchemaProperty('barcode', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('productName', RealmPropertyType.string, optional: true),
      SchemaProperty('brand', RealmPropertyType.string, optional: true),
      SchemaProperty('quantity', RealmPropertyType.string, optional: true),
      SchemaProperty('packaging', RealmPropertyType.string, optional: true),
      SchemaProperty('labels', RealmPropertyType.string, optional: true),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('nutriscore', RealmPropertyType.string, optional: true),
      SchemaProperty('ecoscore', RealmPropertyType.string, optional: true),
      SchemaProperty('novaGroup', RealmPropertyType.int, optional: true),
    ]);
  }
}
