import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// A selector for selecting user's country.
class CountrySelector extends StatefulWidget {
  const CountrySelector({
    required this.initialCountryCode,
  });
  final String? initialCountryCode;

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
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          return Text('Fatal Error: ${snapshot.error}');
        } else if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        return GestureDetector(
          onTap: () async {
            List<Country> filteredList = List<Country>.from(_countryList);
            await showDialog<Country>(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(VoidCallback fn) setState) {
                    return AlertDialog(
                      title: const Text('Choose your country'),
                      // TODO(aman): translations
                      content: SizedBox(
                        width: 300,
                        child: Column(
                          children: <Widget>[
                            TextField(
                              decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: ROUNDED_BORDER_RADIUS,
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(),
                                  borderRadius: ROUNDED_BORDER_RADIUS,
                                ),
                                filled:
                                    Theme.of(context).colorScheme.brightness ==
                                        Brightness.light,
                                fillColor:
                                    const Color.fromARGB(255, 235, 235, 235),
                              ),
                              autofocus: true,
                              onChanged: (String query) {
                                setState(
                                  () {
                                    filteredList = _countryList
                                        .where(
                                          (Country item) =>
                                              item.name.toLowerCase().contains(
                                                    query.toLowerCase(),
                                                  ) |
                                              item.countryCode
                                                  .toLowerCase()
                                                  .contains(
                                                    query.toLowerCase(),
                                                  ),
                                        )
                                        .toList();
                                  },
                                );
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Country country = filteredList[index];
                                    return ListTile(
                                      title: Text(country.name),
                                      onTap: () async {
                                        _chosenValue = country;
                                        await _setUserCountry(
                                            _chosenValue.countryCode);
                                        setState(() {});
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appLocalizations.cancel),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.public),
              title: Text(
                _chosenValue.name,
                style: Theme.of(context).textTheme.headline3,
              ),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
          ),
        );
      },
    );
  }

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
