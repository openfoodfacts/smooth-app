import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/currency_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';

/// Currency selector within user preferences.
class UserPreferencesCurrencySelector extends StatelessWidget {
  const UserPreferencesCurrencySelector();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[_getLabel(appLocalizations)],
      builder: (_) => const UserPreferencesCurrencySelector(),
    );
  }

  static String _getLabel(final AppLocalizations appLocalizations) =>
      appLocalizations.currency_picker_label;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    return ListTile(
      title: Text(
        _getLabel(appLocalizations),
        style: themeData.textTheme.headlineMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: CurrencySelector(
          textStyle: themeData.textTheme.bodyMedium,
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
