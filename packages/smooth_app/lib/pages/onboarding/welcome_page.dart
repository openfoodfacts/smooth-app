import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// Welcome page for first time users.
class WelcomePage extends StatelessWidget {
  const WelcomePage();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // Side padding is 8% of total width.
    final double sidePadding = screenSize.width * 0.08;
    // Top padding is 16% of total width.
    final double topPadding = screenSize.height * 0.016;
    // Bottom padding is 4% of total width.
    final double bottomPadding = screenSize.height * 0.04;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final TextStyle headlineStyle =
        Theme.of(context).textTheme.headline2!.apply(color: Colors.white);
    final TextStyle largeButtonTextStyle =
        Theme.of(context).textTheme.headline3!.apply(color: Colors.white);
    final TextStyle bodyTextStyle =
        Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: topPadding,
            bottom: bottomPadding,
            left: sidePadding,
            right: sidePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(appLocalizations.whatIsOff, style: headlineStyle),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: SMALL_SPACE),
                  child: Text(
                    appLocalizations.country_chooser_label,
                    style: bodyTextStyle,
                  ),
                ),
                const CountrySelector(),
                Padding(
                  padding: const EdgeInsets.only(left: SMALL_SPACE),
                  child: Text(
                    appLocalizations.country_selection_explanation,
                    style: bodyTextStyle,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: SmoothTheme.getColor(
                        Theme.of(context).colorScheme,
                        SmoothTheme
                            .MATERIAL_COLORS[SmoothTheme.COLOR_TAG_BLUE]!,
                        ColorDestination.BUTTON_BACKGROUND,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SMALL_SPACE)),
                      primary: Colors.white,
                    ),
                    onPressed: () {
                      // TODO(jasmeet): Navigate to the next onboarding page.
                      Navigator.push<Widget>(
                          context,
                          MaterialPageRoute<Widget>(
                            builder: (BuildContext context) => PageManager(),
                          ));
                    },
                    child: Text(
                      appLocalizations.next_label,
                      style: largeButtonTextStyle,
                    ),
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
