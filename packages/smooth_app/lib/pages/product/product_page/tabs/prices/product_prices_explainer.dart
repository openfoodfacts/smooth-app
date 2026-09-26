import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_explanation_banner.dart';

class ProductPricesExplanationBanner extends StatelessWidget {
  const ProductPricesExplanationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductPageExplanationBanner(
      title: appLocalizations.prices_explanation_card_title,
      text: <String>[appLocalizations.prices_explanation_card_line1],
      shouldShowBanner: (UserPreferences prefs) =>
          prefs.shouldShowPricesExplanationCard,
      hideBanner: (UserPreferences prefs) => prefs.hidePricesExplanationCard(),
      onTap: () => AppNavigator.of(context).push(AppRoutes.GUIDE_OPEN_PRICES),
    );
  }
}
