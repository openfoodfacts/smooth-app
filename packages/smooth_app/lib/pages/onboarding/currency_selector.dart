import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';

/// A selector for selecting user's currency.
class CurrencySelector extends StatelessWidget {
  CurrencySelector({this.textStyle, this.padding, this.icon});

  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Icon? icon;

  final CurrencySelectorHelper helper = CurrencySelectorHelper();

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final Currency selected = helper.getSelected(
      userPreferences.userCurrencyCode,
    );

    return InkWell(
      borderRadius: ANGULAR_BORDER_RADIUS,
      onTap: () async {
        final Currency? currency = await helper.openCurrencySelector(
          context: context,
          selected: selected,
        );
        if (currency != null) {
          await userPreferences.setUserCurrencyCode(currency.name);
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
                padding: const EdgeInsets.symmetric(
                  vertical: SMALL_SPACE,
                ).add(padding ?? EdgeInsets.zero),
                child: Icon(helper.currencyIconData),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                  child: Text(
                    selected.getFullName(),
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.merge(textStyle),
                  ),
                ),
              ),
              icon ?? const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
