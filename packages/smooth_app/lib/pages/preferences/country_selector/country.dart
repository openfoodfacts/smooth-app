import 'package:l10n_countries/l10n_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Extension on countries and their localizations.
extension OpenFoodFactsCountryLocalization on OpenFoodFactsCountry {
  /// Fallback language is English.
  static const String _englishLanguageCode = 'en';

  static String _latestLanguageCode = _englishLanguageCode;

  static void setLocale(final String? languageCode) {
    if (languageCode != null) {
      _latestLanguageCode = languageCode;
    }
  }

  String get name {
    final String? result =
        _getMapper().map[_latestLanguageCode]?.map[iso3Code] ??
        _getMapper().map[_englishLanguageCode]?.map[iso3Code];
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

  static CountriesLocaleMapper? _mapper;

  static CountriesLocaleMapper _getMapper() =>
      _mapper ??= CountriesLocaleMapper();
}

typedef Country = OpenFoodFactsCountry;
