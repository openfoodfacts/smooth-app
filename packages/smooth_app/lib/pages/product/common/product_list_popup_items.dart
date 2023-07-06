import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/temp_product_list_share_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:url_launcher/url_launcher.dart';

/// Popup menu items for the product list page.
abstract class ProductListPopupItem {
  /// Title of the popup menu item.
  @protected
  String getTitle(final AppLocalizations appLocalizations);

  /// Action of the popup menu item.
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
        child: Text(getTitle(appLocalizations)),
      );
}

/// Popup menu item for the product list page: clear list.
class ProductListPopupClear extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.user_list_popup_clear;

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
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final ProductList? renamedProductList =
        await ProductListUserDialogHelper(daoProductList)
            .showRenameUserListDialog(context, productList);
    if (renamedProductList == null) {
      return null;
    }
    return renamedProductList;
  }
}

/// Popup menu item for the product list page: share list.
class ProductListPopupShare extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.share;

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

/// Popup menu item for the product list page: switch to another list.
class ProductListPopupList extends ProductListPopupItem {
  ProductListPopupList(this.newProductList);

  final ProductList newProductList;

  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      ProductQueryPageHelper.getProductListLabel(
        newProductList,
        appLocalizations,
      );

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    await DaoProductList(localDatabase).get(newProductList);
    return newProductList;
  }
}
