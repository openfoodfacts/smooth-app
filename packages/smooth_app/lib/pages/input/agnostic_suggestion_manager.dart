import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/input/brand_suggestion_manager.dart';

// TODO(monsieurtanuki): there's probably a more elegant way to do it.
/// Suggestion manager for "old" taxonomies and elastic search taxonomies.
class AgnosticSuggestionManager {
  AgnosticSuggestionManager.tagType(this.tagTypeSuggestionManager)
      : brandSuggestionManager = null;

  AgnosticSuggestionManager.brand()
      : brandSuggestionManager = BrandSuggestionManager(),
        tagTypeSuggestionManager = null;

  final SuggestionManager? tagTypeSuggestionManager;
  final BrandSuggestionManager? brandSuggestionManager;

  Future<List<String>> getSuggestions(
    final String input,
  ) async {
    if (tagTypeSuggestionManager != null) {
      return tagTypeSuggestionManager!.getSuggestions(input);
    }
    if (brandSuggestionManager != null) {
      return brandSuggestionManager!.getSuggestions(input);
    }
    return <String>[];
  }
}
