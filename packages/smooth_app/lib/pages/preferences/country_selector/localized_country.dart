import 'package:l10n_countries/l10n_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/preferences/country_selector/openfoodfacts_country_iso2code_extension.dart';
import 'package:smooth_app/pages/preferences/country_selector/tmp_country_iso3.dart';
import 'package:smooth_app/query/product_query.dart';

class LocalizedCountry {
  const LocalizedCountry({
    required this.country,
    required this.localizedName,
    required this.englishName,
  });

  final OpenFoodFactsCountry country;
  final String localizedName;
  final String englishName;

  String get preferenceCode => country.offTag;
  String get iso2Code => country.iso2Code;

  static Map<OpenFoodFactsCountry, LocalizedCountry>
      getLocalizedCountriesMap() {
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    final CountriesLocaleMapper mapper = CountriesLocaleMapper();

    final Set<String> iso3Codes = tmpCountryIso3.values.toSet();
    final LocaleMap localizedMap = mapper.localize(
      iso3Codes,
      mainLocale: language,
      fallbackLocale: OpenFoodFactsLanguage.ENGLISH,
    );

    final LocaleMap englishMap = mapper.localize(
      iso3Codes,
      mainLocale: OpenFoodFactsLanguage.ENGLISH,
    );

    final Map<OpenFoodFactsCountry, LocalizedCountry> result = {};
    for (final OpenFoodFactsCountry country in OpenFoodFactsCountry.values) {
      final String? iso3 = tmpCountryIso3[country];
      if (iso3 == null) {
        continue;
      }

      final String? localized = localizedMap[iso3];
      final String fallbackEnglish =
          englishMap[iso3] ?? _getFallbackEnglishName(country);

      result[country] = LocalizedCountry(
        country: country,
        localizedName: localized ?? fallbackEnglish,
        englishName: fallbackEnglish,
      );
    }

    return result;
  }

  static List<LocalizedCountry> getLocalizedCountries() =>
      getLocalizedCountriesMap().values.toList()
        ..sort((a, b) => a.localizedName.compareTo(b.localizedName));

  static String? getSingleLocalizedName(OpenFoodFactsCountry country) {
    final String? iso3 = tmpCountryIso3[country];
    if (iso3 == null) {
      return null;
    }

    final CountriesLocaleMapper mapper = CountriesLocaleMapper();
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();

    final LocaleMap map = mapper.localize(
      {iso3},
      mainLocale: language,
      fallbackLocale: OpenFoodFactsLanguage.ENGLISH,
    );

    final String? localized = map[iso3];

    if (language != OpenFoodFactsLanguage.ENGLISH || localized != null) {
      return localized;
    }

    final LocaleMap englishMap = mapper.localize(
      {iso3},
      mainLocale: OpenFoodFactsLanguage.ENGLISH,
    );

    return englishMap[iso3] ?? _getFallbackEnglishName(country);
  }

  static String _getFallbackEnglishName(OpenFoodFactsCountry country) {
    final String raw = country.toString().split('.').last.replaceAll('_', ' ');
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }
}
