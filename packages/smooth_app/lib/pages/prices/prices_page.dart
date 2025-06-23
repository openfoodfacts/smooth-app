import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/product_prices_list.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the latest prices according to a model.
class PricesPage extends StatelessWidget {
  const PricesPage(
    this.model, {
    this.pricesResult,
  });

  final GetPricesModel model;
  final GetPricesResult? pricesResult;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          model.title,
          maxLines: model.subtitle == null ? 2 : 1,
        ),
        subTitle: model.subtitle == null ? null : Text(model.subtitle!),
        actions: <Widget>[
          Semantics(
            link: true,
            label: appLocalizations.prices_app_button,
            excludeSemantics: true,
            child: IconButton(
              tooltip: appLocalizations.prices_app_button,
              icon: const ExcludeSemantics(child: Icon(Icons.open_in_new)),
              onPressed: () async => LaunchUrlHelper.launchURL(
                model.uri.toString(),
              ),
            ),
          ),
        ],
      ),
      body: ProductPricesList(
        model,
        pricesResult: pricesResult,
      ),
      floatingActionButton: model.addButton == null
          ? null
          : FloatingActionButton.extended(
              onPressed: model.addButton,
              label: Text(appLocalizations.prices_add_a_price),
              icon: const Icon(Icons.add),
            ),
      bottomNavigationBar: ConsumerFilter<UserPreferences>(
        buildWhen:
            (UserPreferences? previousValue, UserPreferences currentValue) =>
                previousValue?.shouldShowPricesFeedbackForm !=
                currentValue.shouldShowPricesFeedbackForm,
        builder: (
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
    );
  }
}

class _PricesFeedbackForm extends StatelessWidget {
  const _PricesFeedbackForm();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension? themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>();

    final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Ink(
      width: double.infinity,
      height: kBottomNavigationBarHeight + bottomPadding,
      color: themeExtension!.primaryBlack,
      padding: EdgeInsetsDirectional.only(bottom: bottomPadding),
      child: IconTheme(
        data: const IconThemeData(color: Colors.white),
        child: InkWell(
          onTap: () async {
            LaunchUrlHelper.launchURL(
              'https://forms.gle/Vmh9SR3HhPpjMnVF7',
            );
            context.read<UserPreferences>().markPricesFeedbackFormAsCompleted();
          },
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
                      child: Lab(
                        color: Colors.white,
                        size: 13.0,
                      ),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
