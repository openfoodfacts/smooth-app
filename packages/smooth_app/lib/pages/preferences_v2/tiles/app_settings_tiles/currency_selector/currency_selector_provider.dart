import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/pages/prices/currency_name_extension.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_selector_provider.dart';
import 'package:smooth_app/widgets/text/text_extensions.dart';

/// Keeps the selected currencies and the ones matching [filter] (code, symbol
/// or translated name), sorted by translated name with [selectedItem] first.
/// A [List] is returned because the list view reads it by index.
List<Currency> filterCurrencies(
  List<Currency> currencies,
  Currency? selectedItem,
  Currency? selectedItemOverride,
  String filter, {
  required AppLocalizations appLocalizations,
}) {
  final String query = filter.trim().getComparisonSafeString();

  final Map<Currency, String> names = <Currency, String>{
    for (final Currency currency in currencies)
      currency: currency
          .localizedName(appLocalizations)
          .getComparisonSafeString(),
  };

  return currencies
      .where(
        (Currency currency) =>
            query.isEmpty ||
            currency == selectedItem ||
            currency == selectedItemOverride ||
            currency.getFullName().getComparisonSafeString().contains(query) ||
            names[currency]!.contains(query),
      )
      .toList(growable: false)
    ..sort((Currency a, Currency b) {
      if (a == selectedItem) {
        return b == selectedItem ? 0 : -1;
      }
      if (b == selectedItem) {
        return 1;
      }
      return names[a]!.compareTo(names[b]!);
    });
}

class CurrencySelectorProvider extends PreferencesSelectorProvider<Currency> {
  CurrencySelectorProvider({
    required super.preferences,
    required super.autoValidate,
    required this.currentCode,
    required this.onSave,
  });

  /// The currently selected code (read on every preferences change).
  final String? Function() currentCode;

  final Future<void> Function(Currency currency) onSave;

  /// Not `late`: the base constructor reads it before this class' body runs.
  String? _selectedCode;

  @override
  Future<void> onPreferencesChanged() async {
    final String? newCode = currentCode();

    if (value is PreferencesSelectorInitialState<Currency>) {
      _selectedCode = newCode;
      value = _loadedState();
      return;
    }

    // Our own save already updated the selection: nothing else to do, a second
    // transition would close the screen twice in [autoValidate] mode.
    if (newCode == _selectedCode || value is PreferencesSelectorEditingState) {
      return;
    }

    _selectedCode = newCode;
    value = _loadedState();
  }

  /// Never called: the currencies are static, so [onPreferencesChanged] loads
  /// them synchronously. An asynchronous load would expose a loading state to
  /// the screen on its first frame, when it is created with its route.
  @override
  Future<List<Currency>> onLoadValues() async => _loadedState().items;

  @override
  Currency getSelectedValue(List<Currency> values) =>
      CurrencySelectorHelper().getSelected(_selectedCode);

  @override
  Future<void> onSaveItem(Currency item) async {
    final String? previousCode = _selectedCode;
    _selectedCode = item.name;

    try {
      await onSave(item);
    } catch (_) {
      _selectedCode = previousCode;
      dismissSelectedItem();
      rethrow;
    }

    if (value is PreferencesSelectorEditingState<Currency>) {
      value = _loadedState();
    }
  }

  PreferencesSelectorLoadedState<Currency> _loadedState() {
    final Currency selected = getSelectedValue(Currency.values);

    return PreferencesSelectorLoadedState<Currency>(
      selectedItem: selected,
      items: Currency.values,
    );
  }
}
