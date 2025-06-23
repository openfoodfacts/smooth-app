import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterAddPropertyButton extends StatelessWidget {
  const ProductFooterAddPropertyButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.add_tag,
      icon: const icons.AddProperty.alt(),
      onTap: () => _openFolksonomyPage(context, context.read<Product>()),
    );
  }

  Future<void> _openFolksonomyPage(
    BuildContext context,
    Product product,
  ) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: true,
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    final FolksonomyProvider provider = FolksonomyProvider(product.barcode!);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            FolksonomyPage(product: product, provider: provider),
      ),
    );

    if (context.mounted) {
      await provider.fetchProductTags();
    }
  }
}
