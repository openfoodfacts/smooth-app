import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_language_refresh.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/query/product_query.dart';

class UserPreferencesLanguageSelector extends StatelessWidget {
  const UserPreferencesLanguageSelector();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.language_picker_label,
      ],
      builder: (_) => const UserPreferencesLanguageSelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return ListTile(
      title: Text(
        appLocalizations.language_picker_label,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: LanguageSelector(
          setLanguage: (final OpenFoodFactsLanguage? language) async {
            if (language == null) {
              return;
            }
            ProductQuery.setLanguage(
              context,
              userPreferences,
              languageCode: language.code,
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
          },
          selectedLanguages: <OpenFoodFactsLanguage>[
            ProductQuery.getLanguage(),
          ],
          icon: const Icon(Icons.edit),
          padding: const EdgeInsetsDirectional.only(
            start: SMALL_SPACE,
          ),
        ),
      ),
      minVerticalPadding: MEDIUM_SPACE,
    );
  }
}
