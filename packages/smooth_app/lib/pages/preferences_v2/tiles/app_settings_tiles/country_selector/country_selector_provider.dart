part of 'country_selector_tile.dart';

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

  void _reorderCountries(List<Country> countries) =>
      OpenFoodFactsCountryLocalization.reorderCountries(
        countries,
        userCountryCode,
      );

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
