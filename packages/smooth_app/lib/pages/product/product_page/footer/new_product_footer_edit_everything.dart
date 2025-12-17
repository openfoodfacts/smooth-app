import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterEditEverythingButton extends StatelessWidget {
  const ProductFooterEditEverythingButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.edit_product_form_item_edit_everything_title,
      icon: const icons.Shapes(),
      onTap: () => _editEverything(context, context.read<Product>()),
    );
  }

  Future<void> _editEverything(BuildContext context, Product product) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: true,
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.powerEditScreen,
      product,
    );

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SimpleInputPage.multiple(
          helpers: <AbstractSimpleInputPageHelper>[
            // Basic details
            SimpleInputPageProductNameHelper(),
            SimpleInputPageBrandsHelper(),
            SimpleInputPageQuantityHelper(),
            // Additional details
            SimpleInputPageWebsiteHelper(),
            // Existing power edit sections
            SimpleInputPageLabelHelper(),
            SimpleInputPageStoreHelper(),
            SimpleInputPageOriginHelper(),
            SimpleInputPageEmbCodeHelper(),
            SimpleInputPageCountryHelper(context.read<UserPreferences>()),
            SimpleInputPageCategoryHelper(),
          ],
          product: product,
        ),
      ),
    );
  }
}
