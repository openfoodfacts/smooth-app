import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/services/smooth_services.dart';

class UserPreferencesRateUs extends StatelessWidget {
  const UserPreferencesRateUs();

  static UserPreferencesItem getUserPreferencesItem(
    final BuildContext context,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return UserPreferencesItemSimple(
      labels: <String>[
        appLocalizations.rate_app,
      ],
      builder: (_) => const UserPreferencesRateUs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return UserPreferenceListTile(
      title: appLocalizations.rate_app,
      leading: SizedBox(
        key: const Key('settings.rate_us'),
        height: DEFAULT_ICON_SIZE,
        width: DEFAULT_ICON_SIZE,
        child: Image.asset(_getImagePath()),
      ),
      showDivider: true,
      onTap: (BuildContext context) async {
        try {
          await ApplicationStore.openAppDetails();
        } on PlatformException {
          if (!context.mounted) {
            return;
          }

          final ThemeData themeData = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SmoothFloatingSnackbar(
              content: Text(
                appLocalizations.error_occurred,
                textAlign: TextAlign.center,
                style: TextStyle(color: themeData.colorScheme.surface),
              ),
              backgroundColor: themeData.colorScheme.onSurface,
            ),
          );
        }
      },
    );
  }

  String _getImagePath() {
    switch (GlobalVars.storeLabel) {
      case StoreLabel.FDroid:
        return 'assets/app/f-droid.png';
      case StoreLabel.AppleAppStore:
        return 'assets/app/app-store.png';
      default:
        return 'assets/app/playstore.png';
    }
  }
}
