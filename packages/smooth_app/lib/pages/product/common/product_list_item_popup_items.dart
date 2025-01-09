import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/compare_products3_page.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';

/// Popup menu item entries for the product list page, for selected items.
enum ProductListItemPopupMenuEntry {
  compareSideBySide,
  rank,
  delete,
}

/// Popup menu items for the product list page, for selected items.
abstract class ProductListItemPopupItem {
  /// Title of the popup menu item.
  String getTitle(final AppLocalizations appLocalizations);

  /// IconData of the popup menu item.
  IconData getIconData();

  /// Is-it a destructive action?
  bool isDestructive() => false;

  /// Action of the popup menu item.
  ///
  /// Returns true if the caller must refresh (setState) (e.g. after deleting).
  Future<bool> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
    required final Set<String> selectedBarcodes,
  });

  /// Returns the popup menu item.
  SmoothPopupMenuItem<ProductListItemPopupItem> getMenuItem(
    final AppLocalizations appLocalizations,
    final bool enabled,
  ) =>
      SmoothPopupMenuItem<ProductListItemPopupItem>(
        value: this,
        icon: getIconData(),
        label: getTitle(appLocalizations),
        enabled: enabled,
      );
}

/// Popup menu item for the product list page: compare side by side selected items.
class ProductListItemPopupSideBySide extends ProductListItemPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      'Compare side by side';

  @override
  IconData getIconData() => Icons.difference_outlined;

  @override
  Future<bool> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
    required final Set<String> selectedBarcodes,
  }) async {
    final OrderedNutrientsCache? cache =
        await OrderedNutrientsCache.getCache(context);
    if (context.mounted) {
      if (cache == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).nutrition_cache_loading_error,
            ),
          ),
        );
        return false;
      }
      final DaoProduct daoProduct = DaoProduct(localDatabase);
      final List<Product> list = <Product>[];
      for (final String barcode in selectedBarcodes) {
        list.add((await daoProduct.get(barcode))!);
      }
      if (context.mounted) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => CompareProducts3Page(
              products: list,
              orderedNutrientsCache: cache,
            ),
          ),
        );
      }
    }
    return false;
  }
}

/// Popup menu item for the product list page: rank selected items.
class ProductListItemPopupRank extends ProductListItemPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.compare_products_mode;

  @override
  IconData getIconData() => Icons.compare_arrows;

  @override
  Future<bool> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
    required final Set<String> selectedBarcodes,
  }) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PersonalizedRankingPage(
          barcodes: selectedBarcodes.toList(),
          title: AppLocalizations.of(context).product_list_your_ranking,
        ),
      ),
    );
    return false;
  }
}

/// Popup menu item for the product list page: delete selected items.
class ProductListItemPopupDelete extends ProductListItemPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.delete_products_mode;

  @override
  IconData getIconData() => Icons.delete;

  @override
  bool isDestructive() => true;

  @override
  Future<bool> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
    required final Set<String> selectedBarcodes,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final bool? letsDoIt = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Container(
          padding: const EdgeInsetsDirectional.only(start: SMALL_SPACE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(appLocalizations.alert_clear_selected_user_list),
              const SizedBox(height: SMALL_SPACE),
              Text(appLocalizations.confirm_clear_selected_user_list),
            ],
          ),
        ),
        positiveAction: SmoothActionButton(
          onPressed: () async => Navigator.of(context).pop(true),
          text: appLocalizations.yes,
        ),
        negativeAction: SmoothActionButton(
          onPressed: () => Navigator.of(context).pop(false),
          text: appLocalizations.no,
        ),
      ),
    );
    if (letsDoIt != true) {
      return false;
    }
    await daoProductList.bulkSet(
      productList,
      selectedBarcodes.toList(growable: false),
      include: false,
    );
    await daoProductList.get(productList);
    selectedBarcodes.clear();
    return true;
  }
}

/// Popup menu item for the product list page: select all items.
class ProductListItemPopupSelectAll extends ProductListItemPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.select_all_products_mode;

  @override
  IconData getIconData() => Icons.check_box;

  @override
  Future<bool> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
    required final Set<String> selectedBarcodes,
  }) async {
    selectedBarcodes.addAll(productList.barcodes);
    return true;
  }
}

/// Popup menu item for the product list page: unselect all items.
class ProductListItemPopupUnselectAll extends ProductListItemPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.select_none_products_mode;

  @override
  IconData getIconData() => Icons.check_box_outline_blank;

  @override
  Future<bool> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
    required final Set<String> selectedBarcodes,
  }) async {
    selectedBarcodes.clear();
    return true;
  }
}
