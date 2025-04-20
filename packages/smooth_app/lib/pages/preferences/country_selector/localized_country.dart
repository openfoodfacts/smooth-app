import 'package:l10n_countries/l10n_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
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

  static List<LocalizedCountry> getLocalizedCountries() {
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    final CountriesLocaleMapper mapper = CountriesLocaleMapper();

    final Set<String> iso3Codes = tmpCountryIso3.values.toSet();
    final LocaleMap localizedMap = mapper.localize(
      iso3Codes,
      mainLocale: language,
      fallbackLocale: OpenFoodFactsLanguage.ENGLISH,
    );

    final List<LocalizedCountry> result = <LocalizedCountry>[];
    for (final OpenFoodFactsCountry country in OpenFoodFactsCountry.values) {
      final String? iso3 = tmpCountryIso3[country];
      if (iso3 == null) {
        continue;
      }

      final String? localized = localizedMap[iso3];

      String fallbackEnglish =
          country.toString().split('.').last.replaceAll('_', ' ');
      fallbackEnglish = fallbackEnglish[0].toUpperCase() +
          fallbackEnglish.substring(1).toLowerCase();

      result.add(
        LocalizedCountry(
          country: country,
          localizedName: localized ?? fallbackEnglish,
          englishName: fallbackEnglish,
        ),
      );
    }

    result.sort((a, b) => a.localizedName.compareTo(b.localizedName));
    return result;
  }

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

    final String? localized = map.values.firstOrNull;

    if (language != OpenFoodFactsLanguage.ENGLISH || localized != null) {
      return localized;
    }

    final String fallbackEnglish =
        country.toString().split('.').last.replaceAll('_', ' ');
    return fallbackEnglish[0].toUpperCase() +
        fallbackEnglish.substring(1).toLowerCase();
  }
}
