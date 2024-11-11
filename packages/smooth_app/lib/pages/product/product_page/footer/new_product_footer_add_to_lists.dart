import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/pages/product/product_list_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterAddToListButton extends StatelessWidget {
  const ProductFooterAddToListButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.user_list_button_add_product,
      vibrate: true,
      icon: const icons.AddToList(),
      onTap: () => _editList(context, context.read<Product>()),
    );
  }

  Future<bool?> _editList(BuildContext context, Product product) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    showSmoothDraggableModalSheet(
      context: context,
      header: SmoothModalSheetHeader(
        prefix: const SmoothModalSheetHeaderPrefixIndicator(),
        title: appLocalizations.user_list_title,
        suffix: const SmoothModalSheetHeaderCloseButton(),
      ),
      bodyBuilder: (BuildContext context) => AddProductToListContainer(
        barcode: product.barcode!,
      ),
    );

    return true;
  }
}
