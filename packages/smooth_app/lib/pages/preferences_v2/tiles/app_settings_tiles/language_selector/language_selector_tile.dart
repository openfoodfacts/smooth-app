import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_language_refresh.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_list_choice.dart';
import 'package:smooth_app/widgets/selector_screen/smooth_screen_selector_provider.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

part 'language_selector_provider.dart';

class LanguageSelectorTile extends PreferenceTile {
  const LanguageSelectorTile({
    required super.title,
    required this.autoValidate,
  });

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
              _buildLoadingState(),
            PreferencesSelectorLoadedState<OpenFoodFactsLanguage> _ =>
              _buildLoadedState(context),
          };
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 20.0,
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildLoadedState(BuildContext context) {
    return ConsumerValueNotifierFilter<
      _LanguageSelectorProvider,
      PreferencesSelectorState<OpenFoodFactsLanguage>
    >(
      buildWhen:
          (
            PreferencesSelectorState<OpenFoodFactsLanguage>? previousValue,
            PreferencesSelectorState<OpenFoodFactsLanguage> currentValue,
          ) =>
              previousValue != null &&
              currentValue is! PreferencesSelectorEditingState &&
              (currentValue
                          as PreferencesSelectorLoadedState<
                            OpenFoodFactsLanguage
                          >)
                      .selectedItem !=
                  (previousValue
                          as PreferencesSelectorLoadedState<
                            OpenFoodFactsLanguage
                          >)
                      .selectedItem,
      builder: (_, PreferencesSelectorState<OpenFoodFactsLanguage> value, _) {
        final OpenFoodFactsLanguage? language =
            (value as PreferencesSelectorLoadedState<OpenFoodFactsLanguage>)
                .selectedItem;

        return PreferenceTile(
          leading: icons.Language(
            color: context.lightTheme()
                ? Theme.of(context).primaryColor
                : Colors.white,
          ),
          title: title,
          subtitle: Row(
            spacing: VERY_SMALL_SPACE,
            children: <Widget>[
              if (language != null)
                Text(_getCompleteName(language))
              else
                const Icon(Icons.public),
            ],
          ),
          onTap: () => _openLanguageSelector(context),
          trailing: const icons.Edit(size: 18.0),
        );
      },
    );
  }

  static String _getCompleteName(final OpenFoodFactsLanguage language) {
    final String nameInLanguage = Languages().getNameInLanguage(language);
    final String nameInEnglish = Languages().getNameInEnglish(language);
    return '$nameInLanguage ($nameInEnglish)';
  }

  Future<void> _openLanguageSelector(BuildContext context) async {
    final dynamic newLanguage = await Navigator.of(context, rootNavigator: true)
        .push(
          PageRouteBuilder<dynamic>(
            pageBuilder: (_, _, _) => _LanguageSelectorScreen(
              provider: context.read<_LanguageSelectorProvider>(),
            ),
            transitionsBuilder:
                (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  final Tween<Offset> tween = Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  );
                  final CurvedAnimation curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  );
                  final Animation<Offset> position = tween.animate(
                    curvedAnimation,
                  );

                  return SlideTransition(
                    position: position,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
          ),
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
    final ProductPreferences productPreferences = context
        .read<ProductPreferences>();
    await BackgroundTaskLanguageRefresh.addTask(context.read<LocalDatabase>());

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
  const _LanguageSelectorScreen({required this.provider});

  final _LanguageSelectorProvider provider;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothSelectorScreen<OpenFoodFactsLanguage>(
      provider: provider,
      title: appLocalizations.language_selector_title,
      itemBuilder:
          (
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
                      text: LanguageSelectorTile._getCompleteName(language),
                      filter: filter,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            );
          },
      itemsFilter:
          (
            List<OpenFoodFactsLanguage> list,
            OpenFoodFactsLanguage? selectedItem,
            OpenFoodFactsLanguage? selectedItemOverride,
            String filter,
          ) => _filterCountries(
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
          Languages()
              .getNameInLanguage(language)
              .toLowerCase()
              .contains(filter.toLowerCase()) ||
          Languages()
              .getNameInEnglish(language)
              .toLowerCase()
              .contains(filter.toLowerCase()),
    );
  }
}
