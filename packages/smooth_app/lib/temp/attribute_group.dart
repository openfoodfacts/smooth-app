import 'package:openfoodfacts/interface/JsonObject.dart';
import 'package:smooth_app/temp/attribute.dart';

class AttributeGroup extends JsonObject {
  AttributeGroup({
    this.id,
    this.name,
    this.warning,
    this.attributes,
  });

  factory AttributeGroup.fromJson(dynamic json) => AttributeGroup(
        id: json[_JSON_TAG_ID] as String,
        name: json[_JSON_TAG_NAME] as String,
        warning: json[_JSON_TAG_WARNING] as String,
        attributes: (json[_JSON_TAG_ATTRIBUTES] as List<dynamic>)
            ?.map((dynamic item) => Attribute.fromJson(item))
            ?.toList(),
      );

  @override
  Map<String, dynamic>
      toJson() => // TODO(monsieurtanuki): branch to JsonObject.removeNullEntries when available
          Attribute.JsonObject_removeNullEntries(<String, dynamic>{
            _JSON_TAG_ID: id,
            _JSON_TAG_NAME: name,
            _JSON_TAG_WARNING: warning,
            _JSON_TAG_ATTRIBUTES: _listToJson(),
          });

  static const String _JSON_TAG_ID = 'id';
  static const String _JSON_TAG_NAME = 'name';
  static const String _JSON_TAG_WARNING = 'warning';
  static const String _JSON_TAG_ATTRIBUTES = 'attributes';

  final String id;
  final String name;
  final String warning;
  final List<Attribute> attributes;

  @override
  String toString() => 'AttributeGroup(${toJson()})';

  List<Map<String, dynamic>> _listToJson() {
    if (attributes == null || attributes.isEmpty) {
      return null;
    }
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
    for (final Attribute item in attributes) {
      result.add(item.toJson());
    }
    return result;
  }
}
