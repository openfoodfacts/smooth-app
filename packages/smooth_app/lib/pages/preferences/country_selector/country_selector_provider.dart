part of 'country_selector.dart';

/// A provider with 4 states:
/// * [_CountrySelectorInitialState]: initial state, no countries
/// * [_CountrySelectorLoadingState]: loading countries
/// * [_CountrySelectorLoadedState]: countries loaded and/or saved
/// * [_CountrySelectorEditingState]: the user has selected a country
/// (temporary selection)
class _CountrySelectorProvider extends PreferencesSelectorProvider<Country> {
  _CountrySelectorProvider({
    required super.preferences,
    required super.autoValidate,
  });

  String? userCountryCode;
  String? userAppLanguageCode;

  @override
  Future<void> onPreferencesChanged() async {
    final String? newCountryCode = preferences.userCountryCode;
    final String? newLanguageCode = preferences.appLanguageCode;

    if (newLanguageCode != userAppLanguageCode) {
      userCountryCode = newCountryCode;
      userAppLanguageCode = newLanguageCode;
      return loadValues();
    } else if (newCountryCode != userCountryCode) {
      userCountryCode = newCountryCode;
      userAppLanguageCode = newLanguageCode;

      if (value is PreferencesSelectorInitialState<Country>) {
        return loadValues();
      } else {
        final PreferencesSelectorLoadedState<Country> state =
            value as PreferencesSelectorLoadedState<Country>;

        /// Reorder items
        final List<Country> countries = state.items;
        _reorderCountries(countries, userCountryCode);

        value = state.copyWith(
          selectedItem: getSelectedValue(state.items),
          items: countries,
        );
      }
    }
  }

  @override
  Future<List<Country>> onLoadValues() async {
    List<Country> localizedCountries;

    try {
      localizedCountries =
          await IsoCountries.isoCountriesForLocale(userAppLanguageCode);
    } on MissingPluginException catch (_) {
      // Locales are not implemented on desktop and web
      localizedCountries = <Country>[
        const Country(name: 'United States', countryCode: 'US'),
        const Country(name: 'France', countryCode: 'FR'),
        const Country(name: 'Germany', countryCode: 'DE'),
        const Country(name: 'India', countryCode: 'IN'),
      ];
    }

    final List<Country> countries = await compute(
      _reformatCountries,
      (localizedCountries, userCountryCode),
    );

    return countries;
  }

  static Future<List<Country>> _reformatCountries(
    (List<Country>, String?) localizedCountriesAndUserCountry,
  ) async {
    final List<Country> countries =
        _sanitizeCountriesList(localizedCountriesAndUserCountry.$1);
    _reorderCountries(countries, localizedCountriesAndUserCountry.$2);
    return countries;
  }

  /// Sanitizes the country list, but without reordering it.
  /// * by removing countries that are not in [OpenFoodFactsCountry]
  /// * and providing a fallback English name for countries that are in
  /// [OpenFoodFactsCountry] but not in [localizedCountries].
  static List<Country> _sanitizeCountriesList(
    List<Country> localizedCountries,
  ) {
    final List<Country> finalCountriesList = <Country>[];
    final Map<String, OpenFoodFactsCountry> oFFIsoCodeToCountry =
        <String, OpenFoodFactsCountry>{};
    final Map<String, Country> localizedIsoCodeToCountry = <String, Country>{};
    for (final OpenFoodFactsCountry c in OpenFoodFactsCountry.values) {
      oFFIsoCodeToCountry[c.offTag.toLowerCase()] = c;
    }
    for (final Country c in localizedCountries) {
      localizedIsoCodeToCountry.putIfAbsent(
          c.countryCode.toLowerCase(), () => c);
    }
    for (final String countryCode in oFFIsoCodeToCountry.keys) {
      final Country? localizedCountry = localizedIsoCodeToCountry[countryCode];
      if (localizedCountry == null) {
        // No localization for the country name was found, use English name as
        // default.
        String countryName = oFFIsoCodeToCountry[countryCode]
            .toString()
            .replaceAll('OpenFoodFactsCountry.', '')
            .replaceAll('_', ' ');
        countryName =
            '${countryName[0].toUpperCase()}${countryName.substring(1).toLowerCase()}';
        finalCountriesList.add(
          Country(
              name: _fixCountryName(countryName),
              countryCode: _fixCountryCode(countryCode)),
        );
        continue;
      }
      final String fixedCountryCode = _fixCountryCode(countryCode);
      final Country country = fixedCountryCode == countryCode
          ? localizedCountry
          : Country(name: localizedCountry.name, countryCode: countryCode);
      finalCountriesList.add(country);
    }

    return finalCountriesList;
  }

  /// Fix the countryCode if needed so Backend can process it.
  static String _fixCountryCode(String countryCode) {
    // 'gb' is handled as 'uk' in the backend.
    if (countryCode == 'gb') {
      countryCode = 'uk';
    }
    return countryCode;
  }

  /// Fix the issues where United Kingdom appears with lowercase 'k'.
  static String _fixCountryName(String countryName) {
    if (countryName == 'United kingdom') {
      countryName = 'United Kingdom';
    }
    return countryName;
  }

  /// Reorder countries alphabetically, bring user's locale country to top.
  static void _reorderCountries(
    List<Country> countries,
    String? userCountryCode,
  ) {
    countries.sort(
      (final Country a, final Country b) {
        if (a.countryCode == userCountryCode) {
          return -1;
        }
        if (b.countryCode == userCountryCode) {
          return 1;
        }
        return a.name.compareTo(b.name);
      },
    );
  }

  @override
  Country getSelectedValue(List<Country> countries) {
    if (userCountryCode != null) {
      for (final Country country in countries) {
        if (country.countryCode.toLowerCase() ==
            userCountryCode?.toLowerCase()) {
          return country;
        }
      }
    }
    return countries[0];
  }

  @override
  Future<void> onSaveItem(Country country) => preferences.setUserCountryCode(
        country.countryCode,
      );
}
