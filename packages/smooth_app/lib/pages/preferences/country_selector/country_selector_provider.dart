part of 'country_selector.dart';

/// A provider with 4 states:
/// * [_CountrySelectorInitialState]: initial state, no countries
/// * [_CountrySelectorLoadingState]: loading countries
/// * [_CountrySelectorLoadedState]: countries loaded and/or saved
/// * [_CountrySelectorEditingState]: the user has selected a country
/// (temporary selection)
class _CountrySelectorProvider
    extends PreferencesSelectorProvider<OpenFoodFactsCountry> {
  _CountrySelectorProvider({
    required super.preferences,
    required super.autoValidate,
  });

  String? userCountryCode;
  OpenFoodFactsLanguage? userAppLanguage;

  @override
  Future<void> onPreferencesChanged() async {
    final String? newCountryCode = preferences.userCountryCode;
    final String? newLanguageCode = preferences.appLanguageCode;
    final OpenFoodFactsLanguage? newLanguage =
        _getLanguageFromCode(newLanguageCode);

    if (newLanguage != userAppLanguage) {
      userCountryCode = newCountryCode;
      userAppLanguage = newLanguage;
      return loadValues();
    } else if (newCountryCode != userCountryCode) {
      userCountryCode = newCountryCode;
      userAppLanguage = newLanguage;

      if (value is PreferencesSelectorInitialState<OpenFoodFactsCountry>) {
        return loadValues();
      } else {
        final PreferencesSelectorLoadedState<OpenFoodFactsCountry> state =
            value as PreferencesSelectorLoadedState<OpenFoodFactsCountry>;

        final List<OpenFoodFactsCountry> countries = state.items;
        _reorderCountries(countries, userCountryCode);

        value = state.copyWith(
          selectedItem: getSelectedValue(state.items),
          items: countries,
        );
      }
    }
  }

  @override
  Future<List<OpenFoodFactsCountry>> onLoadValues() async {
    final List<OpenFoodFactsCountry> countries = await compute(
      _reformatCountries,
      (OpenFoodFactsCountry.values, userCountryCode),
    );

    return countries;
  }

  static Future<List<OpenFoodFactsCountry>> _reformatCountries(
    (List<OpenFoodFactsCountry>, String?) countriesAndUserCode,
  ) async {
    final List<OpenFoodFactsCountry> countries =
        _sanitizeCountriesList(countriesAndUserCode.$1);
    _reorderCountries(countries, countriesAndUserCode.$2);
    return countries;
  }

  /// Keep all countries from the enum, and sort them alphabetically
  static List<OpenFoodFactsCountry> _sanitizeCountriesList(
    List<OpenFoodFactsCountry> allCountries,
  ) {
    final List<OpenFoodFactsCountry> sorted =
        List<OpenFoodFactsCountry>.from(allCountries);
    sorted.sort(
      (a, b) => (a.getLocalizedName(OpenFoodFactsLanguage.ENGLISH) ?? '')
          .compareTo(b.getLocalizedName(OpenFoodFactsLanguage.ENGLISH) ?? ''),
    );
    return sorted;
  }

  static void _reorderCountries(
    List<OpenFoodFactsCountry> countries,
    String? userCountryCode,
  ) {
    countries.sort(
      (a, b) {
        if (a.offTag == userCountryCode) return -1;
        if (b.offTag == userCountryCode) return 1;
        return (a.getLocalizedName(OpenFoodFactsLanguage.ENGLISH) ?? '')
            .compareTo(b.getLocalizedName(OpenFoodFactsLanguage.ENGLISH) ?? '');
      },
    );
  }

  @override
  OpenFoodFactsCountry getSelectedValue(List<OpenFoodFactsCountry> countries) {
    if (userCountryCode != null) {
      return countries.firstWhere(
        (country) =>
            country.offTag.toLowerCase() == userCountryCode?.toLowerCase(),
        orElse: () => countries.first,
      );
    }
    return countries.first;
  }

  @override
  Future<void> onSaveItem(OpenFoodFactsCountry country) =>
      preferences.setUserCountryCode(country.offTag);

  OpenFoodFactsLanguage? _getLanguageFromCode(String? code) {
    if (code == null) {
      return null;
    }
    return OpenFoodFactsLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => OpenFoodFactsLanguage.ENGLISH,
    );
  }
}
