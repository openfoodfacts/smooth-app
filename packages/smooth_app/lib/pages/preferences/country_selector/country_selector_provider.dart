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

      if (value is PreferencesSelectorInitialState<OpenFoodFactsCountry>) {
        return loadValues();
      } else {
        final state =
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
        _sanitizeAndSortCountries(userAppLanguageCode);
    return countries;
  }

  static List<OpenFoodFactsCountry> _sanitizeAndSortCountries(String? locale) {
    final List<OpenFoodFactsCountry> countries =
        List.from(OpenFoodFactsCountry.values);

    countries.sort(
      (a, b) => a
          .getLocalizedName(locale ?? 'en')
          .compareTo(b.getLocalizedName(locale ?? 'en')),
    );

    return countries;
  }

  static void _reorderCountries(
    List<OpenFoodFactsCountry> countries,
    String? userCountryCode,
  ) {
    countries.sort(
      (a, b) {
        if (a.offTag == userCountryCode) return -1;
        if (b.offTag == userCountryCode) return 1;
        return a.getLocalizedName('en').compareTo(b.getLocalizedName('en'));
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
}

// class CountriesHelper {
//   const CountriesHelper._();
//
//   static Future<List<Country>?> getCountries(String? userLanguageCode) async {
//     try {
//       final CountriesLocaleMapper mapper = CountriesLocaleMapper();
//
//       // Use the ISO3 codes from your custom map
//       final Set<String> iso3Codes = iso3ToCountry.keys.toSet();
//
//       final LocaleMap localized = mapper.localize(
//         iso3Codes,
//         mainLocale: userLanguageCode ?? 'en',
//         fallbackLocale: 'en',
//       );
//
//       // Build the list using your existing OpenFoodFactsCountry mapping
//       final List<Country> countriesList = localized.entries.map((entry) {
//         final String iso3 = entry.key.isoCode; // like 'IND'
//         final String localizedName = entry.value;
//
//         final OpenFoodFactsCountry? offCountry = iso3ToCountry[iso3];
//         final String alpha2 = offCountry?.offTag.toUpperCase() ?? 'UN';
//
//         return Country(name: localizedName, countryCode: alpha2);
//       }).toList();
//
//       return countriesList;
//     } on MissingPluginException catch (_) {
//       // Locales are not implemented on desktop and web
//       return <Country>[
//         const Country(name: 'United States', countryCode: 'US'),
//         const Country(name: 'France', countryCode: 'FR'),
//         const Country(name: 'Germany', countryCode: 'DE'),
//         const Country(name: 'India', countryCode: 'IN'),
//       ];
//     } catch (e) {
//       Logs.e('Failed to load countries', ex: e);
//       return null;
//     }
//   }
// }
