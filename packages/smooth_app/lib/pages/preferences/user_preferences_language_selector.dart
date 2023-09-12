import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/query/product_query.dart';

class UserPreferencesLanguageSelector extends StatelessWidget {
  const UserPreferencesLanguageSelector();

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
            if (language != null) {
              ProductQuery.setLanguage(
                context,
                userPreferences,
                languageCode: language.code,
              );
            }
          },
          selectedLanguages: <OpenFoodFactsLanguage>[
            ProductQuery.getLanguage(),
          ],
          icon: Icons.edit,
          padding: const EdgeInsetsDirectional.only(
            start: SMALL_SPACE,
          ),
        ),
      ),
      minVerticalPadding: MEDIUM_SPACE,
    );
  }
}
