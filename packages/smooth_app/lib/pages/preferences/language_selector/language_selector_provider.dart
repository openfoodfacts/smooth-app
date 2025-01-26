part of 'language_selector.dart';

/// A provider with 4 states:
/// * [_LanguageSelectorInitialState]: initial state, no languages
/// * [_LanguageSelectorLoadingState]: loading languages
/// * [_LanguageSelectorLoadedState]: languages loaded and/or saved
/// * [_LanguageSelectorEditingState]: the user has selected a country
/// (temporary selection)
class _LanguageSelectorProvider
    extends PreferencesSelectorProvider<OpenFoodFactsLanguage> {
  _LanguageSelectorProvider({
    required super.preferences,
    required super.autoValidate,
  });

  String? userAppLanguageCode;

  @override
  Future<void> onPreferencesChanged() async {
    final String? newLanguageCode = preferences.appLanguageCode;

    if (newLanguageCode != userAppLanguageCode) {
      userAppLanguageCode = newLanguageCode;

      if (value is PreferencesSelectorInitialState<OpenFoodFactsLanguage>) {
        return loadValues();
      } else {
        final PreferencesSelectorLoadedState<OpenFoodFactsLanguage> state =
            value as PreferencesSelectorLoadedState<OpenFoodFactsLanguage>;

        /// Reorder items
        final List<OpenFoodFactsLanguage> languages = state.items;
        _reorderLanguages(languages, userAppLanguageCode!);

        value = state.copyWith(
          selectedItem: getSelectedValue(state.items),
          items: languages,
        );
      }
    }
  }

  @override
  Future<List<OpenFoodFactsLanguage>> onLoadValues() async {
    List<OpenFoodFactsLanguage> localizedLanguages;

    localizedLanguages = Languages().getSupportedLanguagesNameInEnglish();

    final List<OpenFoodFactsLanguage> languages = await compute(
      _reformatLanguages,
      (localizedLanguages, userAppLanguageCode!),
    );

    return languages;
  }

  static Future<List<OpenFoodFactsLanguage>> _reformatLanguages(
      (
        List<OpenFoodFactsLanguage> languages,
        String userAppLanguageCode,
      ) val) async {
    _reorderLanguages(val.$1, val.$2);
    return val.$1;
  }

  static void _reorderLanguages(
    List<OpenFoodFactsLanguage> languagesList,
    String userAppLanguageCode,
  ) {
    final Languages languages = Languages();
    final String userLanguageName = languages.getNameInEnglish(
        OpenFoodFactsLanguage.fromOffTag(userAppLanguageCode)!);

    languagesList.sort(
      (final OpenFoodFactsLanguage a, final OpenFoodFactsLanguage b) {
        final String aName = languages.getNameInEnglish(a);
        final String bName = languages.getNameInEnglish(b);

        if (aName == userLanguageName) {
          return -1;
        }
        if (bName == userLanguageName) {
          return 1;
        }
        return aName.compareTo(bName);
      },
    );
  }

  @override
  OpenFoodFactsLanguage getSelectedValue(
    List<OpenFoodFactsLanguage> languages,
  ) {
    if (userAppLanguageCode != null) {
      for (final OpenFoodFactsLanguage language in languages) {
        if (language.offTag == userAppLanguageCode) {
          return language;
        }
      }
    }
    return languages[0];
  }

  @override
  Future<void> onSaveItem(OpenFoodFactsLanguage country) =>
      preferences.setAppLanguageCode(
        country.offTag,
      );
}
