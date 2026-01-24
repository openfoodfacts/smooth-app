import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

// lazily made static, so that it's rebuild at each new app start.
final RandomQuestionsManager randomQuestionsManager = RandomQuestionsManager();

/// Manager for Hunger Games random questions. Avoids duplicate questions.
class RandomQuestionsManager {
  /// Number of questions downloaded so far.
  int _soFar = 0;

  /// Have we exhausted all questions?
  bool _exhausted = false;

  bool get isExhausted => _exhausted;

  /// Query language; part of the key.
  OpenFoodFactsLanguage? _language;

  OpenFoodFactsLanguage get language => _language!;

  /// Query country; part of the key.
  OpenFoodFactsCountry? _country;

  OpenFoodFactsCountry get country => _country!;

  /// Query user; part of the key.
  User? _user;

  User get user => _user!;

  /// Computed page number.
  int get page => 1 + (_soFar / _count).ceil();

  /// Requested number of questions.
  late int _count;

  int get count => _count;

  /// Computes the "page" parameter.
  void setRequest(final int count) {
    _count = count;
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    final OpenFoodFactsCountry country = ProductQuery.getCountry();
    final User user = ProductQuery.getReadUser();
    final bool changed =
        _language != language ||
        _country != country ||
        _user?.userId != user.userId;
    _language = language;
    _country = country;
    _user = user;
    if (changed) {
      // from scratch
      _soFar = 0;
      _exhausted = false;
    }
  }

  /// Sets the number of downloaded questions.
  void setResultCount(final int count) {
    _soFar += count;
    if (_count > count) {
      _exhausted = true;
    }
  }
}
