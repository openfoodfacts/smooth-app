import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_list_helper.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterAddToListButton extends StatefulWidget {
  const ProductFooterAddToListButton();

  @override
  State<ProductFooterAddToListButton> createState() =>
      _ProductFooterAddToListButtonState();
}

class _ProductFooterAddToListButtonState
    extends State<ProductFooterAddToListButton> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ChangeNotifierProvider<_ProductUserListsProvider>(
      create: (BuildContext context) => _ProductUserListsProvider(
        DaoProductList(context.read<LocalDatabase>()),
        context.read<Product>().barcode!,
      ),
      child: Consumer<_ProductUserListsProvider>(
        builder: (BuildContext context, _ProductUserListsProvider provider, _) {
          return ProductFooterButton(
            label: appLocalizations.user_list_button_add_product,
            vibrate: true,
            icon: provider.value == 0
                ? const icons.AddToList.symbol()
                : icons.AddToList(count: provider.value),
            onTap: () => _editList(context, context.read<Product>()),
          );
        },
      ),
    );
  }

  Future<bool?> _editList(BuildContext context, Product product) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    await showSmoothDraggableModalSheet(
      context: context,
      header: SmoothModalSheetHeader(
        prefix: const SmoothModalSheetHeaderPrefixIndicator(),
        title: appLocalizations.user_list_title,
        suffix: const SmoothModalSheetHeaderCloseButton(),
      ),
      bodyBuilder: (BuildContext context) =>
          AddProductToListContainer(barcode: product.barcode!),
    );

    if (context.mounted) {
      context.read<_ProductUserListsProvider>().reload();
    }

    return true;
  }
}

class _ProductUserListsProvider extends ValueNotifier<int> {
  _ProductUserListsProvider(this.dao, this.barcode) : super(0) {
    reload();
  }

  final DaoProductList dao;
  final String barcode;

  Future<void> reload() async {
    value = (await dao.getUserListsWithBarcodes(<String>[barcode])).length;
  }
}
