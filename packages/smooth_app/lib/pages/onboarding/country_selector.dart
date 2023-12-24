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
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// A selector for selecting user's country.
class CountrySelector extends StatefulWidget {
  const CountrySelector({
    this.textStyle,
    this.padding,
    this.icon,
    this.iconDecoration,
    this.inkWellBorderRadius,
  });

  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? inkWellBorderRadius;
  final Icon? icon;
  final BoxDecoration? iconDecoration;

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _countryController = TextEditingController();
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
          await IsoCountries.isoCountriesForLocale(languageCode);
    } on MissingPluginException catch (_) {
      // Locales are not implemented on desktop and web
      localizedCountries = <Country>[
        const Country(name: 'Afghanistan', countryCode: 'AF'),
        const Country(name: 'Albania', countryCode: 'AL'),
        const Country(name: 'Algeria', countryCode: 'DZ'),
        const Country(name: 'Andorra', countryCode: 'AD'),
        const Country(name: 'Angola', countryCode: 'AO'),
        const Country(name: 'Antigua and Barbuda', countryCode: 'AG'),
        const Country(name: 'Argentina', countryCode: 'AR'),
        const Country(name: 'Armenia', countryCode: 'AM'),
        const Country(name: 'Australia', countryCode: 'AU'),
        const Country(name: 'Austria', countryCode: 'AT'),
        const Country(name: 'Azerbaijan', countryCode: 'AZ'),
        const Country(name: 'Bahamas', countryCode: 'BS'),
        const Country(name: 'Bahrain', countryCode: 'BH'),
        const Country(name: 'Bangladesh', countryCode: 'BD'),
        const Country(name: 'Barbados', countryCode: 'BB'),
        const Country(name: 'Belarus', countryCode: 'BY'),
        const Country(name: 'Belgium', countryCode: 'BE'),
        const Country(name: 'Belize', countryCode: 'BZ'),
        const Country(name: 'Benin', countryCode: 'BJ'),
        const Country(name: 'Bhutan', countryCode: 'BT'),
        const Country(name: 'Bolivia', countryCode: 'BO'),
        const Country(name: 'Bosnia and Herzegovina', countryCode: 'BA'),
        const Country(name: 'Botswana', countryCode: 'BW'),
        const Country(name: 'Brazil', countryCode: 'BR'),
        const Country(name: 'Brunei', countryCode: 'BN'),
        const Country(name: 'Bulgaria', countryCode: 'BG'),
        const Country(name: 'Burkina Faso', countryCode: 'BF'),
        const Country(name: 'Burundi', countryCode: 'BI'),
        const Country(name: 'Cabo Verde', countryCode: 'CV'),
        const Country(name: 'Cambodia', countryCode: 'KH'),
        const Country(name: 'Cameroon', countryCode: 'CM'),
        const Country(name: 'Canada', countryCode: 'CA'),
        const Country(name: 'Central African Republic', countryCode: 'CF'),
        const Country(name: 'Chad', countryCode: 'TD'),
        const Country(name: 'Chile', countryCode: 'CL'),
        const Country(name: 'China', countryCode: 'CN'),
        const Country(name: 'Colombia', countryCode: 'CO'),
        const Country(name: 'Comoros', countryCode: 'KM'),
        const Country(name: 'Congo (Congo-Brazzaville)', countryCode: 'CG'),
        const Country(name: 'Costa Rica', countryCode: 'CR'),
        const Country(name: "Cote d'Ivoire (Ivory Coast)", countryCode: 'CI'),
        const Country(name: 'Croatia', countryCode: 'HR'),
        const Country(name: 'Cuba', countryCode: 'CU'),
        const Country(name: 'Cyprus', countryCode: 'CY'),
        const Country(name: 'Czechia (Czech Republic)', countryCode: 'CZ'),
        const Country(name: 'Democratic Republic of the Congo', countryCode: 'CD'),
        const Country(name: 'Denmark', countryCode: 'DK'),
        const Country(name: 'Djibouti', countryCode: 'DJ'),
        const Country(name: 'Dominica', countryCode: 'DM'),
        const Country(name: 'Dominican Republic', countryCode: 'DO'),
        const Country(name: 'Ecuador', countryCode: 'EC'),
        const Country(name: 'Egypt', countryCode: 'EG'),
        const Country(name: 'El Salvador', countryCode: 'SV'),
        const Country(name: 'Equatorial Guinea', countryCode: 'GQ'),
        const Country(name: 'Eritrea', countryCode: 'ER'),
        const Country(name: 'Estonia', countryCode: 'EE'),
        const Country(name: 'Eswatini (fmr. "Swaziland")', countryCode: 'SZ'),
        const Country(name: 'Ethiopia', countryCode: 'ET'),
        const Country(name: 'Fiji', countryCode: 'FJ'),
        const Country(name: 'Finland', countryCode: 'FI'),
        const Country(name: 'France', countryCode: 'FR'),
        const Country(name: 'Gabon', countryCode: 'GA'),
        const Country(name: 'Gambia', countryCode: 'GM'),
        const Country(name: 'Georgia', countryCode: 'GE'),
        const Country(name: 'Germany', countryCode: 'DE'),
        const Country(name: 'Ghana', countryCode: 'GH'),
        const Country(name: 'Greece', countryCode: 'GR'),
        const Country(name: 'Grenada', countryCode: 'GD'),
        const Country(name: 'Guatemala', countryCode: 'GT'),
        const Country(name: 'Guinea', countryCode: 'GN'),
        const Country(name: 'Guinea-Bissau', countryCode: 'GW'),
        const Country(name: 'Guyana', countryCode: 'GY'),
        const Country(name: 'Haiti', countryCode: 'HT'),
        const Country(name: 'Holy See', countryCode: 'VA'),
        const Country(name: 'Honduras', countryCode: 'HN'),
        const Country(name: 'Hungary', countryCode: 'HU'),
        const Country(name: 'Iceland', countryCode: 'IS'),
        const Country(name: 'India', countryCode: 'IN'),
        const Country(name: 'Indonesia', countryCode: 'ID'),
        const Country(name: 'Iran', countryCode: 'IR'),
        const Country(name: 'Iraq', countryCode: 'IQ'),
        const Country(name: 'Ireland', countryCode: 'IE'),
        const Country(name: 'Israel', countryCode: 'IL'),
        const Country(name: 'Italy', countryCode: 'IT'),
        const Country(name: 'Jamaica', countryCode: 'JM'),
        const Country(name: 'Japan', countryCode: 'JP'),
        const Country(name: 'Jordan', countryCode: 'JO'),
        const Country(name: 'Kazakhstan', countryCode: 'KZ'),
        const Country(name: 'Kenya', countryCode: 'KE'),
        const Country(name: 'Kiribati', countryCode: 'KI'),
        const Country(name: 'Kuwait', countryCode: 'KW'),
        const Country(name: 'Kyrgyzstan', countryCode: 'KG'),
        const Country(name: 'Laos', countryCode: 'LA'),
        const Country(name: 'Latvia', countryCode: 'LV'),
        const Country(name: 'Lebanon', countryCode: 'LB'),
        const Country(name: 'Lesotho', countryCode: 'LS'),
        const Country(name: 'Liberia', countryCode: 'LR'),
        const Country(name: 'Libya', countryCode: 'LY'),
        const Country(name: 'Liechtenstein', countryCode: 'LI'),
        const Country(name: 'Lithuania', countryCode: 'LT'),
        const Country(name: 'Luxembourg', countryCode: 'LU'),
        const Country(name: 'Madagascar', countryCode: 'MG'),
        const Country(name: 'Malawi', countryCode: 'MW'),
        const Country(name: 'Malaysia', countryCode: 'MY'),
        const Country(name: 'Maldives', countryCode: 'MV'),
        const Country(name: 'Mali', countryCode: 'ML'),
        const Country(name: 'Malta', countryCode: 'MT'),
        const Country(name: 'Marshall Islands', countryCode: 'MH'),
        const Country(name: 'Mauritania', countryCode: 'MR'),
        const Country(name: 'Mauritius', countryCode: 'MU'),
        const Country(name: 'Mexico', countryCode: 'MX'),
        const Country(name: 'Micronesia', countryCode: 'FM'),
        const Country(name: 'Moldova', countryCode: 'MD'),
        const Country(name: 'Monaco', countryCode: 'MC'),
        const Country(name: 'Mongolia', countryCode: 'MN'),
        const Country(name: 'Montenegro', countryCode: 'ME'),
        const Country(name: 'Morocco', countryCode: 'MA'),
        const Country(name: 'Mozambique', countryCode: 'MZ'),
        const Country(name: 'Myanmar (formerly Burma)', countryCode: 'MM'),
        const Country(name: 'Namibia', countryCode: 'NA'),
        const Country(name: 'Nauru', countryCode: 'NR'),
        const Country(name: 'Nepal', countryCode: 'NP'),
        const Country(name: 'Netherlands', countryCode: 'NL'),
        const Country(name: 'New Zealand', countryCode: 'NZ'),
        const Country(name: 'Nicaragua', countryCode: 'NI'),
        const Country(name: 'Niger', countryCode: 'NE'),
        const Country(name: 'Nigeria', countryCode: 'NG'),
        const Country(name: 'North Korea', countryCode: 'KP'),
        const Country(name: 'North Macedonia (formerly Macedonia)', countryCode: 'MK'),
        const Country(name: 'Norway', countryCode: 'NO'),
        const Country(name: 'Oman', countryCode: 'OM'),
        const Country(name: 'Pakistan', countryCode: 'PK'),
        const Country(name: 'Palau', countryCode: 'PW'),
        const Country(name: 'Palestine State', countryCode: 'PS'),
        const Country(name: 'Panama', countryCode: 'PA'),
        const Country(name: 'Papua New Guinea', countryCode: 'PG'),
        const Country(name: 'Paraguay', countryCode: 'PY'),
        const Country(name: 'Peru', countryCode: 'PE'),
        const Country(name: 'Philippines', countryCode: 'PH'),
        const Country(name: 'Poland', countryCode: 'PL'),
        const Country(name: 'Portugal', countryCode: 'PT'),
        const Country(name: 'Qatar', countryCode: 'QA'),
        const Country(name: 'Romania', countryCode: 'RO'),
        const Country(name: 'Russia', countryCode: 'RU'),
        const Country(name: 'Rwanda', countryCode: 'RW'),
        const Country(name: 'Saint Kitts and Nevis', countryCode: 'KN'),
        const Country(name: 'Saint Lucia', countryCode: 'LC'),
        const Country(name: 'Saint Vincent and the Grenadines', countryCode: 'VC'),
        const Country(name: 'Samoa', countryCode: 'WS'),
        const Country(name: 'San Marino', countryCode: 'SM'),
        const Country(name: 'Sao Tome and Principe', countryCode: 'ST'),
        const Country(name: 'Saudi Arabia', countryCode: 'SA'),
        const Country(name: 'Senegal', countryCode: 'SN'),
        const Country(name: 'Serbia', countryCode: 'RS'),
        const Country(name: 'Seychelles', countryCode: 'SC'),
        const Country(name: 'Sierra Leone', countryCode: 'SL'),
        const Country(name: 'Singapore', countryCode: 'SG'),
        const Country(name: 'Slovakia', countryCode: 'SK'),
        const Country(name: 'Slovenia', countryCode: 'SI'),
        const Country(name: 'Solomon Islands', countryCode: 'SB'),
        const Country(name: 'Somalia', countryCode: 'SO'),
        const Country(name: 'South Africa', countryCode: 'ZA'),
        const Country(name: 'South Korea', countryCode: 'KR'),
        const Country(name: 'South Sudan', countryCode: 'SS'),
        const Country(name: 'Spain', countryCode: 'ES'),
        const Country(name: 'Sri Lanka', countryCode: 'LK'),
        const Country(name: 'Sudan', countryCode: 'SD'),
        const Country(name: 'Suriname', countryCode: 'SR'),
        const Country(name: 'Sweden', countryCode: 'SE'),
        const Country(name: 'Switzerland', countryCode: 'CH'),
        const Country(name: 'Syria', countryCode: 'SY'),
        const Country(name: 'Tajikistan', countryCode: 'TJ'),
        const Country(name: 'Tanzania', countryCode: 'TZ'),
        const Country(name: 'Thailand', countryCode: 'TH'),
        const Country(name: 'Timor-Leste', countryCode: 'TL'),
        const Country(name: 'Togo', countryCode: 'TG'),
        const Country(name: 'Tonga', countryCode: 'TO'),
        const Country(name: 'Trinidad and Tobago', countryCode: 'TT'),
        const Country(name: 'Tunisia', countryCode: 'TN'),
        const Country(name: 'Turkey', countryCode: 'TR'),
        const Country(name: 'Turkmenistan', countryCode: 'TM'),
        const Country(name: 'Tuvalu', countryCode: 'TV'),
        const Country(name: 'Uganda', countryCode: 'UG'),
        const Country(name: 'Ukraine', countryCode: 'UA'),
        const Country(name: 'United Arab Emirates', countryCode: 'AE'),
        const Country(name: 'United Kingdom', countryCode: 'GB'),
        const Country(name: 'United States of America', countryCode: 'US'),
        const Country(name: 'Uruguay', countryCode: 'UY'),
        const Country(name: 'Uzbekistan', countryCode: 'UZ'),
        const Country(name: 'Vanuatu', countryCode: 'VU'),
        const Country(name: 'Venezuela', countryCode: 'VE'),
        const Country(name: 'Vietnam', countryCode: 'VN'),
        const Country(name: 'Yemen', countryCode: 'YE'),
        const Country(name: 'Zambia', countryCode: 'ZM'),
        const Country(name: 'Zimbabwe', countryCode: 'ZW'),];
    }
    _countryList = _sanitizeCountriesList(localizedCountries);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
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
                        controller: _countryController,
                        onChanged: (String? query) {
                          query = query!.trim()..getComparisonSafeString();

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
                            trailing: selected ? const Icon(Icons.check) : null,
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                      child: Text(
                        selectedCountry.name,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.merge(widget.textStyle),
                      ),
                    ),
                  ),
                  Container(
                    height: double.infinity,
                    decoration: widget.iconDecoration ?? const BoxDecoration(),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: widget.icon ?? const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ],
              ),
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

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }
}
