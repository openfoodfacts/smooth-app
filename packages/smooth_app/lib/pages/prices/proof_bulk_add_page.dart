import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/price_currency_card.dart';
import 'package:smooth_app/pages/prices/price_date_card.dart';
import 'package:smooth_app/pages/prices/price_location_card.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_proof_card.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as app_icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_expandable_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/smooth_text.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// Single page that displays all the elements of bulk proof adding.
class ProofBulkAddPage extends StatefulWidget {
  const ProofBulkAddPage(
    this.model,
  );

  final PriceModel model;

  static Future<PriceModel?> toto({
    required final BuildContext context,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: true,
    )) {
      return null;
    }
    if (!context.mounted) {
      return null;
    }
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final List<OsmLocation> osmLocations =
        await DaoOsmLocation(localDatabase).getAll();
    if (!context.mounted) {
      return null;
    }

    final UserPreferences userPreferences = context.read<UserPreferences>();
    final Currency currency = CurrencySelectorHelper().getSelected(
      userPreferences.userCurrencyCode,
    );

    return PriceModel(
      proofType: ProofType.priceTag,
      locations: osmLocations,
      currency: currency,
    );
  }

  static Future<void> showPage({
    required final BuildContext context,
  }) async {
    final PriceModel? priceModel = await toto(context: context);
    if (priceModel == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProofBulkAddPage(priceModel),
      ),
    );
  }

  @override
  State<ProofBulkAddPage> createState() => _ProofBulkAddPageState();
}

class _ProofBulkAddPageState extends State<ProofBulkAddPage>
    with TraceableClientMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PriceModel>.value(
      value: widget.model,
      builder: (
        final BuildContext context,
        final Widget? child,
      ) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final PriceModel model = Provider.of<PriceModel>(context);
        return WillPopScope2(
          onWillPop: () async => (
            await _mayExitPage(
              saving: false,
              model: model,
            ),
            null
          ),
          child: Form(
            key: _formKey,
            child: SmoothScaffold(
              appBar: SmoothAppBar(
                centerTitle: false,
                leading: const SmoothBackButton(),
                title: Text(
                  appLocalizations.prices_bulk_proof_upload_title,
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () async => _doesAcceptWarning(justInfo: true),
                  ),
                ],
              ),
              backgroundColor: context.lightTheme()
                  ? context.extension<SmoothColorsThemeExtension>().primaryLight
                  : null,
              body: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(LARGE_SPACE),
                child: Column(
                  children: <Widget>[
                    const PriceDateCard(),
                    const SizedBox(height: LARGE_SPACE),
                    PriceLocationCard(
                      onLocationChanged: (
                        OsmLocation? oldLocation,
                        OsmLocation location,
                      ) =>
                          _updateCurrency(
                        oldLocation,
                        location,
                        model,
                      ),
                    ),
                    const SizedBox(height: LARGE_SPACE),
                    const PriceCurrencyCard(),
                    const SizedBox(height: LARGE_SPACE),
                    const PriceProofCard(
                      forcedProofType: ProofType.priceTag,
                      includeMyProofs: false,
                    ),
                    // so that the last items don't get hidden by the FAB
                    const SizedBox(height: MINIMUM_TOUCH_SIZE * 2),
                  ],
                ),
              ),
              floatingActionButton: SmoothExpandableFloatingActionButton(
                scrollController: _scrollController,
                onPressed: () async => _mayExitPage(
                  saving: true,
                  model: model,
                ),
                icon: const Icon(Icons.send),
                label: Text(
                  appLocalizations.prices_bulk_proof_upload_action,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateCurrency(
    OsmLocation? oldLocation,
    OsmLocation location,
    PriceModel model,
  ) async {
    if (location.countryCode != null) {
      final Currency? newCurrency =
          OpenFoodFactsCountry.fromOffTag(location.countryCode)?.currency;

      if (newCurrency != null && model.currency != newCurrency) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final SmoothColorsThemeExtension extension =
            context.extension<SmoothColorsThemeExtension>();

        final Currency? currency = await showSmoothAlertModalSheet<Currency?>(
          context: context,
          title: appLocalizations.prices_currency_change_proposal_title,
          message: TextWithBoldParts(
            text: appLocalizations.prices_currency_change_proposal_message(
                model.currency.name, newCurrency.name),
            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
  }

  Future<bool?> _doesAcceptWarning({required final bool justInfo}) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    const Color color = Color(0xFFB81D1D);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
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
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
      labels: <String>[
        appLocalizations.i_accept,
        appLocalizations.i_refuse,
      ],
      values: <bool>[
        true,
        false,
      ],
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
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  /// Returns true if the basic checks passed.
  Future<bool> _check(
    final BuildContext context,
    final PriceModel model,
  ) async {
    if (!_formKey.currentState!.validate()) {
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

  @override
  String get actionName => 'Opened bulk proof upload page';

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({
    required final bool saving,
    required PriceModel model,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!model.hasChanged && !saving) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(
        context,
        title: appLocalizations.prices_bulk_proof_upload_title,
      );
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
      if (!mounted) {
        return false;
      }
    }

    if (!await _check(context, model)) {
      return false;
    }
    if (!mounted) {
      return false;
    }

    final UserPreferences userPreferences = context.read<UserPreferences>();
    const String flagTag = UserPreferences.TAG_PRICE_PRIVACY_WARNING;
    final bool? already = userPreferences.getFlag(flagTag);
    if (already != true) {
      final bool? accepts = await _doesAcceptWarning(justInfo: false);
      if (accepts != true) {
        return false;
      }
      await userPreferences.setFlag(flagTag, true);
    }
    if (!mounted) {
      return true;
    }

    await model.addTask(context);

    if (saving) {
      model.clearProof();
    }

    return true;
  }
}
