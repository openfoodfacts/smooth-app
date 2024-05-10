import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// A selector for selecting user's currency.
class CurrencySelector extends StatefulWidget {
  const CurrencySelector({
    this.textStyle,
    this.padding,
    this.icon,
  });

  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Icon? icon;

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _currencyController = TextEditingController();
  final List<Currency> _currencyList = List<Currency>.from(Currency.values);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Selector<UserPreferences, String?>(
      selector: (BuildContext buildContext, UserPreferences userPreferences) =>
          userPreferences.appLanguageCode,
      builder: (BuildContext context, String? appLanguageCode, _) {
        final UserPreferences userPreferences =
            context.watch<UserPreferences>();
        final Currency selected = _getSelected(
          userPreferences.userCurrencyCode,
        );
        final EdgeInsetsGeometry innerPadding = const EdgeInsets.symmetric(
          vertical: SMALL_SPACE,
        ).add(widget.padding ?? EdgeInsets.zero);

        return InkWell(
          borderRadius: ANGULAR_BORDER_RADIUS,
          onTap: () async {
            _reorderCurrencies(selected);
            List<Currency> filteredList = List<Currency>.from(_currencyList);
            final Currency? currency = await showDialog<Currency>(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(VoidCallback fn) setState) {
                    const double horizontalPadding = 16.0 + SMALL_SPACE;

                    return SmoothListAlertDialog(
                      title: appLocalizations.currency_selector_title,
                      header: SmoothTextFormField(
                        type: TextFieldTypes.PLAIN_TEXT,
                        prefixIcon: const Icon(Icons.search),
                        controller: _currencyController,
                        onChanged: (String? query) {
                          query = query!.trim()..getComparisonSafeString();

                          setState(
                            () {
                              filteredList = _currencyList
                                  .where((Currency item) => item.name
                                      .getComparisonSafeString()
                                      .contains(
                                        query!,
                                      ))
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
                          final Currency currency = filteredList[index];
                          final bool isSelected = currency == selected;
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            trailing:
                                isSelected ? const Icon(Icons.check) : null,
                            title: TextHighlighter(
                              text: currency.name,
                              filter: _currencyController.text,
                              selected: isSelected,
                            ),
                            onTap: () {
                              Navigator.of(context).pop(currency);
                              _currencyController.clear();
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
                          _currencyController.clear();
                        },
                        text: appLocalizations.cancel,
                      ),
                    );
                  },
                );
              },
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
                    padding: innerPadding,
                    child: const Icon(Icons.currency_exchange),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                      child: Text(
                        selected.name,
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
  }

  Currency _getSelected(final String? code) {
    if (code != null) {
      for (final Currency currency in _currencyList) {
        if (currency.name == code) {
          return currency;
        }
      }
    }
    return _currencyList[0];
  }

  /// Reorder currencies alphabetically, bring user's selected one to top.
  void _reorderCurrencies(final Currency selected) {
    _currencyList.sort(
      (final Currency a, final Currency b) {
        if (a == selected) {
          return -1;
        }
        if (b == selected) {
          return 1;
        }
        return a.name.compareTo(b.name);
      },
    );
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }
}
