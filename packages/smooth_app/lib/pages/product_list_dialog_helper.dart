import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

class ProductListDialogHelper {
  static const String _TRANSLATE_ME_WANT_TO_DELETE =
      'Do you want to delete this product list?';
  static const String _TRANSLATE_ME_NEW_LIST = 'New list';
  static const String _TRANSLATE_ME_RENAME_LIST = 'Rename list';
  static const String _TRANSLATE_ME_HINT = 'My custom list';
  static const String _TRANSLATE_ME_EMPTY = 'Please enter some text';
  static const String _TRANSLATE_ME_ALREADY_OTHER =
      'There\'s already a list with that name';
  static const String _TRANSLATE_ME_ALREADY_SAME = 'That\'s the same name!';
  static const String _TRANSLATE_ME_CANCEL = 'Cancel';

  static Future<bool> openDelete(
    final BuildContext context,
    final DaoProductList daoProductList,
    final ProductList productList,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          close: false,
          body: const Text(_TRANSLATE_ME_WANT_TO_DELETE),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: AppLocalizations.of(context).no,
              important: false,
              onPressed: () => Navigator.pop(context, false),
            ),
            SmoothSimpleButton(
              text: AppLocalizations.of(context).yes,
              important: true,
              onPressed: () async {
                await daoProductList.delete(productList);
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      );

  static Future<bool> openNew(
    final BuildContext context,
    final DaoProductList daoProductList,
    final List<ProductList> list,
  ) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    ProductList newProductList;
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        title: _TRANSLATE_ME_NEW_LIST,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: _TRANSLATE_ME_HINT,
                ),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return _TRANSLATE_ME_EMPTY;
                  }
                  if (list == null) {
                    return null;
                  }
                  newProductList = ProductList(
                    listType: ProductList.LIST_TYPE_USER_DEFINED,
                    parameters: value,
                  );
                  for (final ProductList productList in list) {
                    if (productList.lousyKey == newProductList.lousyKey) {
                      return _TRANSLATE_ME_ALREADY_OTHER;
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: _TRANSLATE_ME_CANCEL,
            onPressed: () => Navigator.pop(context, false),
            important: false,
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).okay,
            onPressed: () async {
              if (!formKey.currentState.validate()) {
                return;
              }
              if (await daoProductList.get(newProductList)) {
                // TODO(monsieurtanuki): unexpected, but do something!
                return;
              }
              await daoProductList.put(newProductList);
              Navigator.pop(context, true);
            },
            important: true,
          ),
        ],
      ),
    );
  }

  static Future<ProductList> openRename(
    final BuildContext context,
    final DaoProductList daoProductList,
    final ProductList productList,
  ) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final List<ProductList> list =
        await daoProductList.getAll(withStats: false);
    ProductList newProductList;
    return showDialog<ProductList>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        close: false,
        title: _TRANSLATE_ME_RENAME_LIST,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: productList.parameters,
                decoration: const InputDecoration(
                  hintText: _TRANSLATE_ME_HINT,
                ),
                validator: (final String value) {
                  if (value.isEmpty) {
                    return _TRANSLATE_ME_EMPTY;
                  }
                  newProductList = ProductList(
                    listType: ProductList.LIST_TYPE_USER_DEFINED,
                    parameters: value,
                  );
                  for (final ProductList item in list) {
                    if (item.lousyKey == newProductList.lousyKey) {
                      if (item.lousyKey == productList.lousyKey) {
                        return _TRANSLATE_ME_ALREADY_SAME;
                      }
                      return _TRANSLATE_ME_ALREADY_OTHER;
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: _TRANSLATE_ME_CANCEL,
            onPressed: () => Navigator.pop(context, null),
            important: false,
          ),
          SmoothSimpleButton(
            text: AppLocalizations.of(context).okay,
            onPressed: () async {
              if (!formKey.currentState.validate()) {
                return;
              }
              if (!await daoProductList.rename(
                  productList, newProductList.parameters)) {
                // TODO(monsieurtanuki): unexpected, but do something!
                return;
              }
              await daoProductList.get(newProductList);
              Navigator.pop(context, newProductList);
            },
            important: true,
          ),
        ],
      ),
    );
  }
}
