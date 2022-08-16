import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

/// Dialog helper class for user product list.
class ProductListUserDialogHelper {
  const ProductListUserDialogHelper(this.daoProductList);

  final DaoProductList daoProductList;

  /// Shows a "create list" dialog; returns the new [ProductList] if relevant.
  Future<ProductList?> showCreateUserListDialog(
    final BuildContext context,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextEditingController textEditingController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final List<String> lists = await daoProductList.getUserLists();
    final String? title = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.user_list_dialog_new_title,
        body: Form(
          key: formKey,
          child: SmoothTextFormField(
            type: TextFieldTypes.PLAIN_TEXT,
            controller: textEditingController,
            hintText: appLocalizations.user_list_name_hint,
            autofocus: true,
            textInputAction: TextInputAction.done,
            validator: (String? value) {
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
        negativeAction: SmoothActionButton(
          onPressed: () => Navigator.pop(context),
          text: appLocalizations.cancel,
        ),
        positiveAction: SmoothActionButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) {
              return;
            }
            Navigator.pop(context, textEditingController.text);
          },
          text: appLocalizations.okay,
        ),
      ),
    );
    if (title == null) {
      return null;
    }
    final ProductList productList = ProductList.user(title);
    await daoProductList.put(productList);
    daoProductList.localDatabase.notifyListeners();
    return productList;
  }

  /// Shows all user lists with "contains [barcode]?" checkboxes.
  Future<bool> showUserListsWithBarcodeDialog(
    final BuildContext context,
    final Product product,
  ) async {
    final String barcode = product.barcode!;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> all = await daoProductList.getUserLists();
    final List<String> withBarcode =
        await daoProductList.getUserLists(withBarcode: barcode);
    final Set<String> newWithBarcode = <String>{};
    newWithBarcode.addAll(withBarcode);
    bool addedLists = false;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => StatefulBuilder(
        builder:
            (BuildContext context, void Function(VoidCallback fn) setState) {
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
          return SmoothAlertDialog(
            close: true,
            title: getProductName(product, appLocalizations),
            body: Column(children: children),
            negativeAction: SmoothActionButton(
              onPressed: () async {
                final ProductList? productList =
                    await showCreateUserListDialog(context);
                if (productList != null) {
                  all.clear();
                  all.addAll(await daoProductList.getUserLists());
                  setState(() => addedLists = true);
                }
              },
              text: appLocalizations.user_list_button_new,
            ),
            positiveAction: SmoothActionButton(
              onPressed: () => Navigator.pop(context, true),
              text: appLocalizations.okay,
            ),
          );
        },
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
        productList,
        barcode,
        newWithBarcode.contains(name),
      );
    }
    daoProductList.localDatabase.notifyListeners();
    return true;
  }

  /// Shows a "rename list" dialog; returns renamed [ProductList] if relevant.
  Future<ProductList?> showRenameUserListDialog(
    final BuildContext context,
    final ProductList initialProductList,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextEditingController textEditingController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final String initialName = initialProductList.parameters;
    textEditingController.text = initialName;
    final List<String> lists = await daoProductList.getUserLists();
    final String? newName = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.user_list_dialog_rename_title,
        body: Form(
          key: formKey,
          child: SmoothTextFormField(
            type: TextFieldTypes.PLAIN_TEXT,
            controller: textEditingController,
            hintText: appLocalizations.user_list_name_hint,
            textInputAction: TextInputAction.done,
            validator: (String? value) {
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
        negativeAction: SmoothActionButton(
          onPressed: () => Navigator.pop(context),
          text: appLocalizations.cancel,
        ),
        positiveAction: SmoothActionButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) {
              return;
            }
            Navigator.pop(context, textEditingController.text);
          },
          text: appLocalizations.okay,
        ),
      ),
    );
    if (newName == null) {
      return null;
    }
    final ProductList result =
        await daoProductList.rename(initialProductList, newName);
    daoProductList.localDatabase.notifyListeners();
    return result;
  }

  /// Shows a "delete list" dialog; returns true if deleted.
  Future<bool> showDeleteUserListDialog(
    final BuildContext context,
    final ProductList productList,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool? deleted = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        body: Text(
          appLocalizations.confirm_delete_user_list(productList.parameters),
        ),
        negativeAction: SmoothActionButton(
          onPressed: () => Navigator.pop(context),
          text: appLocalizations.cancel,
        ),
        positiveAction: SmoothActionButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          text: appLocalizations.okay,
        ),
      ),
    );
    if (deleted == null) {
      return false;
    }
    final bool result = await daoProductList.delete(productList);
    if (result) {
      daoProductList.localDatabase.notifyListeners();
    }
    return result;
  }
}
