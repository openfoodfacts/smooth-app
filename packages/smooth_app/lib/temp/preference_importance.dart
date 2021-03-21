/// Importance level when we match products to preferences.
/// Will be loaded in JSON as a list of increasingly important items.
class PreferenceImportance {
  PreferenceImportance({this.id, this.name, this.factor, this.minimalMatch});

  factory PreferenceImportance.fromJson(dynamic json) => PreferenceImportance(
        id: _checkedId(json['id'] as String),
        name: json['name'] as String,
        factor: json['factor'] as int,
        minimalMatch: json['minimum_match'] as int,
      );

  final String id;
  final String name;
  final int factor;
  final int minimalMatch;

  /// The index of the least important, therefore 0 (which is "NOT" important).
  static const int INDEX_NOT_IMPORTANT = 0;

  static const String ID_NOT_IMPORTANT = 'not_important';
  static const String ID_IMPORTANT = 'important';
  static const String ID_VERY_IMPORTANT = 'very_important';
  static const String ID_MANDATORY = 'mandatory';

  static const List<String> IDS = <String>[
    ID_NOT_IMPORTANT,
    ID_IMPORTANT,
    ID_VERY_IMPORTANT,
    ID_MANDATORY,
  ];

  @override
  String toString() => 'PreferenceImportance('
      'id: $id, name: $name, factor: $factor, minimalWatch: $minimalMatch'
      ')';

  static String _checkedId(final String id) =>
      IDS.contains(id) ? id : throw Exception('Unknown id "$id"');
}
