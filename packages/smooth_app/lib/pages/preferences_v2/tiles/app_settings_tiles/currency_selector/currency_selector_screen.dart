import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/app_settings_tiles/currency_selector/currency_selector_provider.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/pages/prices/currency_name_extension.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/selector_screen/smooth_screen_list_choice.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class CurrencySelectorScreen extends StatelessWidget {
  const CurrencySelectorScreen({required this.provider, super.key});

  final CurrencySelectorProvider provider;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothSelectorScreen<Currency>(
      provider: provider,
      title: appLocalizations.currency_selector_title,
      itemBuilder:
          (
            BuildContext context,
            Currency currency,
            bool selected,
            String filter,
          ) {
            return Row(
              children: <Widget>[
                const icons.Currency(),
                const SizedBox(width: SMALL_SPACE),
                Expanded(
                  child: TextHighlighter(
                    text: currency.localizedName(appLocalizations),
                    filter: filter,
                  ),
                ),
                const SizedBox(width: SMALL_SPACE),
                TextHighlighter(
                  text: currency.getFullName(),
                  filter: filter,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
      itemsFilter:
          (
            List<Currency> currencies,
            Currency? selectedItem,
            Currency? selectedItemOverride,
            String filter,
          ) => filterCurrencies(
            currencies,
            selectedItem,
            selectedItemOverride,
            filter,
            appLocalizations: appLocalizations,
          ),
    );
  }
}
