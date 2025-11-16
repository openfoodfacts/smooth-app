import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/prices_page_header.dart';
import 'package:smooth_app/pages/prices/product_prices_list.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

/// Page that displays the latest prices according to a model.
class PricesPage extends StatelessWidget {
  const PricesPage(this.model, {this.pricesResult});

  final GetPricesModel model;
  final GetPricesResult? pricesResult;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothScaffold2(
      backgroundColor: lightTheme ? extension.primaryLight : null,
      topBar: SmoothTopBar2(
        leadingAction: SmoothLeadingAction.back,
        backgroundColor: lightTheme
            ? extension.primaryBlack
            : extension.primaryUltraBlack,
        foregroundColor: lightTheme ? Colors.white : null,
        elevationColor: lightTheme ? Colors.black54 : Colors.white12,
        title: appLocalizations.prices_list_title,
        subTitle: model.title,
        elevationOnScroll: true,
      ),
      injectPaddingInBody: model.displayEachProduct,
      belowTopBar: !model.displayEachProduct,
      padding: EdgeInsetsDirectional.zero,
      floatingBottomBar: ConsumerFilter<UserPreferences>(
        buildWhen:
            (UserPreferences? previousValue, UserPreferences currentValue) =>
                previousValue?.shouldShowPricesFeedbackForm !=
                currentValue.shouldShowPricesFeedbackForm,
        builder:
            (
              final BuildContext context,
              final UserPreferences userPreferences,
              _,
            ) {
              if (!userPreferences.shouldShowPricesFeedbackForm) {
                return EMPTY_WIDGET;
              }

              return const _PricesFeedbackForm();
            },
      ),
      children: <Widget>[
        if (!model.displayEachProduct)
          PricesHeader(model, pricesResult: pricesResult),
        ProductPricesList(model, pricesResult: pricesResult),
        const SliverPadding(
          padding: EdgeInsetsDirectional.only(
            bottom: MEDIUM_SPACE + kBottomNavigationBarHeight,
          ),
        ),
      ],
    );
  }
}

class _PricesFeedbackForm extends StatelessWidget {
  const _PricesFeedbackForm();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension? themeExtension = Theme.of(
      context,
    ).extension<SmoothColorsThemeExtension>();

    final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      width: double.infinity,
      height: kBottomNavigationBarHeight + bottomPadding,
      child: Material(
        color: themeExtension!.primaryBlack,
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: InkWell(
            onTap: () async {
              LaunchUrlHelper.launchURL('https://forms.gle/Vmh9SR3HhPpjMnVF7');
              context
                  .read<UserPreferences>()
                  .markPricesFeedbackFormAsCompleted();
            },
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: bottomPadding),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: MEDIUM_SPACE,
                  vertical: SMALL_SPACE,
                ),
                child: Row(
                  children: <Widget>[
                    ExcludeSemantics(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeExtension.secondaryNormal,
                          shape: BoxShape.circle,
                        ),
                        child: const AspectRatio(
                          aspectRatio: 1.0,
                          child: Lab(color: Colors.white, size: 13.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: SMALL_SPACE),
                    Expanded(
                      child: AutoSizeText(
                        appLocalizations.prices_feedback_form,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: SMALL_SPACE),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context
                          .read<UserPreferences>()
                          .markPricesFeedbackFormAsCompleted(),
                      child: const AspectRatio(
                        aspectRatio: 1.0,
                        child: CloseButtonIcon(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
