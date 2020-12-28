import 'package:openfoodfacts/interface/JsonObject.dart';

class Attribute extends JsonObject {
  Attribute({
    this.id,
    this.name,
    this.title,
    this.iconUrl,
    this.defaultF,
    this.settingNote,
    this.settingName,
    this.description,
    this.shortDescription,
    this.match,
    this.status,
  });

  factory Attribute.fromJson(dynamic json) => Attribute(
        id: json[_JSON_TAG_ID] as String,
        name: json[_JSON_TAG_NAME] as String,
        title: json[_JSON_TAG_TITLE] as String,
        iconUrl: json[_JSON_TAG_ICON_URL] as String,
        defaultF: json[_JSON_TAG_DEFAULT] as String,
        settingNote: json[_JSON_TAG_SETTING_NOTE] as String,
        settingName: json[_JSON_TAG_SETTING_NAME] as String,
        description: json[_JSON_TAG_DESCRIPTION] as String,
        shortDescription: json[_JSON_TAG_DESCRIPTION_SHORT] as String,
        match: JsonObject.parseDouble(json[_JSON_TAG_MATCH]),
        status: json[_JSON_TAG_STATUS] as String,
      );

  @override
  Map<String, dynamic>
      toJson() => // TODO(monsieurtanuki): branch to JsonObject.removeNullEntries when available
          JsonObject_removeNullEntries(<String, dynamic>{
            _JSON_TAG_ID: id,
            _JSON_TAG_NAME: name,
            _JSON_TAG_TITLE: title,
            _JSON_TAG_ICON_URL: iconUrl,
            _JSON_TAG_DEFAULT: defaultF,
            _JSON_TAG_SETTING_NOTE: settingNote,
            _JSON_TAG_SETTING_NAME: settingName,
            _JSON_TAG_DESCRIPTION: description,
            _JSON_TAG_DESCRIPTION_SHORT: shortDescription,
            _JSON_TAG_MATCH: match,
            _JSON_TAG_STATUS: status,
          });

  static const String _JSON_TAG_ID = 'id';
  static const String _JSON_TAG_NAME = 'name';
  static const String _JSON_TAG_TITLE = 'title';
  static const String _JSON_TAG_ICON_URL = 'icon_url';
  static const String _JSON_TAG_DEFAULT = 'default';
  static const String _JSON_TAG_SETTING_NOTE = 'setting_note';
  static const String _JSON_TAG_SETTING_NAME = 'setting_name';
  static const String _JSON_TAG_DESCRIPTION = 'description';
  static const String _JSON_TAG_DESCRIPTION_SHORT = 'description_short';
  static const String _JSON_TAG_MATCH = 'match';
  static const String _JSON_TAG_STATUS = 'status';

  final String id;
  final String name;
  final String title;
  final String iconUrl;
  final String defaultF;
  final String settingNote;
  final String settingName;
  final String description;
  final String shortDescription;
  final double match;
  final String status;

  @override
  String toString() => 'Attribute(${toJson()})';

  // TODO(monsieurtanuki): remove when the lib is upgraded
  static Map<String, dynamic> JsonObject_removeNullEntries(
      final Map<String, dynamic> input) {
    if (input == null) {
      return null;
    }
    final Map<String, dynamic> result = <String, dynamic>{};
    input.forEach((String key, dynamic value) {
      if (key != null) {
        result[key] = value;
      }
    });
    return result;
  }
}
