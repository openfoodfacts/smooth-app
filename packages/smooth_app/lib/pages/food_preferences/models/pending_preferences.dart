import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Manages pending (unsaved) food preference changes during the preferences wizard.
///
/// This class acts as a temporary buffer between the UI and [UserPreferences],
/// allowing users to make multiple preference changes before committing them.
/// Changes are stored in memory and only persisted when [saveAll] is called.
///
/// Key responsibilities:
/// - Tracks pending attribute importance changes (e.g., nutrition, allergens)
/// - Manages the list of unwanted ingredients
/// - Supports project-specific preferences (foods, beauty, pets, etc.)
/// - Provides methods to query and modify pending preferences
///
/// Use [saveAll] to persist all pending changes to [UserPreferences].
class PendingPreferences extends ChangeNotifier {
  PendingPreferences({
    required UserPreferences userPreferences,
    required List<AttributeGroup> attributeGroups,
    required PreferencesPageProjects project,
  }) : _userPreferences = userPreferences,
       _attributeGroups = attributeGroups,
       _project = project {
    _initializeFromCurrentPreferences();
  }

  bool _unwantedIngredientsInitialized = false;

  static const String enabledImportanceId = PreferenceImportance.ID_MANDATORY;

  final UserPreferences _userPreferences;
  final List<AttributeGroup> _attributeGroups;
  final PreferencesPageProjects _project;

  String get _projectKey => _project.name;

  final Map<String, String> _pendingImportances = <String, String>{};

  List<String> _pendingUnwantedIngredients = <String>[];
  static const String disabledImportanceId =
      PreferenceImportance.ID_NOT_IMPORTANT;

  Future<void> _initializeFromCurrentPreferences() async {
    for (final AttributeGroup group in _attributeGroups) {
      for (final Attribute attribute in group.attributes ?? <Attribute>[]) {
        final String? attributeId = attribute.id;
        if (attributeId != null) {
          _pendingImportances[attributeId] = _userPreferences
              .getImportanceForProject(attributeId, _projectKey);
        }
      }
    }
    _loadExcludedIngredients();
  }

  Future<void> _loadExcludedIngredients() async {
    // Load user-facing names from preferences
    _pendingUnwantedIngredients = _userPreferences
        .getUnwantedIngredientsForProject(_projectKey);
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
        (MapEntry<String, String> entry) => _userPreferences
            .setImportanceForProject(entry.key, entry.value, _projectKey),
      ),
    );

    await _saveUnwantedIngredients();
  }

  Future<void> _saveUnwantedIngredients() async {
    if (_pendingUnwantedIngredients.isEmpty) {
      await _userPreferences.setUnwantedIngredientsForProject(
        <String, String>{},
        _projectKey,
      );
      return;
    }

    final MaybeError<Map<String, String>> result =
        await OpenFoodAPIClient.getCanonicalTags(
          TagType.INGREDIENTS,
          localizedNames: _pendingUnwantedIngredients,
          language: ProductQuery.getLanguage(),
          uriHelper: _project.getUriProductHelper(),
        );

    final Map<String, String> ingredientsMap = <String, String>{};

    if (!result.isError) {
      for (final String ingredient in _pendingUnwantedIngredients) {
        ingredientsMap[ingredient] = result.value[ingredient] ?? ingredient;
      }
    }

    await _userPreferences.setUnwantedIngredientsForProject(
      ingredientsMap,
      _projectKey,
    );
  }

  List<AttributeGroup> get attributeGroups => _attributeGroups;

  PreferencesPageProjects get project => _project;
}
