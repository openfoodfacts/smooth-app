import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/language_selector/language_selector.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';

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
    final ThemeData themeData = Theme.of(context);

    return ListTile(
      title: Text(
        appLocalizations.language_picker_label,
        style: themeData.textTheme.headlineMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: LanguageSelector(
          autoValidate: false,
          textStyle: themeData.textTheme.bodyMedium,
          icon: const Icon(Icons.edit),
          padding: const EdgeInsetsDirectional.only(
            start: SMALL_SPACE,
          ),
          loadingHeight: 40.0,
        ),
      ),
      minVerticalPadding: MEDIUM_SPACE,
    );
  }
}
