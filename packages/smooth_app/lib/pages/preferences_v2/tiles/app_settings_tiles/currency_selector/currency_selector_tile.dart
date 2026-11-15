import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/app_settings_tiles/currency_selector/currency_selector_provider.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/app_settings_tiles/currency_selector/currency_selector_screen.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/prices/currency_extension.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_selector_provider.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_selector_route.dart';

class CurrencySelectorTile extends PreferenceTile {
  const CurrencySelectorTile({
    required super.title,
    required this.autoValidate,
  });

  final bool autoValidate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrencySelectorProvider>(
      create: (BuildContext context) {
        final UserPreferences preferences = context.read<UserPreferences>();

        return CurrencySelectorProvider(
          preferences: preferences,
          autoValidate: autoValidate,
          currentCode: () => preferences.userCurrencyCode,
          onSave: (Currency currency) =>
              preferences.setUserCurrencyCode(currency.name),
        );
      },
      child: Consumer<CurrencySelectorProvider>(
        builder: (BuildContext context, CurrencySelectorProvider provider, _) {
          final Currency? currency = switch (provider.value) {
            PreferencesSelectorLoadedState<Currency>(
              :final Currency? selectedItem,
            ) =>
              selectedItem,
            _ => null,
          };

          return PreferenceTile(
            leading: icons.Currency(
              color: context.lightTheme()
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
            title: title,
            subtitleText: currency?.getFullName(),
            onTap: () => _openCurrencySelector(context),
            trailing: const icons.Edit(size: 18.0),
          );
        },
      ),
    );
  }

  Future<void> _openCurrencySelector(BuildContext context) async {
    final CurrencySelectorProvider provider = context
        .read<CurrencySelectorProvider>();

    final Currency? result = await Navigator.of(context, rootNavigator: true)
        .push<Currency>(
          smoothSelectorRoute<Currency>(
            (_) => CurrencySelectorScreen(provider: provider),
          ),
        );

    // Restore the previous state when the route is dismissed without a
    // choice (for example with the Android back button).
    if (result == null && context.mounted) {
      provider.dismissSelectedItem();
    }
  }
}
