import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_language_refresh.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_list_choice.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_selector_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

part 'language_selector_provider.dart';

/// A button that will open a list of countries and save it in the preferences.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
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
  final double loadingHeight;

  /// A click on a new language will automatically save it
  final bool autoValidate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_LanguageSelectorProvider>(
      create: (_) => _LanguageSelectorProvider(
        preferences: context.read<UserPreferences>(),
        autoValidate: autoValidate,
      ),
      child: Consumer<_LanguageSelectorProvider>(
        builder: (BuildContext context, _LanguageSelectorProvider provider, _) {
          return switch (provider.value) {
            PreferencesSelectorLoadingState<OpenFoodFactsLanguage> _ =>
              SizedBox(
                height: loadingHeight,
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
            PreferencesSelectorLoadedState<OpenFoodFactsLanguage> _ =>
              _LanguageSelectorButton(
                icon: icon,
                innerPadding: const EdgeInsetsDirectional.symmetric(
                  vertical: SMALL_SPACE,
                ).add(padding ?? EdgeInsets.zero),
                textStyle: textStyle,
                inkWellBorderRadius: inkWellBorderRadius,
                autoValidate: autoValidate,
              ),
          };
        },
      ),
    );
  }

  static String _getCompleteName(final OpenFoodFactsLanguage language) {
    final String nameInLanguage = Languages().getNameInLanguage(language);
    final String nameInEnglish = Languages().getNameInEnglish(language);
    return '$nameInLanguage ($nameInEnglish)';
  }
}

class _LanguageSelectorButton extends StatelessWidget {
  const _LanguageSelectorButton({
    required this.innerPadding,
    required this.autoValidate,
    this.icon,
    this.textStyle,
    this.inkWellBorderRadius,
  });

  final Widget? icon;
  final EdgeInsetsGeometry innerPadding;
  final TextStyle? textStyle;
  final BorderRadius? inkWellBorderRadius;
  final bool autoValidate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: inkWellBorderRadius ?? ANGULAR_BORDER_RADIUS,
      onTap: () => _openLanguageSelector(context),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: ConsumerValueNotifierFilter<_LanguageSelectorProvider,
            PreferencesSelectorState<OpenFoodFactsLanguage>>(
          buildWhen:
              (PreferencesSelectorState<OpenFoodFactsLanguage>? previousValue,
                      PreferencesSelectorState<OpenFoodFactsLanguage>
                          currentValue) =>
                  previousValue != null &&
                  currentValue is! PreferencesSelectorEditingState &&
                  (currentValue as PreferencesSelectorLoadedState<
                              OpenFoodFactsLanguage>)
                          .selectedItem !=
                      (previousValue as PreferencesSelectorLoadedState<
                              OpenFoodFactsLanguage>)
                          .selectedItem,
          builder:
              (_, PreferencesSelectorState<OpenFoodFactsLanguage> value, __) {
            final OpenFoodFactsLanguage? language =
                (value as PreferencesSelectorLoadedState<OpenFoodFactsLanguage>)
                    .selectedItem;

            return Padding(
              padding: innerPadding,
              child: Row(
                children: <Widget>[
                  const Icon(Icons.language),
                  const SizedBox(width: LARGE_SPACE),
                  Expanded(
                    child: Text(
                      LanguageSelector._getCompleteName(language!),
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
    );
  }

  Future<void> _openLanguageSelector(BuildContext context) async {
    final dynamic newLanguage =
        await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<dynamic>(
          pageBuilder: (_, __, ___) => _LanguageSelectorScreen(
                provider: context.read<_LanguageSelectorProvider>(),
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
    if (newLanguage == null) {
      context.read<_LanguageSelectorProvider>().dismissSelectedItem();
      return;
    } else if (newLanguage is! OpenFoodFactsLanguage) {
      return;
    }

    ProductQuery.setLanguage(
      context,
      context.read<UserPreferences>(),
      languageCode: newLanguage.code,
    );
    final ProductPreferences productPreferences =
        context.read<ProductPreferences>();
    await BackgroundTaskLanguageRefresh.addTask(
      context.read<LocalDatabase>(),
    );

    // Refresh the news feed
    if (context.mounted) {
      context.read<AppNewsProvider>().loadLatestNews();
    }
    // TODO(monsieurtanuki): make it a background task also?
    // no await
    productPreferences.refresh();
  }
}

class _LanguageSelectorScreen extends StatelessWidget {
  const _LanguageSelectorScreen({
    required this.provider,
  });

  final _LanguageSelectorProvider provider;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothSelectorScreen<OpenFoodFactsLanguage>(
      provider: provider,
      title: appLocalizations.language_selector_title,
      itemBuilder: (
        BuildContext context,
        OpenFoodFactsLanguage language,
        bool selected,
        String filter,
      ) {
        return Row(
          children: <Widget>[
            const Icon(Icons.language),
            const SizedBox(width: LARGE_SPACE),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: SMALL_SPACE,
                ),
                child: TextHighlighter(
                  text: LanguageSelector._getCompleteName(language),
                  filter: filter,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      itemsFilter: (List<OpenFoodFactsLanguage> list,
              OpenFoodFactsLanguage? selectedItem,
              OpenFoodFactsLanguage? selectedItemOverride,
              String filter) =>
          _filterCountries(
        list,
        selectedItem,
        selectedItemOverride,
        filter,
      ),
    );
  }

  Iterable<OpenFoodFactsLanguage> _filterCountries(
    List<OpenFoodFactsLanguage> countries,
    OpenFoodFactsLanguage? userLanguage,
    OpenFoodFactsLanguage? selectedLanguage,
    String? filter,
  ) {
    if (filter == null || filter.isEmpty) {
      return countries;
    }

    return countries.where(
      (OpenFoodFactsLanguage language) =>
          language == userLanguage ||
          language == selectedLanguage ||
          Languages().getNameInLanguage(language).toLowerCase().contains(
                filter.toLowerCase(),
              ),
    );
  }
}
