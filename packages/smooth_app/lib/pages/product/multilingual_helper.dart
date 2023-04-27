import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/query/product_query.dart';

/// Helper for multilingual inputs (e.g. product name).
///
/// There are 2 versions of the input:
/// 1. the old one - only one text per product
/// 2. the multilingual one
/// Typically, the old version will be used with "old" data, that have not
/// downloaded yet the more "recent" multilingual fields
/// (e.g. [ProductField.NAME_ALL_LANGUAGES]).
class MultilingualHelper {
  MultilingualHelper({required this.controller});

  final TextEditingController controller;

  /// Current language; only relevant/valid if _names is not empty.
  late OpenFoodFactsLanguage _currentLanguage;

  /// Initial monolingual text.
  late final String? _initialMonolingualText;

  /// Initial multilingual texts.
  final Map<OpenFoodFactsLanguage, String> _initialMultilingualTexts =
      <OpenFoodFactsLanguage, String>{};

  /// Current multilingual texts.
  final Map<OpenFoodFactsLanguage, String> _currentMultilingualTexts =
      <OpenFoodFactsLanguage, String>{};

  void init({
    required final Map<OpenFoodFactsLanguage, String>? multilingualTexts,
    required final String? monolingualText,
  }) {
    _initialMonolingualText = monolingualText;
    // checking if we use the multilingual version...
    if (multilingualTexts != null) {
      for (final OpenFoodFactsLanguage language in multilingualTexts.keys) {
        final String name = getCleanText(multilingualTexts[language]);
        if (name.isNotEmpty) {
          _initialMultilingualTexts[language] = name;
          _currentMultilingualTexts[language] = name;
        }
      }
      if (_initialMultilingualTexts.isNotEmpty) {
        // fallback
        _currentLanguage = _initialMultilingualTexts.keys.first;
        final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
        if (_initialMultilingualTexts.containsKey(language)) {
          // best choice: the current app language
          _currentLanguage = language;
        } else {
          // second best choice: the same language as the "main" text
          for (final MapEntry<OpenFoodFactsLanguage, String> entry
              in _initialMultilingualTexts.entries) {
            if (entry.value == _initialMonolingualText) {
              _currentLanguage = entry.key;
            }
          }
        }
        controller.text = _initialMultilingualTexts[_currentLanguage] ?? '';
      }
    }
    // Fallback: we may have old data where there are no translations.
    if (_initialMultilingualTexts.isEmpty) {
      controller.text = _initialMonolingualText ?? '';
    }
  }

  bool isMonolingual() => _initialMultilingualTexts.isEmpty;

  Widget getLanguageSelector(void Function(void Function()) setState) =>
      LanguageSelector(
        setLanguage: (
          final OpenFoodFactsLanguage? newLanguage,
        ) async {
          if (newLanguage == null) {
            return;
          }
          if (_currentLanguage == newLanguage) {
            return;
          }
          _saveCurrentName();
          setState(() {
            _currentLanguage = newLanguage;
            _currentMultilingualTexts[_currentLanguage] ??= '';
            controller.text = _currentMultilingualTexts[_currentLanguage]!;
          });
        },
        selectedLanguages: _currentMultilingualTexts.keys,
        displayedLanguage: _currentLanguage,
      );

  /// Returns the new text, if any change happened.
  String? getChangedMonolingualText() {
    if (!isMonolingual()) {
      return null;
    }
    final String result = getCleanText(controller.text);
    if (result != getCleanText(_initialMonolingualText)) {
      return result;
    }
    return null;
  }

  /// Returns all the new texts, if any change happened.
  Map<OpenFoodFactsLanguage, String>? getChangedMultilingualText() {
    if (isMonolingual()) {
      return null;
    }
    _saveCurrentName();
    bool changed = false;
    final Map<OpenFoodFactsLanguage, String> result =
        <OpenFoodFactsLanguage, String>{};

    // setting new names, comparing them to old names for change flag.
    void setNewName(final OpenFoodFactsLanguage language) {
      final String newName = getCleanText(_currentMultilingualTexts[language]);
      final String oldName = getCleanText(_initialMultilingualTexts[language]);
      if (newName != oldName) {
        changed = true;
      }
      result[language] = newName;
    }

    _currentMultilingualTexts.keys.forEach(setNewName);

    if (!changed) {
      return null;
    }
    return result;
  }

  /// Saves the current input for the current language.
  void _saveCurrentName() =>
      _currentMultilingualTexts[_currentLanguage] = controller.text;

  OpenFoodFactsLanguage getCurrentLanguage() =>
      isMonolingual() ? ProductQuery.getLanguage() : _currentLanguage;

  static String getCleanText(final String? name) => (name ?? '').trim();
}
