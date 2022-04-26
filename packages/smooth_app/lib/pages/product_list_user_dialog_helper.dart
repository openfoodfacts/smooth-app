import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

/// Dialog helper class for user product list.
class ProductListUserDialogHelper {
  ProductListUserDialogHelper(this.daoProductList);

  final DaoProductList daoProductList;

  /// Shows a "create list" dialog; returns the new [ProductList] if relevant.
  Future<ProductList?> showCreateUserListDialog(
    final BuildContext context,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final TextEditingController _textEditingController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final String? title = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: Text(appLocalizations.user_list_dialog_new_title),
        content: Form(
          key: _formKey,
          child: SmoothTextFormField(
            type: TextFieldTypes.PLAIN_TEXT,
            controller: _textEditingController,
            hintText: appLocalizations.user_list_name_hint,
            textInputAction: TextInputAction.done,
            validator: (String? value) {
              final List<String> lists = daoProductList.getUserLists();
              if (value == null || value.isEmpty) {
                return appLocalizations.user_list_name_error_empty;
              }
              if (lists.contains(value)) {
                return appLocalizations.user_list_name_error_already;
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              Navigator.pop(context, _textEditingController.text);
            },
            child: Text(appLocalizations.okay),
          ),
        ],
      ),
    );
    if (title == null) {
      return null;
    }
    final ProductList productList = ProductList.user(title);
    await daoProductList.put(productList);
    return productList;
  }

  /// Shows all user lists with "contains [barcode]?" checkboxes.
  Future<bool> showUserListsWithBarcodeDialog(
    final BuildContext context,
    final Product product,
  ) async {
    final String barcode = product.barcode!;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<String> all = daoProductList.getUserLists();
    final List<String> withBarcode =
        daoProductList.getUserLists(withBarcode: barcode);
    final Set<String> newWithBarcode = <String>{};
    newWithBarcode.addAll(withBarcode);
    bool addedLists = false;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => StatefulBuilder(
        builder:
            (BuildContext context, void Function(VoidCallback fn) setState) =>
                AlertDialog(
          title: Text(getProductName(product, appLocalizations)),
          content: all.isEmpty
              ? Container()
              : SizedBox(
                  // TODO(monsieurtanuki): proper sizes
                  width: 300,
                  height: 400,
                  child: StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(VoidCallback fn) setState) {
                      final List<Widget> children = <Widget>[];
                      for (final String name in all) {
                        children.add(
                          ListTile(
                            leading: Icon(
                              newWithBarcode.contains(name)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                            ),
                            title: Text(name),
                            onTap: () => setState(
                              () => newWithBarcode.contains(name)
                                  ? newWithBarcode.remove(name)
                                  : newWithBarcode.add(name),
                            ),
                          ),
                        );
                      }
                      return ListView(children: children);
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appLocalizations.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final ProductList? productList =
                    await showCreateUserListDialog(context);
                if (productList != null) {
                  all.clear();
                  all.addAll(daoProductList.getUserLists());
                  setState(() => addedLists = true);
                }
              },
              child: Text(appLocalizations.user_list_button_new),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(appLocalizations.okay),
            ),
          ],
        ),
      ),
    );
    if (addedLists == false && result != true) {
      return false;
    }
    final Set<String> possibleChanges = <String>{};
    possibleChanges.addAll(withBarcode);
    possibleChanges.addAll(newWithBarcode);
    for (final String name in possibleChanges) {
      if (withBarcode.contains(name) && newWithBarcode.contains(name)) {
        continue;
      }
      if ((!withBarcode.contains(name)) && (!newWithBarcode.contains(name))) {
        continue;
      }
      final ProductList productList = ProductList.user(name);
      await daoProductList.set(
          productList, barcode, newWithBarcode.contains(name));
    }
    return true;
  }

  /// Shows a "rename list" dialog; returns renamed [ProductList] if relevant.
  Future<ProductList?> showRenameUserListDialog(
    final BuildContext context,
    final ProductList initialProductList,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final TextEditingController _textEditingController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final String initialName = initialProductList.parameters;
    _textEditingController.text = initialName;
    final String? newName = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: Text(appLocalizations.user_list_dialog_rename_title),
        content: Form(
          key: _formKey,
          child: SmoothTextFormField(
            type: TextFieldTypes.PLAIN_TEXT,
            controller: _textEditingController,
            hintText: appLocalizations.user_list_name_hint,
            textInputAction: TextInputAction.done,
            validator: (String? value) {
              final List<String> lists = daoProductList.getUserLists();
              if (value == null || value.isEmpty) {
                return appLocalizations.user_list_name_error_empty;
              }
              if (lists.contains(value)) {
                if (value != initialName) {
                  return appLocalizations.user_list_name_error_already;
                }
                return appLocalizations.user_list_name_error_same;
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              Navigator.pop(context, _textEditingController.text);
            },
            child: Text(appLocalizations.okay),
          ),
        ],
      ),
    );
    if (newName == null) {
      return null;
    }
    return daoProductList.rename(initialProductList, newName);
  }
}
