import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/temp_product_list_share_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:url_launcher/url_launcher.dart';

/// Popup menu item entries for the product list page.
enum ProductListPopupMenuEntry {
  share,
  openInBrowser,
  rename,
  clear,
  delete,
}

/// Popup menu items for the product list page.
abstract class ProductListPopupItem {
  /// Title of the popup menu item.
  String getTitle(final AppLocalizations appLocalizations);

  /// IconData of the popup menu item.
  IconData getIconData();

  /// Popup menu entry of the popup menu item.
  ProductListPopupMenuEntry getEntry();

  /// Action of the popup menu item.
  ///
  /// Returns a different product list if there are changes, else null.
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  });

  /// Returns the popup menu item.
  PopupMenuItem<ProductListPopupItem> getMenuItem(
    final AppLocalizations appLocalizations,
  ) =>
      PopupMenuItem<ProductListPopupItem>(
        value: this,
        child: ListTile(
          leading: Icon(getIconData()),
          title: Text(getTitle(appLocalizations)),
        ),
      );
}

/// Popup menu item for the product list page: clear list.
class ProductListPopupClear extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.clear_long;

  @override
  IconData getIconData() => Icons.delete_sweep;

  @override
  ProductListPopupMenuEntry getEntry() => ProductListPopupMenuEntry.clear;

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        title: getTitle(appLocalizations),
        body: Text(
          productList.listType == ProductListType.USER
              ? appLocalizations.confirm_clear_user_list(productList.parameters)
              : appLocalizations.confirm_clear,
        ),
        positiveAction: SmoothActionButton(
          onPressed: () => Navigator.of(context).pop(true),
          text: appLocalizations.yes,
        ),
        negativeAction: SmoothActionButton(
          onPressed: () => Navigator.of(context).pop(),
          text: appLocalizations.no,
        ),
      ),
    );
    if (ok == true) {
      await daoProductList.clear(productList);
      await daoProductList.get(productList);
      return productList;
    }
    return null;
  }
}

/// Popup menu item for the product list page: rename list.
class ProductListPopupRename extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.user_list_popup_rename;

  @override
  IconData getIconData() => Icons.edit;

  @override
  ProductListPopupMenuEntry getEntry() => ProductListPopupMenuEntry.rename;

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async =>
      ProductListUserDialogHelper(DaoProductList(localDatabase))
          .showRenameUserListDialog(context, productList);
}

/// Popup menu item for the product list page: share list.
class ProductListPopupShare extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.share;

  @override
  IconData getIconData() => Icons.share;

  @override
  ProductListPopupMenuEntry getEntry() => ProductListPopupMenuEntry.share;

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> products = productList.getList();
    final String url = shareProductList(products).toString();

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    AnalyticsHelper.trackEvent(AnalyticsEvent.shareList);
    Share.share(
      appLocalizations.share_product_list_text(url),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    return null;
  }
}

/// Popup menu item for the product list page: open list in web.
class ProductListPopupOpenInWeb extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.label_web;

  @override
  IconData getIconData() => Icons.public;

  @override
  ProductListPopupMenuEntry getEntry() =>
      ProductListPopupMenuEntry.openInBrowser;

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    final List<String> products = productList.getList();
    AnalyticsHelper.trackEvent(AnalyticsEvent.openListWeb);
    await launchUrl(shareProductList(products));
    return null;
  }
}

/// Popup menu item for the product list page: delete.
class ProductListPopupDelete extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.action_delete_list;

  @override
  IconData getIconData() => Icons.delete;

  @override
  ProductListPopupMenuEntry getEntry() => ProductListPopupMenuEntry.delete;

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    final bool deleted =
        await ProductListUserDialogHelper(DaoProductList(localDatabase))
            .showDeleteUserListDialog(context, productList);
    return deleted ? null : productList;
  }
}
