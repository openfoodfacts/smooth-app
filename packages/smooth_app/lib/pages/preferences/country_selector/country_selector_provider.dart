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
    final String? newCountryCode =
        preferences.userCountryCode; // Stored as offTag
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
    final List<OpenFoodFactsCountry> countries =
        LocalizedCountry.getLocalizedCountries().map((e) => e.country).toList();
    return countries;
  }

  static void _reorderCountries(
    List<OpenFoodFactsCountry> countries,
    String? userCountryCode,
  ) {
    final Map<OpenFoodFactsCountry, LocalizedCountry> localizedMap = {
      for (final c in LocalizedCountry.getLocalizedCountries()) c.country: c
    };

    countries.sort(
      (a, b) {
        if (a.offTag == userCountryCode) {
          return -1;
        }
        if (b.offTag == userCountryCode) {
          return 1;
        }
        final String nameA = localizedMap[a]?.localizedName ?? '';
        final String nameB = localizedMap[b]?.localizedName ?? '';
        return nameA.compareTo(nameB);
      },
    );
  }

  @override
  OpenFoodFactsCountry getSelectedValue(List<OpenFoodFactsCountry> countries) {
    if (userCountryCode != null) {
      return countries.firstWhere(
        (OpenFoodFactsCountry country) =>
            country.offTag.toLowerCase() == userCountryCode?.toLowerCase(),
        orElse: () => countries.first,
      );
    }
    return countries.first;
  }

  @override
  Future<void> onSaveItem(OpenFoodFactsCountry country) =>
      preferences.setUserCountryCode(
          country.offTag); // Save offTag (not iso2code) in preferences

  OpenFoodFactsLanguage? _getLanguageFromCode(String? code) {
    if (code == null) {
      return null;
    }
    return OpenFoodFactsLanguage.fromOffTag(code);
  }
}
