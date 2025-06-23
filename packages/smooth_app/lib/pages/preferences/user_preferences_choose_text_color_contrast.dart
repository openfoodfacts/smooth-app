import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/themes/color_schemes.dart';
import 'package:smooth_app/themes/contrast_provider.dart';

class UserPreferencesChooseTextColorContrast extends StatelessWidget {
  const UserPreferencesChooseTextColorContrast();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.text_contrast_mode,
        appLocalizations.contrast_high,
        appLocalizations.contrast_medium,
        appLocalizations.contrast_low,
      ],
      builder: (_) => const UserPreferencesChooseTextColorContrast(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextContrastProvider textContrastProvider =
        context.watch<TextContrastProvider>();

    return UserPreferencesMultipleChoicesItem<String>(
      title: appLocalizations.text_contrast_mode,
      values: const <String>[
        CONTRAST_HIGH,
        CONTRAST_MEDIUM,
        CONTRAST_LOW,
      ],
      labels: <String>[
        appLocalizations.contrast_high,
        appLocalizations.contrast_medium,
        appLocalizations.contrast_low,
      ],
      currentValue: textContrastProvider.currentContrastLevel,
      onChanged: (String? contrast) =>
          textContrastProvider.setContrast(contrast!),
    );
  }
}
