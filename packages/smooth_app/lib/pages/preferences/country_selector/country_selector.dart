import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

part 'country_selector_provider.dart';

/// A button that will open a list of countries and save it in the preferences.
class CountrySelector extends StatelessWidget {
  const CountrySelector({
    required this.forceCurrencyChange,
    this.textStyle,
    this.padding,
    this.icon,
    this.inkWellBorderRadius,
    this.autoValidate = true,
  });

  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? inkWellBorderRadius;
  final Widget? icon;
  final bool forceCurrencyChange;

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
            _CountrySelectorLoadingState _ => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            _CountrySelectorLoadedState _ => _CountrySelectorButton(
                icon: icon,
                innerPadding: const EdgeInsetsDirectional.symmetric(
                  vertical: SMALL_SPACE,
                ).add(padding ?? EdgeInsets.zero),
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
        child: ConsumerValueNotifierFilter<_CountrySelectorProvider,
            _CountrySelectorState>(
          buildWhen: (_CountrySelectorState? previousValue,
                  _CountrySelectorState currentValue) =>
              previousValue != null &&
              currentValue is! _CountrySelectorEditingState &&
              (currentValue as _CountrySelectorLoadedState).country !=
                  (previousValue as _CountrySelectorLoadedState).country,
          builder: (_, _CountrySelectorState value, __) {
            final Country? country =
                (value as _CountrySelectorLoadedState).country;

            return Row(
              children: <Widget>[
                if (country != null)
                  SizedBox(
                    height: IconTheme.of(context).size,
                    width: IconTheme.of(context).size! + LARGE_SPACE,
                    child: AutoSizeText(
                      EmojiHelper.getEmojiByCountryCode(country.countryCode)!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 25.0),
                    ),
                  )
                else
                  const Icon(Icons.public),
                Expanded(
                  child: Padding(
                    padding: innerPadding,
                    child: Text(
                      country?.name ?? AppLocalizations.of(context).loading,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.merge(textStyle),
                    ),
                  ),
                ),
                icon ?? const Icon(Icons.arrow_drop_down),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openCountrySelector(BuildContext context) async {
    final dynamic newCountry =
        await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<dynamic>(
          pageBuilder: (_, __, ___) =>

              /// We re-inject the [_CountrySelectorProvider], otherwise it's not in
              /// the same tree. [ListenableProvider] allows to prevent the auto-dispose.
              ListenableProvider<_CountrySelectorProvider>(
                create: (_) => context.read<_CountrySelectorProvider>(),
                dispose: (_, __) {},
                child: const _CountrySelectorScreen(),
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
      context.read<_CountrySelectorProvider>().dismissSelectedCountry();
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
    final OpenFoodFactsCountry? offCountry =
        OpenFoodFactsCountry.fromOffTag(country.countryCode);
    final String? possibleCurrencyCode = offCountry?.currency?.name;

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
            onPressed: () => Navigator.of(context).pop(),
            text: appLocalizations.no,
          ),
          positiveAction: SmoothActionButton(
            onPressed: () => Navigator.of(context).pop(true),
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
  const _CountrySelectorScreen();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final _CountrySelectorProvider provider =
        context.read<_CountrySelectorProvider>();

    return ValueNotifierListener<_CountrySelectorProvider,
        _CountrySelectorState>(
      listenerWithValueNotifier: _onValueChanged,
      child: SmoothScaffold2(
        topBar: SmoothTopBar2(
          title: appLocalizations.country_selector_title,
          leadingAction: provider.autoValidate
              ? SmoothTopBarLeadingAction.minimize
              : SmoothTopBarLeadingAction.close,
        ),
        bottomBar:
            !provider.autoValidate ? const _CountrySelectorBottomBar() : null,
        children: <Widget>[
          Consumer<_CountrySelectorProvider>(
            builder:
                (BuildContext context, _CountrySelectorProvider provider, _) {
              final _CountrySelectorLoadedState state =
                  provider.value as _CountrySelectorLoadedState;

              return SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final Country country = state.countries[index];
                    final bool selected = state is _CountrySelectorEditingState
                        ? country == state.selectedCountry
                        : country == state.country;

                    return _CountrySelectorListItem(
                      country: country,
                      selected: selected,
                    );
                  },
                  childCount: state.countries.length,
                ),
                itemExtent: 60.0,
              );
            },
          )
        ],
      ),
    );
  }

  /// When the value changed in [autoValidate] mode, we close the screen
  void _onValueChanged(
    BuildContext context,
    _CountrySelectorProvider provider,
    _CountrySelectorState? oldValue,
    _CountrySelectorState currentValue,
  ) {
    if (provider.autoValidate &&
        oldValue is _CountrySelectorEditingState &&
        currentValue is! _CountrySelectorEditingState &&
        currentValue is _CountrySelectorLoadedState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(currentValue.country);
      });
    }
  }
}

class _CountrySelectorBottomBar extends StatelessWidget {
  const _CountrySelectorBottomBar();

  @override
  Widget build(BuildContext context) {
    return ConsumerValueNotifierFilter<_CountrySelectorProvider,
        _CountrySelectorState>(
      builder: (
        BuildContext context,
        _CountrySelectorState value,
        _,
      ) {
        if (value is! _CountrySelectorEditingState) {
          return EMPTY_WIDGET;
        }

        return SmoothButtonsBar2(
          positiveButton: SmoothActionButton2(
              text: AppLocalizations.of(context).validate,
              icon: const Arrow.right(),
              onPressed: () => _saveCountry(context)),
        );
      },
    );
  }

  void _saveCountry(BuildContext context) {
    final _CountrySelectorProvider countryProvider =
        context.read<_CountrySelectorProvider>();

    /// Without autoValidate, we need to manually close the screen
    countryProvider.saveSelectedCountry();
    Navigator.of(context).pop(
      (countryProvider.value as _CountrySelectorLoadedState).country,
    );
  }
}

class _CountrySelectorListItem extends StatelessWidget {
  const _CountrySelectorListItem({
    required this.country,
    required this.selected,
  });

  final Country country;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final _CountrySelectorProvider provider =
        context.read<_CountrySelectorProvider>();

    return Semantics(
      value: country.name,
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: SmoothAnimationsDuration.short,
        margin: const EdgeInsetsDirectional.only(
          start: SMALL_SPACE,
          end: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        decoration: BoxDecoration(
          borderRadius: ANGULAR_BORDER_RADIUS,
          border: Border.all(
            color: selected ? colors.secondaryLight : colors.primaryMedium,
            width: selected ? 3.0 : 1.0,
          ),
          color: selected
              ? context.darkTheme()
                  ? colors.primarySemiDark
                  : colors.primaryLight
              : Colors.transparent,
        ),
        child: InkWell(
          borderRadius: ANGULAR_BORDER_RADIUS,
          onTap: () => provider.changeSelectedCountry(country),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SMALL_SPACE,
              vertical: VERY_SMALL_SPACE,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    EmojiHelper.getEmojiByCountryCode(country.countryCode) ??
                        '',
                    style: const TextStyle(fontSize: 25.0),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    country.countryCode.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Text(
                    country.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
