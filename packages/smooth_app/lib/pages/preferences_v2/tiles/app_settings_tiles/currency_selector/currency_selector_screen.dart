import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/app_settings_tiles/currency_selector/currency_selector_provider.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/selector_screen/smooth_screen_list_choice.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class CurrencySelectorScreen extends StatelessWidget {
  const CurrencySelectorScreen({required this.provider, super.key});

  final CurrencySelectorProvider provider;

  @override
  Widget build(BuildContext context) {
    return SmoothSelectorScreen<Currency>(
      provider: provider,
      title: AppLocalizations.of(context).currency_selector_title,
      itemBuilder:
          (
            BuildContext context,
            Currency currency,
            bool selected,
            String filter,
          ) {
            return Row(
              children: <Widget>[
                const Expanded(flex: 1, child: icons.Currency()),
                Expanded(
                  flex: 2,
                  child: Text(
                    currency.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: TextHighlighter(
                    text: currency.getFullName(),
                    filter: filter,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
      itemsFilter: filterCurrencies,
    );
  }
}
