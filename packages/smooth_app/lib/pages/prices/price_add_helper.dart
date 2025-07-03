import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/resources/app_icons.dart' as app_icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Helper around price/proof adding pages.
class PriceAddHelper {
  const PriceAddHelper(this.context);

  final BuildContext context;

  Future<List<OsmLocation>> getLocations() async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    return DaoOsmLocation(localDatabase).getAll();
  }

  Currency getCurrency() {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    return CurrencySelectorHelper().getSelected(
      userPreferences.userCurrencyCode,
    );
  }

  /// Returns true if the basic checks passed.
  Future<bool> check(
    final PriceModel model,
    final GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    String? error;
    try {
      error = model.checkParameters(context);
    } catch (e) {
      error = e.toString();
    }
    if (error != null) {
      if (!context.mounted) {
        return false;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothSimpleErrorAlertDialog(
          title: AppLocalizations.of(context).prices_add_validation_error,
          message: error!,
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> acceptsWarning() async {
    final UserPreferences userPreferences = context.read<UserPreferences>();
    const String flagTag = UserPreferences.TAG_PRICE_PRIVACY_WARNING;
    final bool? already = userPreferences.getFlag(flagTag);
    if (already != true) {
      final bool? accepts = await doesAcceptWarning(justInfo: false);
      if (accepts != true) {
        return false;
      }
      await userPreferences.setFlag(flagTag, true);
    }
    return true;
  }

  Future<void> updateCurrency(
    OsmLocation? oldLocation,
    OsmLocation location,
    PriceModel model,
  ) async {
    if (location.countryCode == null) {
      return;
    }
    final Currency? newCurrency = OpenFoodFactsCountry.fromOffTag(
      location.countryCode,
    )?.currency;

    if (newCurrency != null && model.currency != newCurrency) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      final SmoothColorsThemeExtension extension = context
          .extension<SmoothColorsThemeExtension>();

      final Currency? currency = await showSmoothAlertModalSheet<Currency?>(
        context: context,
        title: appLocalizations.prices_currency_change_proposal_title,
        message: TextWithBoldParts(
          text: appLocalizations.prices_currency_change_proposal_message(
            model.currency.name,
            newCurrency.name,
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        actionLabels: <String>[
          appLocalizations.prices_currency_change_proposal_action_approve(
            newCurrency.name,
          ),
          appLocalizations.prices_currency_change_proposal_action_cancel(
            model.currency.name,
          ),
        ],
        actionIcons: <Widget>[
          Icon(Icons.check_circle_rounded, color: extension.success),
          Icon(Icons.cancel_rounded, color: extension.error),
        ],
        actionValues: <Currency?>[newCurrency, null],
      );

      if (currency != null) {
        model.currency = currency;
      }
    }
  }

  Future<bool?> doesAcceptWarning({required final bool justInfo}) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    const Color color = Color(0xFFB81D1D);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    return showSmoothListOfChoicesModalSheet<bool>(
      safeArea: true,
      context: context,
      headerBackgroundColor: color,
      header: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextWithBoldParts(
              text: appLocalizations.prices_privacy_warning_main_message,
              textStyle: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            _buildBulletPoint(
              appLocalizations.prices_privacy_warning_message_bullet_1,
              context,
            ),
            const SizedBox(height: MEDIUM_SPACE),
            _buildBulletPoint(
              appLocalizations.prices_privacy_warning_message_bullet_2,
              context,
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Text(
              appLocalizations.prices_privacy_warning_sub_message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      labels: <String>[appLocalizations.i_accept, appLocalizations.i_refuse],
      values: <bool>[true, false],
      prefixIcons: <Widget>[
        Icon(Icons.check_circle_rounded, color: extension.success),
        Icon(Icons.cancel_rounded, color: extension.error),
      ],
      title: appLocalizations.prices_privacy_warning_title,
    );
  }

  Widget _buildBulletPoint(String text, BuildContext context) {
    const double defaultIconSize = 7.0;
    const double radius = 10.0;
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(width: MEDIUM_SPACE),
        CircleAvatar(
          radius: radius,
          backgroundColor: extension.greyMedium,
          child: const app_icons.Arrow.right(
            color: Colors.white,
            size: defaultIconSize,
          ),
        ),
        const SizedBox(width: SMALL_SPACE),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
