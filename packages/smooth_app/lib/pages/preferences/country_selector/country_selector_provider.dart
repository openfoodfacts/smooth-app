part of 'country_selector.dart';

/// A provider with 4 states:
/// * [_CountrySelectorInitialState]: initial state, no countries
/// * [_CountrySelectorLoadingState]: loading countries
/// * [_CountrySelectorLoadedState]: countries loaded and/or saved
/// * [_CountrySelectorEditingState]: the user has selected a country
/// (temporary selection)
class _CountrySelectorProvider
    extends PreferencesSelectorProvider<LocalizedCountry> {
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

      if (value is PreferencesSelectorInitialState<LocalizedCountry>) {
        return loadValues();
      } else {
        final PreferencesSelectorLoadedState<LocalizedCountry> state =
            value as PreferencesSelectorLoadedState<LocalizedCountry>;

        final List<LocalizedCountry> countries = state.items;
        _reorderCountries(countries, userCountryCode);

        value = state.copyWith(
          selectedItem: getSelectedValue(state.items),
          items: countries,
        );
      }
    }
  }

  @override
  Future<List<LocalizedCountry>> onLoadValues() async {
    return _sanitizeCountriesList(LocalizedCountry.getLocalizedCountries());
  }

  /// Sanitizes the country list, but without reordering it.
  /// * by removing countries that are not in [OpenFoodFactsCountry]
  /// * and providing a fallback English name for countries that are in
  /// [OpenFoodFactsCountry] but not in [localizedCountries].
  static List<LocalizedCountry> _sanitizeCountriesList(
    List<LocalizedCountry> localizedCountries,
  ) {
    final Set<OpenFoodFactsCountry> validCountries =
        OpenFoodFactsCountry.values.toSet();
    final List<LocalizedCountry> sanitizedList = localizedCountries
        .where((country) => validCountries.contains(country.country))
        .toList();

    return sanitizedList;
  }

  static void _reorderCountries(
    List<LocalizedCountry> countries,
    String? userCountryCode,
  ) {
    countries.sort(
      (a, b) {
        if (a.preferenceCode == userCountryCode) return -1;
        if (b.preferenceCode == userCountryCode) return 1;
        return a.localizedName.compareTo(b.localizedName);
      },
    );
  }

  @override
  LocalizedCountry getSelectedValue(List<LocalizedCountry> countries) {
    if (userCountryCode != null) {
      return countries.firstWhere(
        (country) =>
            country.preferenceCode.toLowerCase() ==
            userCountryCode?.toLowerCase(),
        orElse: () => countries.first,
      );
    }
    return countries.first;
  }

  @override
  Future<void> onSaveItem(LocalizedCountry country) =>
      preferences.setUserCountryCode(country.preferenceCode);

  OpenFoodFactsLanguage? _getLanguageFromCode(String? code) {
    if (code == null) {
      return null;
    }
    return OpenFoodFactsLanguage.fromOffTag(code);
  }
}
