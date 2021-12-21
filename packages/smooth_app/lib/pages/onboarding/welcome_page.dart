import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';


// Welcome page for first time users.
class WelcomePage extends StatelessWidget {
  const WelcomePage();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // Side padding is 8% of total width.
    final double sidePadding = screenSize.width * 8 / 100;
    // Top padding is 16% of total width.
    final double topPadding = screenSize.height * 16 / 100;
    // Bottom padding is 4% of total width.
    final double bottomPadding = screenSize.height * 4 / 100;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final TextStyle headlineStyle = Theme.of(context).textTheme.headline2!.apply(color: Colors.white);
    final TextStyle largeButtonTextStyle = Theme.of(context).textTheme.headline3!.apply(color: Colors.white);
    final TextStyle bodyTextStyle = Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding, left: sidePadding, right: sidePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(appLocalizations.whatIsOff, style: headlineStyle),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: SMALL_SPACE),
                  child: Text(appLocalizations.country_label, style: bodyTextStyle),
                ),
                const CountrySelector(),
                Padding(
                  padding: const EdgeInsets.only(left: SMALL_SPACE),
                  child: Text(appLocalizations.country_selection_explanation, style: bodyTextStyle),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: SmoothTheme.getColor(
                          Theme.of(context).colorScheme,
                          SmoothTheme.MATERIAL_COLORS[SmoothTheme.COLOR_TAG_BLUE]!,
                          ColorDestination.BUTTON_BACKGROUND,
                        ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SMALL_SPACE)),
                      primary: Colors.white,
                    ),
                    onPressed: () {
                      // TODO(jasmeet): Navigate to the next page.
                    },
                    child: Text(appLocalizations.next_label, style: largeButtonTextStyle),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    );
  }
}

// Welcome page for first time users.
class CountrySelector extends StatefulWidget {
  const CountrySelector();

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  late UserPreferences _userPreferences;
  late List<Country> _countryList;
  String? _chosenValue;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    _userPreferences = await UserPreferences.getUserPreferences();
    final String locale = Localizations.localeOf(context).languageCode;
    _countryList = await
    IsoCountries.iso_countries_for_locale('hi');
    
  }
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
   return  FutureBuilder<void>(
    future: _initFuture,
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
      if (snapshot.hasError) {
        return Text('Fatal Error: ${snapshot.error}');

      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const CircularProgressIndicator();
      }
      return Padding(
          padding: const EdgeInsets.only(top:MEDIUM_SPACE, bottom: LARGE_SPACE),
          child: DropdownButtonFormField<String>(
              value: _chosenValue,
              //elevation: 5,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color.fromARGB(255, 235, 235, 235)),
      borderRadius: BorderRadius.circular(VERY_LARGE_SPACE),
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 235, 235, 235),
       ),
        items: _countryList.map<DropdownMenuItem<String>>((Country country) {
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
//_userPreferences
              _chosenValue = value;
            }
          });
        },
      ),
   );
  });
}
}