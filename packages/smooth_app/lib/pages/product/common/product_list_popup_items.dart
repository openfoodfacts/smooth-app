import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/temp_product_list_share_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Popup menu item entries for the product list page.
enum ProductListPopupMenuEntry {
  share,
  openInBrowser,
  rename,
  clear,
  export,
  import,
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

  /// Is-it a destructive action?
  bool isDestructive() => false;

  /// Action of the popup menu item.
  ///
  /// Returns a different product list if there are changes, else null.
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  });

  /// Returns the popup menu item.
  SmoothPopupMenuItem<ProductListPopupItem> getMenuItem(
    final AppLocalizations appLocalizations,
  ) =>
      SmoothPopupMenuItem<ProductListPopupItem>(
        value: this,
        icon: getIconData(),
        label: getTitle(appLocalizations),
      );

  /// Returns the first possible URL/server that contains at least one product.
  @protected
  Future<Uri?> _getFirstUrl({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
  }) async {
    final List<String> products = productList.getList();
    final Map<ProductType, List<String>> productTypes =
        await DaoProduct(localDatabase).getProductTypes(products);
    for (final MapEntry<ProductType, List<String>> entry
        in productTypes.entries) {
      return shareProductList(entry.value, entry.key);
    }
    return null;
  }
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
  bool isDestructive() => true;

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

/// Popup menu item for the product list page: export list.
class ProductListPopupExport extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      appLocalizations.product_list_export;

  @override
  IconData getIconData() => Icons.download;

  @override
  ProductListPopupMenuEntry getEntry() => ProductListPopupMenuEntry.export;

  @override
  bool isDestructive() => false;

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    final String listName = ProductQueryPageHelper.getProductListLabel(
      productList,
      AppLocalizations.of(context),
    );
    final String fileName =
        "${listName.replaceAll(' ', '-').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.csv";
    final StringBuffer csv = StringBuffer('Barcode,Name,Brand\n');

    for (final String barcode in productList.barcodes) {
      final Product? product = await DaoProduct(localDatabase).get(barcode);
      if (product != null) {
        final String name = (product.productName ?? '').replaceAll(';', '');
        final String brand = (product.brands ?? '').replaceAll(';', '');
        csv.write('"$barcode";"$name";"$brand"\n');
      }
    }

    unawaited(
      Share.shareXFiles(
        <XFile>[
          XFile.fromData(
            utf8.encode(csv.toString()),
            name: '$fileName.csv',
            mimeType: 'text/csv',
          ),
        ],
        fileNameOverrides: <String>['$fileName.csv'],
      ),
    );

    return null;
  }
}

/// Popup menu item for the product list page: import list.
class ProductListPopupImport extends ProductListPopupItem {
  @override
  String getTitle(final AppLocalizations appLocalizations) =>
      'Import'; //appLocalizations.product_list_import;

  @override
  IconData getIconData() => Icons.upload;

  @override
  ProductListPopupMenuEntry getEntry() => ProductListPopupMenuEntry.import;

  @override
  bool isDestructive() => false;

  @override
  Future<ProductList?> doSomething({
    required final ProductList productList,
    required final LocalDatabase localDatabase,
    required final BuildContext context,
  }) async {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['csv'],
    ).then((final FilePickerResult? result) {
      if (result == null) {
        return;
      }
      final File file = File(result.files.single.path!);
      final String content = file.readAsStringSync();
      final List<String> lines = content.split('\n');
      final List<String> barcodes = <String>[];
      for (final String line in lines) {
        final List<String> parts = line.split(';');
        if (parts.length < 3) {
          continue;
        }
        final String barcode = parts[0].replaceAll('"', '');
        barcodes.add(barcode);
      }
      DaoProductList(localDatabase).bulkSet(
        productList,
        barcodes,
        include: true,
      );
    });

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
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String? url = (await _getFirstUrl(
      productList: productList,
      localDatabase: localDatabase,
    ))
        ?.toString();
    if (url != null) {
      AnalyticsHelper.trackEvent(AnalyticsEvent.shareList);
      unawaited(
        Share.share(
          appLocalizations.share_product_list_text(url),
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    }
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
    final Uri? firstUrl = await _getFirstUrl(
      productList: productList,
      localDatabase: localDatabase,
    );
    if (firstUrl != null) {
      AnalyticsHelper.trackEvent(AnalyticsEvent.openListWeb);
      unawaited(launchUrl(firstUrl));
    }
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
