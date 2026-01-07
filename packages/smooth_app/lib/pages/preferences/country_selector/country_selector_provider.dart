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
        _reorderCountries(countries);

        value = state.copyWith(
          selectedItem: getSelectedValue(state.items),
          items: countries,
        );
      }
    }
  }

  @override
  Future<List<Country>> onLoadValues() async {
    final List<Country> countries = OpenFoodFactsCountry.values.toList(
      growable: false,
    );
    _reorderCountries(countries);
    return countries;
  }

  /// Reorder countries alphabetically, bring user's locale country to top.
  void _reorderCountries(List<Country> countries) {
    countries.sort((final Country a, final Country b) {
      if (a.offTag == userCountryCode) {
        return -1;
      }
      if (b.offTag == userCountryCode) {
        return 1;
      }
      return a.name.compareTo(b.name);
    });
  }

  @override
  Country getSelectedValue(List<Country> countries) {
    if (userCountryCode != null) {
      for (final Country country in countries) {
        if (country.offTag.toLowerCase() == userCountryCode?.toLowerCase()) {
          return country;
        }
      }
    }
    return countries[0];
  }

  @override
  Future<void> onSaveItem(Country country) =>
      ProductQuery.setCountry(preferences, country.offTag);
}
