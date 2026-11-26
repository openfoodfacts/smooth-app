import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/color_extension.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/country_selector/country.dart';
import 'package:smooth_app/pages/preferences/country_selector/currency_change_summary.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

// TODO(g123k): move this to a dedicated Provider
/// Saves the currency of [country], after asking the user when it differs from
/// the current one. Only an explicit approval of the sheet changes it.
Future<void> changeCurrencyIfRelevant(
  BuildContext context,
  Country country, {
  required bool forceCurrencyChange,
}) async {
  // The selector route has just been popped: its context may be gone.
  if (!context.mounted) {
    return;
  }

  final UserPreferences userPreferences = context.read<UserPreferences>();
  final String? newCurrencyCode = country.currency?.name;

  if (newCurrencyCode == null) {
    return;
  }

  bool? changeCurrency;
  final String? currentCurrencyCode = userPreferences.userCurrencyCode;

  if (currentCurrencyCode == null || forceCurrencyChange) {
    changeCurrency = true;
  } else if (currentCurrencyCode != newCurrencyCode) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool lightTheme = context.lightTheme(listen: false);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final TextStyle? bodyStyle = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(fontWeight: FontWeight.w500);

    changeCurrency = await showSmoothAlertModalSheet<bool>(
      context: context,
      title: appLocalizations.currency_change_sheet_title,
      message: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextWithBoldParts(
            text: appLocalizations.currency_change_sheet_country(
              country.localizedName,
            ),
            textStyle: bodyStyle,
          ),
          const SizedBox(height: SMALL_SPACE),
          Text(
            appLocalizations.currency_change_sheet_question,
            style: bodyStyle,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: lightTheme
                    ? extension.primaryLight
                    : extension.primaryDark.darken(0.1),
                borderRadius: ROUNDED_BORDER_RADIUS,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: MEDIUM_SPACE,
                ),
                child: CurrencyChangeSummary(
                  currency: currentCurrencyCode,
                  newCurrency: newCurrencyCode,
                ),
              ),
            ),
          ),
        ],
      ),
      actionLabels: <String>[
        appLocalizations.currency_change_sheet_action_approve(newCurrencyCode),
        appLocalizations.currency_change_sheet_action_keep(currentCurrencyCode),
      ],
      actionIcons: <Widget>[
        Icon(Icons.check_circle_rounded, color: extension.success),
        Icon(Icons.cancel_rounded, color: extension.error),
      ],
      actionValues: const <bool>[true, false],
      // Transparent: the body of the sheet shows through, like behind the actions.
      messageBackgroundColor: lightTheme ? Colors.white : Colors.transparent,
    );
  }

  if (changeCurrency == true) {
    await userPreferences.setUserCurrencyCode(newCurrencyCode);
  }
}
