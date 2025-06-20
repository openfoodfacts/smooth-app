import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/country_selector/country.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_list_choice.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_selector_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

part 'country_selector_provider.dart';

/// A button that will open a list of countries and save it in the preferences.
class CountrySelector extends StatelessWidget {
  const CountrySelector({
    required this.forceCurrencyChange,
    this.textStyle,
    this.padding,
    this.icon,
    this.inkWellBorderRadius,
    this.loadingHeight = 48.0,
    this.autoValidate = true,
  });

  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? inkWellBorderRadius;
  final Widget? icon;
  final bool forceCurrencyChange;
  final double loadingHeight;

  /// A click on a new country will automatically save it
  final bool autoValidate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_CountrySelectorProvider>(
      create: (_) => _CountrySelectorProvider(
        preferences: context.read<UserPreferences>(),
        autoValidate: autoValidate,
      ),
      child: Consumer<_CountrySelectorProvider>(
        builder: (BuildContext context, _CountrySelectorProvider provider, _) {
          return switch (provider.value) {
            PreferencesSelectorLoadingState<Country> _ => SizedBox(
                height: loadingHeight,
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
            PreferencesSelectorLoadedState<Country> _ => _CountrySelectorButton(
                icon: icon,
                innerPadding: padding ?? EdgeInsets.zero,
                textStyle: textStyle,
                inkWellBorderRadius: inkWellBorderRadius,
                forceCurrencyChange: forceCurrencyChange,
                autoValidate: autoValidate,
              ),
          };
        },
      ),
    );
  }
}

class _CountrySelectorButton extends StatelessWidget {
  const _CountrySelectorButton({
    required this.innerPadding,
    required this.forceCurrencyChange,
    required this.autoValidate,
    this.icon,
    this.textStyle,
    this.inkWellBorderRadius,
  });

  final Widget? icon;
  final EdgeInsetsGeometry innerPadding;
  final TextStyle? textStyle;
  final BorderRadius? inkWellBorderRadius;
  final bool forceCurrencyChange;
  final bool autoValidate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: inkWellBorderRadius ?? ANGULAR_BORDER_RADIUS,
      onTap: () => _openCountrySelector(context),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40.0),
          child: ConsumerValueNotifierFilter<_CountrySelectorProvider,
              PreferencesSelectorState<Country>>(
            buildWhen: (PreferencesSelectorState<Country>? previousValue,
                    PreferencesSelectorState<Country> currentValue) =>
                previousValue != null &&
                currentValue is! PreferencesSelectorEditingState &&
                (currentValue as PreferencesSelectorLoadedState<Country>)
                        .selectedItem !=
                    (previousValue as PreferencesSelectorLoadedState<Country>)
                        .selectedItem,
            builder: (_, PreferencesSelectorState<Country> value, __) {
              final Country? country =
                  (value as PreferencesSelectorLoadedState<Country>)
                      .selectedItem;

              return Padding(
                padding: innerPadding,
                child: Row(
                  children: <Widget>[
                    if (country != null)
                      SizedBox(
                        width: IconTheme.of(context).size! + LARGE_SPACE,
                        child: AutoSizeText(
                          EmojiHelper.getCountryEmoji(country)!,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: IconTheme.of(context).size),
                        ),
                      )
                    else
                      const Icon(Icons.public),
                    const SizedBox(width: SMALL_SPACE),
                    Expanded(
                      child: Text(
                        country?.name ?? AppLocalizations.of(context).loading,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.merge(textStyle),
                      ),
                    ),
                    icon ?? const Icon(Icons.arrow_drop_down),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openCountrySelector(BuildContext context) async {
    final dynamic newCountry =
        await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<dynamic>(
          pageBuilder: (_, __, ___) => _CountrySelectorScreen(
                provider: context.read<_CountrySelectorProvider>(),
              ),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            final Tween<Offset> tween = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            );
            final CurvedAnimation curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            final Animation<Offset> position = tween.animate(curvedAnimation);

            return SlideTransition(
              position: position,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          }),
    );

    if (!context.mounted) {
      return;
    }

    /// Ensure to restore the previous state
    /// (eg: the user uses the Android back button).
    if (newCountry == null) {
      context.read<_CountrySelectorProvider>().dismissSelectedItem();
    } else if (newCountry is Country) {
      _changeCurrencyIfRelevant(context, newCountry);
    }
  }

// TODO(g123k): move this to a dedicated Provider
  Future<void> _changeCurrencyIfRelevant(
    final BuildContext context,
    final Country country,
  ) async {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    final String? possibleCurrencyCode = country.currency?.name;

    if (possibleCurrencyCode == null) {
      return;
    }

    bool? changeCurrency;
    final String? currentCurrencyCode = userPreferences.userCurrencyCode;

    if (currentCurrencyCode == null) {
      changeCurrency = true;
    } else if (forceCurrencyChange) {
      changeCurrency = true;
    } else if (currentCurrencyCode != possibleCurrencyCode) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      changeCurrency = await showDialog<bool>(
        context: context,
        builder: (final BuildContext context) => SmoothAlertDialog(
          body: Text(
            '${appLocalizations.country_change_message}'
            '\n'
            '${appLocalizations.currency_auto_change_message(
              currentCurrencyCode,
              possibleCurrencyCode,
            )}',
          ),
          negativeAction: SmoothActionButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            text: appLocalizations.no,
          ),
          positiveAction: SmoothActionButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
            text: appLocalizations.yes,
          ),
        ),
      );
    }
    if (changeCurrency == true) {
      await userPreferences.setUserCurrencyCode(possibleCurrencyCode);
    }
  }
}

class _CountrySelectorScreen extends StatelessWidget {
  const _CountrySelectorScreen({
    required this.provider,
  });

  final _CountrySelectorProvider provider;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothSelectorScreen<Country>(
      provider: provider,
      title: appLocalizations.country_selector_title,
      itemBuilder: (
        BuildContext context,
        Country country,
        bool selected,
        String filter,
      ) {
        return Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                EmojiHelper.getCountryEmoji(country)!,
                style: const TextStyle(fontSize: 25.0),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                country.offTag.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 7,
              child: TextHighlighter(
                text: country.name,
                filter: filter,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        );
      },
      itemsFilter: (List<Country> list, Country? selectedItem,
              Country? selectedItemOverride, String filter) =>
          _filterCountries(
        list,
        selectedItem,
        selectedItemOverride,
        filter,
      ),
    );
  }

  Iterable<Country> _filterCountries(
    List<Country> countries,
    Country? userCountry,
    Country? selectedCountry,
    String? filter,
  ) {
    if (filter == null || filter.isEmpty) {
      return countries;
    }

    return countries.where(
      (Country country) =>
          country == userCountry ||
          country == selectedCountry ||
          country.name.toLowerCase().contains(
                filter.toLowerCase(),
              ) ||
          country.offTag.toLowerCase().contains(
                filter.toLowerCase(),
              ),
    );
  }
}
