import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/preferences/country_selector/localized_country.dart';
import 'package:smooth_app/pages/preferences/country_selector/openfoodfacts_country_iso2code_extension.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_list_choice.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_selector_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

part 'country_selector_provider.dart';

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
  final bool autoValidate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_CountrySelectorProvider>(
      create: (_) => _CountrySelectorProvider(
        preferences: context.read<UserPreferences>(),
        autoValidate: autoValidate,
      ),
      child: Consumer<_CountrySelectorProvider>(
        builder: (context, provider, _) {
          return switch (provider.value) {
            PreferencesSelectorLoadingState<LocalizedCountry>() => SizedBox(
                height: loadingHeight,
                child:
                    const Center(child: CircularProgressIndicator.adaptive()),
              ),
            PreferencesSelectorLoadedState<LocalizedCountry>() =>
              _CountrySelectorButton(
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
              PreferencesSelectorState<LocalizedCountry>>(
            buildWhen: (previous, current) =>
                previous is PreferencesSelectorLoadedState<LocalizedCountry> &&
                current is PreferencesSelectorLoadedState<LocalizedCountry> &&
                current.selectedItem != previous.selectedItem,
            builder: (_, state, __) {
              final country =
                  (state as PreferencesSelectorLoadedState<LocalizedCountry>)
                      .selectedItem;
              final String displayName = country?.localizedName ?? '';

              return Padding(
                padding: innerPadding,
                child: Row(
                  children: [
                    SizedBox(
                      width: IconTheme.of(context).size! + LARGE_SPACE,
                      child: AutoSizeText(
                        EmojiHelper.getCountryEmoji(country?.country) ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: IconTheme.of(context).size),
                      ),
                    ),
                    const SizedBox(width: SMALL_SPACE),
                    Expanded(
                      child: Text(
                        displayName,
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
    final newCountry = await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _CountrySelectorScreen(
          provider: context.read<_CountrySelectorProvider>(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset = Tween<Offset>(
                  begin: const Offset(0.0, 1.0), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(
            position: offset,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );

    if (!context.mounted) return;

    if (newCountry == null) {
      context.read<_CountrySelectorProvider>().dismissSelectedItem();
    } else if (newCountry is LocalizedCountry) {
      _changeCurrencyIfRelevant(context, newCountry.country);
    }
  }

  Future<void> _changeCurrencyIfRelevant(
      BuildContext context, OpenFoodFactsCountry country) async {
    final userPreferences = context.read<UserPreferences>();
    final possibleCurrencyCode = country.currency?.name;
    if (possibleCurrencyCode == null) return;

    bool? changeCurrency;
    final currentCurrencyCode = userPreferences.userCurrencyCode;

    if (currentCurrencyCode == null ||
        forceCurrencyChange ||
        currentCurrencyCode != possibleCurrencyCode) {
      final appLocalizations = AppLocalizations.of(context);
      changeCurrency = await showDialog<bool>(
        context: context,
        builder: (context) => SmoothAlertDialog(
          body: Text(
            '${appLocalizations.country_change_message}\n${appLocalizations.currency_auto_change_message(currentCurrencyCode ?? '', possibleCurrencyCode)}',
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
  const _CountrySelectorScreen({required this.provider});

  final _CountrySelectorProvider provider;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    LocalizedCountry.getLocalizedCountries();

    return SmoothSelectorScreen<LocalizedCountry>(
      provider: provider,
      title: appLocalizations.country_selector_title,
      itemBuilder: (context, country, selected, filter) {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                EmojiHelper.getCountryEmoji(country.country) ?? '',
                style: const TextStyle(fontSize: 25.0),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                country.country.iso2Code,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 7,
              child: TextHighlighter(
                text: country.localizedName,
                filter: filter,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
      itemsFilter: (list, selectedItem, selectedItemOverride, filter) {
        return list.where((country) {
          return country == selectedItem ||
              country == selectedItemOverride ||
              country.localizedName
                  .toLowerCase()
                  .contains(filter.toLowerCase()) ||
              country.country.iso2Code
                  .toLowerCase()
                  .contains(filter.toLowerCase()) ||
              country.preferenceCode
                  .toLowerCase()
                  .contains(filter.toLowerCase());
        });
      },
    );
  }
}
