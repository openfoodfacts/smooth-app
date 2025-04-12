import 'package:l10n_countries/l10n_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/preferences/country_selector/tmp_country_iso3.dart';

extension OpenFoodFactsCountryNameExtension on OpenFoodFactsCountry {
  String getLocalizedName(String locale) {
    final CountriesLocaleMapper mapper = CountriesLocaleMapper();
    final LocaleMap result = mapper.localize({tmpCountryIso3[this] ?? 'UN'},
        mainLocale: locale, fallbackLocale: 'en');
    return result.values.first;
  }

  String getEnglishName() => getLocalizedName('en');
}
