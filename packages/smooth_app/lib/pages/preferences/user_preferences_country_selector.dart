import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';

class UserPreferencesCountrySelector extends StatelessWidget {
  const UserPreferencesCountrySelector();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.country_chooser_label,
      ],
      builder: (_) => const UserPreferencesCountrySelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    return ListTile(
      title: Text(
        appLocalizations.country_chooser_label,
        style: themeData.textTheme.headlineMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: CountrySelector(
          textStyle: themeData.textTheme.bodyMedium,
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
