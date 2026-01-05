import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_in/logged_in_app_bar_header.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class LoggedOutAppBarTitle extends StatelessWidget {
  const LoggedOutAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PROFILE_PICTURE_SIZE),
      child: Row(
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          const UserProfilePicture(),
          Expanded(
            child: Text(
              appLocalizations.logged_out,
              style: TextStyle(
                color: themeExtension.secondaryNormal,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
