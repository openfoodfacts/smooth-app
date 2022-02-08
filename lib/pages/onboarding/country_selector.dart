import 'package:flutter/material.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/product_query.dart';

/// A selector for selecting user's country.
class CountrySelector extends StatefulWidget {
  const CountrySelector({
    required this.initialCountryCode,
    this.inputDecoration,
    this.padding,
  });

  final String? initialCountryCode;
  final InputDecoration? inputDecoration;
  final EdgeInsetsGeometry? padding;

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  late UserPreferences _userPreferences;
  late List<Country> _countryList = <Country>[];
  late Country _chosenValue;
  late Future<void> _initFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFuture = _init();
  }

  Future<void> _init() async {
    final String locale = Localizations.localeOf(context).languageCode;
    final List<Country> localizedCountries =
        await IsoCountries.iso_countries_for_locale(locale);
    _userPreferences = await UserPreferences.getUserPreferences();
    _countryList = _sanitizeCountriesList(localizedCountries);
    _chosenValue = _countryList[0];
    _setUserCountry(_chosenValue.countryCode);
  }

  Future<void> _setUserCountry(final String countryCode) async {
    await _userPreferences.setUserCountry(_chosenValue.countryCode);
    ProductQuery.setCountry(_userPreferences.userCountryCode);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            return Text('Fatal Error: ${snapshot.error}');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            final double parentWidth = constraints.maxWidth;
            return Container(
              padding: widget.padding,
              child: DropdownButtonFormField<Country>(
                value: _chosenValue,
                decoration: widget.inputDecoration,
                items: _countryList
                    .map<DropdownMenuItem<Country>>((Country country) {
                  return DropdownMenuItem<Country>(
                    value: country,
                    child: Container(
                      // Set the maxWidth so the dropdown arrow icon doesn't overflow.
                      // 48 dp is needed to account for dropdown arrow icon and padding.
                      constraints: BoxConstraints(maxWidth: parentWidth - 48)
                          .normalize(),
                      child: Text(country.name),
                    ),
                  );
                }).toList(),
                onChanged: (Country? value) async {
                  if (value != null) {
                    _chosenValue = value;
                    await _setUserCountry(_chosenValue.countryCode);
                    setState(() {});
                  }
                },
              ),
            );
          });
        },
      );

  /// Sanitize the country list by removing countries that are not in [OpenFoodFactsCountry]
  /// and providing a fallback English name for countries that are in [OpenFoodFactsCountry]
  /// but not in [localizedCountries].
  List<Country> _sanitizeCountriesList(List<Country> localizedCountries) {
    final List<Country> finalCountriesList = <Country>[];
    final Map<String, OpenFoodFactsCountry> oFFIsoCodeToCountry =
        <String, OpenFoodFactsCountry>{};
    final Map<String, Country> localizedIsoCodeToCountry = <String, Country>{};
    for (final OpenFoodFactsCountry c in OpenFoodFactsCountry.values) {
      oFFIsoCodeToCountry[c.iso2Code.toLowerCase()] = c;
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
        finalCountriesList.add(Country(
            name: countryName, countryCode: _fixCountryCode(countryCode)));
        continue;
      }
      final String fixedCountryCode = _fixCountryCode(countryCode);
      final Country country = fixedCountryCode == countryCode
          ? localizedCountry
          : Country(name: localizedCountry.name, countryCode: countryCode);
      finalCountriesList.add(country);
    }
    return _reorderCountries(finalCountriesList);
  }

  /// Fix the countryCode if needed so Backend can process it.
  String _fixCountryCode(String countryCode) {
    // 'gb' is handled as 'uk' in the backend.
    if (countryCode == 'gb') {
      countryCode = 'uk';
    }
    return countryCode;
  }

  /// Reorder countries alphabetically, bring user's locale country to top.
  List<Country> _reorderCountries(List<Country> countries) {
    countries
        .sort((final Country a, final Country b) => a.name.compareTo(b.name));
    final String? mostLikelyUserCountryCode = widget.initialCountryCode;
    if (mostLikelyUserCountryCode == null) {
      return countries;
    }
    // Bring the most likely user country to top.
    for (final Country country in countries) {
      if (country.countryCode.toLowerCase() ==
          mostLikelyUserCountryCode.toLowerCase()) {
        countries.remove(country);
        countries.insert(0, country);
        return countries;
      }
    }
    return countries;
  }
}
