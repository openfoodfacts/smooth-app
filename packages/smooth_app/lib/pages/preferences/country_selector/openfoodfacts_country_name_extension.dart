import 'package:l10n_countries/l10n_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/preferences/country_selector/tmp_country_iso3.dart';

extension OpenFoodFactsCountryNameExtension on OpenFoodFactsCountry {
  String? getLocalizedName(OpenFoodFactsLanguage locale) {
    final String? iso3 = tmpCountryIso3[this];
    if (iso3 == null) {
      return null;
    }

    final CountriesLocaleMapper mapper = CountriesLocaleMapper();
    final LocaleMap result = mapper.localize(
      {iso3},
      mainLocale: locale,
    );

    return result.values.firstOrNull;
  }

  String getEnglishName() =>
      getLocalizedName(OpenFoodFactsLanguage.ENGLISH) ??
      toString().split('.').last;
}
