import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/query/product_query.dart';

/// A selector for selecting user's country.
class CountrySelector extends StatefulWidget {
  const CountrySelector({
    this.textStyle,
  });

  final TextStyle? textStyle;

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  late List<Country> _countryList;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    final UserPreferences userPreferences = context.read<UserPreferences>();
    _initFuture = _init(userPreferences.appLanguageCode!);
  }

  Future<void> _init(final String languageCode) async {
    List<Country> localizedCountries;

    try {
      localizedCountries =
          await IsoCountries.iso_countries_for_locale(languageCode);
    } on MissingPluginException catch (_) {
      // Locales are not implemented on desktop and web
      // TODO(g123k): Add a complete list
      localizedCountries = <Country>[
        const Country(name: 'United States', countryCode: 'US'),
        const Country(name: 'France', countryCode: 'FR'),
        const Country(name: 'Germany', countryCode: 'DE'),
        const Country(name: 'India', countryCode: 'IN'),
      ];
    }
    _countryList = _sanitizeCountriesList(localizedCountries);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextEditingController countryController = TextEditingController();
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          return Text('Fatal Error: ${snapshot.error}');
        } else if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator.adaptive();
        }
        final UserPreferences userPreferences =
            context.watch<UserPreferences>();
        final Country selectedCountry = _getSelectedCountry(
          userPreferences.userCountryCode,
        );
        return InkWell(
          borderRadius: ANGULAR_BORDER_RADIUS,
          onTap: () async {
            _reorderCountries(selectedCountry);
            List<Country> filteredList = List<Country>.from(_countryList);
            final Country? country = await showDialog<Country>(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(VoidCallback fn) setState) {
                    return SmoothAlertDialog(
                      body: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            SmoothTextFormField(
                              type: TextFieldTypes.PLAIN_TEXT,
                              prefixIcon: const Icon(Icons.search),
                              controller: countryController,
                              onChanged: (String? query) {
                                setState(
                                  () {
                                    filteredList = _countryList
                                        .where(
                                          (Country item) =>
                                              item.name.toLowerCase().contains(
                                                    query!.toLowerCase(),
                                                  ) ||
                                              item.countryCode
                                                  .toLowerCase()
                                                  .contains(
                                                    query.toLowerCase(),
                                                  ),
                                        )
                                        .toList(growable: false);
                                  },
                                );
                              },
                              hintText: appLocalizations.search,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  final Country country = filteredList[index];
                                  final bool selected =
                                      country == selectedCountry;
                                  return ListTile(
                                    dense: true,
                                    trailing: selected
                                        ? const Icon(Icons.check)
                                        : null,
                                    title: Text(
                                      country.name,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: selected
                                          ? const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )
                                          : null,
                                    ),
                                    onTap: () =>
                                        Navigator.of(context).pop(country),
                                  );
                                },
                                itemCount: filteredList.length,
                                shrinkWrap: true,
                              ),
                            )
                          ],
                        ),
                      ),
                      positiveAction: SmoothActionButton(
                        onPressed: () => Navigator.pop(context),
                        text: appLocalizations.cancel,
                      ),
                    );
                  },
                );
              },
            );
            if (country != null) {
              await ProductQuery.setCountry(
                userPreferences,
                isoCode: country.countryCode,
              );
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.public),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                    child: Text(
                      selectedCountry.name,
                      style: widget.textStyle ??
                          Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Sanitizes the country list, but without reordering it.
  ///
  /// * by removing countries that are not in [OpenFoodFactsCountry]
  /// * and providing a fallback English name for countries that are in
  /// [OpenFoodFactsCountry] but not in [localizedCountries].
  List<Country> _sanitizeCountriesList(List<Country> localizedCountries) {
    final List<Country> finalCountriesList = <Country>[];
    final Map<String, OpenFoodFactsCountry> oFFIsoCodeToCountry =
        <String, OpenFoodFactsCountry>{};
    final Map<String, Country> localizedIsoCodeToCountry = <String, Country>{};
    for (final OpenFoodFactsCountry c in OpenFoodFactsCountry.values) {
      oFFIsoCodeToCountry[c.offTag.toLowerCase()] = c;
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
        finalCountriesList.add(
          Country(
              name: _fixCountryName(countryName),
              countryCode: _fixCountryCode(countryCode)),
        );
        continue;
      }
      final String fixedCountryCode = _fixCountryCode(countryCode);
      final Country country = fixedCountryCode == countryCode
          ? localizedCountry
          : Country(name: localizedCountry.name, countryCode: countryCode);
      finalCountriesList.add(country);
    }
    return finalCountriesList;
  }

  /// Fix the countryCode if needed so Backend can process it.
  String _fixCountryCode(String countryCode) {
    // 'gb' is handled as 'uk' in the backend.
    if (countryCode == 'gb') {
      countryCode = 'uk';
    }
    return countryCode;
  }

  Country _getSelectedCountry(final String? cc) {
    if (cc != null) {
      for (final Country country in _countryList) {
        if (country.countryCode.toLowerCase() == cc.toLowerCase()) {
          return country;
        }
      }
    }
    return _countryList[0];
  }

  /// Fix the issues where United Kingdom appears with lowercase 'k'.
  String _fixCountryName(String countryName) {
    if (countryName == 'United kingdom') {
      countryName = 'United Kingdom';
    }
    return countryName;
  }

  /// Reorder countries alphabetically, bring user's locale country to top.
  void _reorderCountries(final Country selectedCountry) {
    _countryList.sort(
      (final Country a, final Country b) {
        if (a == selectedCountry) {
          return -1;
        }
        if (b == selectedCountry) {
          return 1;
        }
        return a.name.compareTo(b.name);
      },
    );
  }
}
