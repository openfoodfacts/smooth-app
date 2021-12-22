import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// A selector for selecting user's country.
class CountrySelector extends StatefulWidget {
  const CountrySelector();

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  late List<Country> _countryList = <Country>[];
  String? _chosenValue;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFuture = _init();
  }

  Future<void> _init() async {
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Country> localizedCountries =
        await IsoCountries.iso_countries_for_locale(locale);
    _countryList = sanitizeCountriesList(localizedCountries);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            return Text('Fatal Error: ${snapshot.error}');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return Padding(
            padding:
                const EdgeInsets.only(top: MEDIUM_SPACE, bottom: LARGE_SPACE),
            child: DropdownButtonFormField<String>(
              value: _chosenValue,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 235, 235, 235)),
                  borderRadius: BorderRadius.circular(VERY_LARGE_SPACE),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 235, 235, 235),
              ),
              items:
                  _countryList.map<DropdownMenuItem<String>>((Country country) {
                return DropdownMenuItem<String>(
                  value: country.name,
                  child: Text(country.name),
                );
              }).toList(),
              hint: Text(
                appLocalizations.country_chooser_label,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onChanged: (String? value) {
                setState(() {
                  if (value != null) {
                    // TODO(jasmeet): Store pref in _userPreferences
                    _chosenValue = value;
                  }
                });
              },
            ),
          );
        });
  }

  List<Country> sanitizeCountriesList(List<Country> localizedCountries) {
    final List<Country> finalCountriesList = <Country>[];
    final Map<String, OpenFoodFactsCountry> oFFIsoCodeToCountry =
        <String, OpenFoodFactsCountry>{};
    final Map<String, Country> localizedIsoCodeToCountry = <String, Country>{};
    for (final OpenFoodFactsCountry c in OpenFoodFactsCountry.values) {
      oFFIsoCodeToCountry.putIfAbsent(c.iso2Code.toLowerCase(), () => c);
    }
    for (final Country c in localizedCountries) {
      localizedIsoCodeToCountry.putIfAbsent(
          c.countryCode.toLowerCase(), () => c);
    }
    for (final String countryCode in oFFIsoCodeToCountry.keys) {
      final Country? localizedCountry = localizedIsoCodeToCountry[countryCode];
      if (localizedCountry == null) {
        // No localization for the country name was found, use English name as
        // default.
        String countryName = oFFIsoCodeToCountry[countryCode]
            .toString()
            .replaceAll('OpenFoodFactsCountry.', '')
            .replaceAll('_', ' ');
        countryName =
            '${countryName[0].toUpperCase()}${countryName.substring(1).toLowerCase()}';
        final Country country =
            Country(name: countryName, countryCode: countryName);
        finalCountriesList.add(country);
        continue;
      }
      // 'gb' is handled as 'uk' in the backend.
      if (countryCode == 'gb') {
        final Country modifiedCountry =
            Country(name: localizedCountry.name, countryCode: 'uk');
        finalCountriesList.add(modifiedCountry);
        continue;
      }
      finalCountriesList.add(localizedCountry);
    }
    return reorderCountries(finalCountriesList);
  }

  List<Country> reorderCountries(List<Country> countries) {
    countries
        .sort((final Country a, final Country b) => a.name.compareTo(b.name));
    final String? mostLikelyUserCountryCode =
        WidgetsBinding.instance?.window.locale.countryCode;
    if (mostLikelyUserCountryCode == null) {
      return countries;
    }
    Country? mostLikelyUserCountry;
    // Bring the most likely user country to top.
    for (final Country country in countries) {
      if (country.countryCode == mostLikelyUserCountryCode) {
        mostLikelyUserCountry = country;
        break;
      }
    }
    if (mostLikelyUserCountry == null) {
      return countries;
    }
    countries.remove(mostLikelyUserCountry);
    countries.insert(0, mostLikelyUserCountry);
    return countries;
  }
}
