import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/query/product_query.dart';

class PendingPreferences extends ChangeNotifier {
  PendingPreferences({
    required ProductPreferences productPreferences,
    required UserPreferences userPreferences,
    required List<AttributeGroup> attributeGroups,
  }) : _productPreferences = productPreferences,
       _userPreferences = userPreferences,
       _attributeGroups = attributeGroups {
    _initializeFromCurrentPreferences();
  }

  final ProductPreferences _productPreferences;
  final UserPreferences _userPreferences;
  final List<AttributeGroup> _attributeGroups;

  final Map<String, String> _pendingImportances = <String, String>{};

  List<String> _pendingUnwantedIngredients = <String>[];
  bool _unwantedIngredientsInitialized = false;

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
    _loadExcludedIngredients();
  }

  Future<void> _loadExcludedIngredients() async {
    // Load user-facing names from preferences
    _pendingUnwantedIngredients = _userPreferences.getUnwantedIngredients();
    _unwantedIngredientsInitialized = true;
    notifyListeners();
  }

  List<String> get unwantedIngredients =>
      List<String>.unmodifiable(_pendingUnwantedIngredients);

  bool get unwantedIngredientsInitialized => _unwantedIngredientsInitialized;

  void addUnwantedIngredient(String ingredient) {
    final String trimmed = ingredient.trim();
    if (trimmed.isNotEmpty && !_pendingUnwantedIngredients.contains(trimmed)) {
      _pendingUnwantedIngredients.add(trimmed);
      notifyListeners();
    }
  }

  void removeUnwantedIngredient(String ingredient) {
    if (_pendingUnwantedIngredients.remove(ingredient)) {
      notifyListeners();
    }
  }

  bool isIngredientExcluded(String ingredient) {
    return _pendingUnwantedIngredients.contains(ingredient);
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

    await _saveUnwantedIngredients();
  }

  Future<void> _saveUnwantedIngredients() async {
    if (_pendingUnwantedIngredients.isEmpty) {
      await _userPreferences.setUnwantedIngredients(<String, String>{});
      return;
    }

    final MaybeError<Map<String, String>> result =
        await OpenFoodAPIClient.getCanonicalTags(
          TagType.INGREDIENTS,
          localizedNames: _pendingUnwantedIngredients,
          language: ProductQuery.getLanguage(),
          uriHelper: ProductQuery.getUriProductHelper(
            productType: ProductType.food,
          ),
        );

    final Map<String, String> ingredientsMap = <String, String>{};

    if (!result.isError) {
      for (final String ingredient in _pendingUnwantedIngredients) {
        ingredientsMap[ingredient] = result.value[ingredient] ?? ingredient;
      }
    }

    await _userPreferences.setUnwantedIngredients(ingredientsMap);
  }

  List<AttributeGroup> get attributeGroups => _attributeGroups;
}
