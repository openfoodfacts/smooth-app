import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/strings_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// A selector for selecting user's country.
class CountrySelector extends StatefulWidget {
  const CountrySelector({
    this.textStyle,
    this.padding,
    this.icon,
    this.inkWellBorderRadius,
    required this.forceCurrencyChange,
  });

  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? inkWellBorderRadius;
  final Widget? icon;
  final bool forceCurrencyChange;

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _countryController = TextEditingController();
  late List<Country> _countryList;

  Future<void> _loadLocalizedCountryNames(final String languageCode) async {
    List<Country> localizedCountries;

    try {
      localizedCountries =
          await IsoCountries.isoCountriesForLocale(languageCode);
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
    return Selector<UserPreferences, String?>(
      selector: (BuildContext buildContext, UserPreferences userPreferences) =>
          userPreferences.appLanguageCode,
      builder: (BuildContext context, String? appLanguageCode, _) {
        return FutureBuilder<void>(
          future: _loadLocalizedCountryNames(appLanguageCode!),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.hasError) {
              return Text('Fatal Error: ${snapshot.error}');
            } else if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final UserPreferences userPreferences =
                context.watch<UserPreferences>();
            final Country selectedCountry = _getSelectedCountry(
              userPreferences.userCountryCode,
            );
            final EdgeInsetsGeometry innerPadding = const EdgeInsets.symmetric(
              vertical: SMALL_SPACE,
            ).add(widget.padding ?? EdgeInsets.zero);

            return InkWell(
              borderRadius: widget.inkWellBorderRadius ?? ANGULAR_BORDER_RADIUS,
              onTap: () async {
                _reorderCountries(selectedCountry);
                List<Country> filteredList = List<Country>.from(_countryList);
                final Country? country = await showDialog<Country>(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context,
                          void Function(VoidCallback fn) setState) {
                        const double horizontalPadding = 16.0 + SMALL_SPACE;

                        return SmoothListAlertDialog(
                          title: appLocalizations.country_selector_title,
                          header: SmoothTextFormField(
                            type: TextFieldTypes.PLAIN_TEXT,
                            prefixIcon: const Icon(Icons.search),
                            borderRadius: BorderRadius.zero,
                            controller: _countryController,
                            onChanged: (String? query) {
                              query = query!.trim().getComparisonSafeString();

                              setState(
                                () {
                                  filteredList = _countryList
                                      .where(
                                        (Country item) =>
                                            item.name
                                                .getComparisonSafeString()
                                                .contains(
                                                  query!,
                                                ) ||
                                            item.countryCode
                                                .getComparisonSafeString()
                                                .contains(
                                                  query,
                                                ),
                                      )
                                      .toList(growable: false);
                                },
                              );
                            },
                            hintText: appLocalizations.search,
                          ),
                          scrollController: _scrollController,
                          list: ListView.separated(
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              final Country country = filteredList[index];
                              final bool selected = country == selectedCountry;
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                horizontalTitleGap: 0,
                                leading: Text(country.emoji),
                                minLeadingWidth: 30.0,
                                trailing:
                                    selected ? const Icon(Icons.check) : null,
                                title: TextHighlighter(
                                  text: country.name,
                                  filter: _countryController.text,
                                  selected: selected,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(country);
                                  _countryController.clear();
                                },
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(
                              height: 1.0,
                            ),
                            itemCount: filteredList.length,
                            shrinkWrap: true,
                          ),
                          positiveAction: SmoothActionButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _countryController.clear();
                            },
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
                    country.countryCode,
                  );
                  if (context.mounted) {
                    await _changeCurrencyIfRelevant(
                      country,
                      userPreferences,
                      context,
                    );
                  }
                }
              },
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: innerPadding,
                        child: const Icon(Icons.public),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: LARGE_SPACE),
                          child: Text(
                            selectedCountry.name,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.merge(widget.textStyle),
                          ),
                        ),
                      ),
                      widget.icon ?? const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            );
          },
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

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _changeCurrencyIfRelevant(
    final Country country,
    final UserPreferences userPreferences,
    final BuildContext context,
  ) async {
    final OpenFoodFactsCountry? offCountry =
        OpenFoodFactsCountry.fromOffTag(country.countryCode);
    final String? possibleCurrencyCode = offCountry?.currency?.name;
    if (possibleCurrencyCode == null) {
      return;
    }
    bool? changeCurrency;
    final String? currentCurrencyCode = userPreferences.userCurrencyCode;
    if (currentCurrencyCode == null) {
      changeCurrency = true;
    } else if (widget.forceCurrencyChange) {
      changeCurrency = true;
    } else if (currentCurrencyCode != possibleCurrencyCode) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      changeCurrency = await showDialog<bool>(
        context: context,
        builder: (final BuildContext context) => SmoothAlertDialog(
          body: Text(
            '${appLocalizations.country_change_message}'
            '\n'
            '${appLocalizations.currency_auto_change_message(
              currentCurrencyCode,
              possibleCurrencyCode,
            )}',
          ),
          negativeAction: SmoothActionButton(
            onPressed: () => Navigator.of(context).pop(),
            text: appLocalizations.no,
          ),
          positiveAction: SmoothActionButton(
            onPressed: () => Navigator.of(context).pop(true),
            text: appLocalizations.yes,
          ),
        ),
      );
    }
    if (changeCurrency == true) {
      await userPreferences.setUserCurrencyCode(possibleCurrencyCode);
    }
  }
}
