import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';

class PendingPreferences extends ChangeNotifier {
  PendingPreferences({
    required ProductPreferences productPreferences,
    required List<AttributeGroup> attributeGroups,
  }) : _productPreferences = productPreferences,
       _attributeGroups = attributeGroups {
    _initializeFromCurrentPreferences();
  }

  final ProductPreferences _productPreferences;
  final List<AttributeGroup> _attributeGroups;

  final Map<String, String> _pendingImportances = <String, String>{};

  static const String enabledImportanceId = PreferenceImportance.ID_MANDATORY;
  static const String disabledImportanceId =
      PreferenceImportance.ID_NOT_IMPORTANT;

  void _initializeFromCurrentPreferences() {
    for (final AttributeGroup group in _attributeGroups) {
      for (final Attribute attribute in group.attributes ?? <Attribute>[]) {
        final String? attributeId = attribute.id;
        if (attributeId != null) {
          _pendingImportances[attributeId] = _productPreferences
              .getImportanceIdForAttributeId(attributeId);
        }
      }
    }
  }

  String getImportanceIdForAttributeId(String attributeId) {
    return _pendingImportances[attributeId] ?? disabledImportanceId;
  }

  bool isAttributeEnabled(String attributeId) {
    return getImportanceIdForAttributeId(attributeId) != disabledImportanceId;
  }

  void setImportance(String attributeId, String importanceId) {
    _pendingImportances[attributeId] = importanceId;
    notifyListeners();
  }

  void toggleAttribute(String attributeId) {
    final bool isCurrentlyEnabled = isAttributeEnabled(attributeId);
    setImportance(
      attributeId,
      isCurrentlyEnabled ? disabledImportanceId : enabledImportanceId,
    );
  }

  List<Attribute> getSelectedAttributesForGroup(AttributeGroup group) {
    final List<Attribute> selected = <Attribute>[];
    for (final Attribute attribute in group.attributes ?? <Attribute>[]) {
      final String? attributeId = attribute.id;
      if (attributeId != null && isAttributeEnabled(attributeId)) {
        selected.add(attribute);
      }
    }
    return selected;
  }

  bool get hasAnySelection {
    for (final AttributeGroup group in _attributeGroups) {
      if (getSelectedAttributesForGroup(group).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<void> saveAll() async {
    await Future.wait(
      _pendingImportances.entries.map(
        (MapEntry<String, String> entry) =>
            _productPreferences.setImportance(entry.key, entry.value),
      ),
    );
  }

  List<AttributeGroup> get attributeGroups => _attributeGroups;
}
