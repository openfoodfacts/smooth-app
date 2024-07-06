part of 'country_selector.dart';

/// A provider with 4 states:
/// * [_CountrySelectorInitialState]: initial state, no countries
/// * [_CountrySelectorLoadingState]: loading countries
/// * [_CountrySelectorLoadedState]: countries loaded and/or saved
/// * [_CountrySelectorEditingState]: the user has selected a country
/// (temporary selection)
class _CountrySelectorProvider extends ValueNotifier<_CountrySelectorState> {
  _CountrySelectorProvider({
    required this.preferences,
    required this.autoValidate,
  }) : super(const _CountrySelectorInitialState()) {
    preferences.addListener(_onPreferencesChanged);
    _onPreferencesChanged();
  }

  final UserPreferences preferences;
  final bool autoValidate;
  String? userCountryCode;
  String? userAppLanguageCode;

  void changeSelectedCountry(Country country) {
    final _CountrySelectorLoadedState state =
        value as _CountrySelectorLoadedState;

    value = _CountrySelectorEditingState.fromLoadedState(
      loadedState: state,
      selectedCountry: country,
    );

    if (autoValidate) {
      saveSelectedCountry();
    }
  }

  Future<void> saveSelectedCountry() async {
    if (value is! _CountrySelectorEditingState) {
      return;
    }

    /// No need to refresh the state here, the [UserPreferences] will notify
    return preferences.setUserCountryCode(
      (value as _CountrySelectorEditingState).selectedCountry!.countryCode,
    );
  }

  void dismissSelectedCountry() {
    if (value is _CountrySelectorEditingState) {
      value = (value as _CountrySelectorEditingState).toLoadedState();
    }
  }

  Future<void> _onPreferencesChanged() async {
    final String? newCountryCode = preferences.userCountryCode;
    final String? newAppLanguageCode = preferences.appLanguageCode;

    if (newAppLanguageCode != userAppLanguageCode) {
      userAppLanguageCode = newAppLanguageCode;
      userCountryCode = newCountryCode;

      return _loadCountries();
    } else if (newCountryCode != userCountryCode) {
      userAppLanguageCode = newAppLanguageCode;
      userCountryCode = newCountryCode;

      if (value is _CountrySelectorInitialState) {
        return _loadCountries();
      } else {
        final _CountrySelectorLoadedState state =
            value as _CountrySelectorLoadedState;

        value = state.copyWith(
          country: _getSelectedCountry(state.countries),
        );
      }
    }
  }

  Future<void> _loadCountries() async {
    if (userAppLanguageCode == null) {
      return;
    }

    value = const _CountrySelectorLoadingState();

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

    value = _CountrySelectorLoadedState(
      country: _getSelectedCountry(countries),
      countries: countries,
    );
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
      List<Country> localizedCountries) {
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
      List<Country> countries, String? userCountryCode) {
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

  Country _getSelectedCountry(List<Country> countries) {
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
  void dispose() {
    preferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }
}

@immutable
sealed class _CountrySelectorState {
  const _CountrySelectorState();
}

class _CountrySelectorInitialState extends _CountrySelectorLoadingState {
  const _CountrySelectorInitialState();
}

class _CountrySelectorLoadingState extends _CountrySelectorState {
  const _CountrySelectorLoadingState();
}

class _CountrySelectorLoadedState extends _CountrySelectorState {
  const _CountrySelectorLoadedState({
    required this.country,
    required this.countries,
    this.estimatedCountry,
  });

  final Country? country;
  final List<Country> countries;

  /// We be used later to provide an estimation based on the IP address.
  final Country? estimatedCountry;

  _CountrySelectorLoadedState copyWith({
    Country? country,
    Country? estimatedCountry,
    List<Country>? countries,
  }) =>
      _CountrySelectorLoadedState(
        country: country ?? this.country,
        estimatedCountry: estimatedCountry ?? this.estimatedCountry,
        countries: countries ?? this.countries,
      );

  @override
  String toString() {
    return '_CountrySelectorLoadedState{country: $country, estimatedCountry: $estimatedCountry, countries: $countries}';
  }
}

class _CountrySelectorEditingState extends _CountrySelectorLoadedState {
  _CountrySelectorEditingState.fromLoadedState({
    required this.selectedCountry,
    required _CountrySelectorLoadedState loadedState,
  }) : super(
          country: loadedState.country,
          estimatedCountry: loadedState.estimatedCountry,
          countries: loadedState.countries,
        );

  final Country? selectedCountry;

  /// Remove the selected country
  _CountrySelectorLoadedState toLoadedState() => _CountrySelectorLoadedState(
        country: country,
        estimatedCountry: estimatedCountry,
        countries: countries,
      );

  @override
  String toString() {
    return '_CountrySelectorEditingState{selectedCountry: $selectedCountry}';
  }
}
