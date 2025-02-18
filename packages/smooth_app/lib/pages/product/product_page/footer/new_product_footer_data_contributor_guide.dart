import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterContributorGuideButton extends StatelessWidget {
  const ProductFooterContributorGuideButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.product_footer_action_contributor_guide,
      semanticsLabel: appLocalizations.product_footer_action_contributor_guide,
      icon: const icons.Lifebuoy(),
      onTap: () => AppNavigator.of(context).push(
        AppRoutes.EXTERNAL('https://wiki.openfoodfacts.org/Data_fields'),
      ),
    );
  }
}
