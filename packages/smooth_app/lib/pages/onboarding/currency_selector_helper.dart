import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Helper for currency selection.
class CurrencySelectorHelper {
  factory CurrencySelectorHelper() {
    _instance ??= CurrencySelectorHelper._();
    return _instance!;
  }

  CurrencySelectorHelper._();

  static CurrencySelectorHelper? _instance;

  final List<Currency> _currencyList = List<Currency>.from(Currency.values);

  IconData get currencyIconData => CupertinoIcons.money_dollar_circle;

  Future<Currency?> openCurrencySelector({
    required final BuildContext context,
    required final Currency selected,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ScrollController scrollController = ScrollController();
    final TextEditingController currencyController = TextEditingController();
    _reorderCurrencies(selected);
    List<Currency> filteredList = List<Currency>.from(_currencyList);
    return showDialog<Currency>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(VoidCallback fn) setState) {
                const double horizontalPadding = 16.0 + SMALL_SPACE;

                return SmoothListAlertDialog(
                  title: appLocalizations.currency_selector_title,
                  header: SmoothTextFormField(
                    type: TextFieldTypes.PLAIN_TEXT,
                    prefixIcon: const Icon(Icons.search),
                    controller: currencyController,
                    onChanged: (String? query) {
                      query = query!.trim().getComparisonSafeString();

                      setState(() {
                        filteredList = _currencyList
                            .where(
                              (Currency item) => item
                                  .getFullName()
                                  .getComparisonSafeString()
                                  .contains(query!),
                            )
                            .toList(growable: false);
                      });
                    },
                    hintText: appLocalizations.search,
                  ),
                  scrollController: scrollController,
                  list: ListView.separated(
                    controller: scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      final Currency currency = filteredList[index];
                      final bool isSelected = currency == selected;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        trailing: isSelected ? const Icon(Icons.check) : null,
                        title: TextHighlighter(
                          text: currency.getFullName(),
                          filter: currencyController.text,
                          selected: isSelected,
                        ),
                        onTap: () {
                          Navigator.of(context).pop(currency);
                          currencyController.clear();
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1.0),
                    itemCount: filteredList.length,
                    shrinkWrap: true,
                  ),
                  positiveAction: SmoothActionButton(
                    onPressed: () {
                      Navigator.pop(context);
                      currencyController.clear();
                    },
                    text: appLocalizations.cancel,
                  ),
                );
              },
        );
      },
    );
  }

  Currency getSelected(final String? code) {
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
    _currencyList.sort((final Currency a, final Currency b) {
      if (a == selected) {
        return -1;
      }
      if (b == selected) {
        return 1;
      }
      return a.name.compareTo(b.name);
    });
  }
}
