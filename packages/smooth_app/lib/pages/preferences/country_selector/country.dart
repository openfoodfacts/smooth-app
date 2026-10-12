import 'package:l10n_countries/l10n_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Extension on countries and their localizations.
extension OpenFoodFactsCountryLocalization on OpenFoodFactsCountry {
  /// Fallback language is English.
  static const String _englishLanguageCode = 'en';

  static String _latestLanguageCode = _englishLanguageCode;

  /// Translations, computed only if needed, and cached.
  static final Map<String, Map<OpenFoodFactsCountry, String>> _translations =
      <String, Map<OpenFoodFactsCountry, String>>{};

  static void setLocale(final String? languageCode) {
    if (languageCode != null) {
      _latestLanguageCode = languageCode;
    }
  }

  String get localizedName {
    _translations[_latestLanguageCode] ??= _translate(_latestLanguageCode);
    String? result = _translations[_latestLanguageCode]![this];
    if (result != null) {
      return result;
    }
    _translations[_englishLanguageCode] ??= _translate(_englishLanguageCode);
    result = _translations[_englishLanguageCode]![this];
    if (result != null) {
      return result;
    }
    // lousy fallback version in English
    final String countryName = toString()
        .replaceAll('OpenFoodFactsCountry.', '')
        .replaceAll('_', ' ');
    return '${countryName[0].toUpperCase()}'
        '${countryName.substring(1).toLowerCase()}';
  }

  /// Map of all countries' ISO3 codes.
  static Map<String, Country>? _iso3s;

  /// Return the map of all countries' ISO3 codes.
  static Map<String, Country> _getIso3s() {
    final Map<String, Country> result = <String, Country>{};
    for (final Country country in OpenFoodFactsCountry.values) {
      result[country.iso3Code] = country;
    }
    return result;
  }

  static Map<OpenFoodFactsCountry, String> _translate(
    final String languageCode,
  ) {
    final Map<Country, String> result = <Country, String>{};
    _iso3s ??= _getIso3s();
    CountriesLocaleMapper().localize(
      _iso3s!.keys.toSet(),
      mainLocale: languageCode,
      useLanguageFallback: true,
      formatter: (LocaleKey localeKey, String translation) {
        final Country? country = _iso3s![localeKey.isoCode];
        // null would happen for 'USA+' for instance
        if (country != null) {
          result[country] = translation;
        }
        return translation;
      },
    );
    return result;
  }

  static Iterable<Country> filterCountries(
    List<Country> countries,
    Country? userCountry,
    Country? selectedCountry,
    String? filter,
  ) {
    if (filter == null || filter.isEmpty) {
      return countries;
    }

    return countries.where(
      (Country country) =>
          country == userCountry ||
          country == selectedCountry ||
          country.localizedName.toLowerCase().contains(filter.toLowerCase()) ||
          country.offTag.toLowerCase().contains(filter.toLowerCase()),
    );
  }

  /// Reorder countries alphabetically, bring user's locale country to top.
  static void reorderCountries(
    List<Country> countries,
    final String? userCountryCode,
  ) {
    countries.sort((final Country a, final Country b) {
      if (a.offTag == userCountryCode) {
        return -1;
      }
      if (b.offTag == userCountryCode) {
        return 1;
      }
      return a.localizedName.compareTo(b.localizedName);
    });
  }
}

typedef Country = OpenFoodFactsCountry;
