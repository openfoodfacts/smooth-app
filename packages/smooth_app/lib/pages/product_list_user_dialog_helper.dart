import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';

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

    final List<String> lists = daoProductList.getUserLists();
    final String? title = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) {
        return SmoothAlertDialog(
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
                value = value?.trim();
                if (value == null || value.isEmpty) {
                  return appLocalizations.user_list_name_error_empty;
                }
                if (lists.contains(value)) {
                  return appLocalizations.user_list_name_error_already;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                Navigator.pop(context, textEditingController.text.trim());
              },
            ),
          ),
          actionsAxis: Axis.vertical,
          negativeAction: SmoothActionButton(
            onPressed: () => Navigator.pop(context),
            text: appLocalizations.cancel,
          ),
          positiveAction: SmoothActionButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              Navigator.pop(context, textEditingController.text.trim());
            },
            text: appLocalizations.create,
          ),
        );
      },
    );

    if (title == null) {
      return null;
    }

    final ProductList productList = ProductList.user(title);
    await daoProductList.put(productList);
    daoProductList.localDatabase.notifyListeners();
    return productList;
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
    final List<String> lists = daoProductList.getUserLists();
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
        title: appLocalizations.confirm_delete_user_list_title,
        body: Text(
          appLocalizations.confirm_delete_user_list_message(
            ProductQueryPageHelper.getProductListLabel(
              productList,
              appLocalizations,
            ),
          ),
        ),
        negativeAction: SmoothActionButton(
          onPressed: () => Navigator.pop(context),
          text: appLocalizations.no,
        ),
        positiveAction: SmoothActionButton(
          onPressed: () => Navigator.pop(context, true),
          text: appLocalizations.confirm_delete_user_list_button,
        ),
        actionsAxis: Axis.vertical,
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

  /// Shows all user lists with checkboxes, adds all [barcodes] to the selected lists.
  /// Pre-checks all lists where all the selected barcodes are already contained
  /// Returns true if products were added
  Future<bool?> showUserAddProductsDialog(
    final BuildContext context,
    final Set<String> barcodes,
  ) async {
    final List<String> lists = daoProductList.getUserLists();

    if (lists.isEmpty) {
      final bool? newListCreated = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => _UserEmptyLists(daoProductList),
      );
      if (newListCreated != null && newListCreated) {
        if (context.mounted) {
          return showUserAddProductsDialog(context, barcodes);
        }
      }
      return false;
    }

    final List<String> selectedLists =
        await daoProductList.getUserListsWithBarcodes(
      barcodes.toList(growable: false),
    );

    if (!context.mounted) {
      return null;
    }
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) => _UserLists(
        lists: lists.toSet(),
        selectedLists: selectedLists.toSet(),
        onListsSubmitted: (Set<String> newSelectedLists) async {
          bool hasChanged = false;

          for (final String list in lists) {
            // Nothing changed
            if (selectedLists.contains(list) &&
                newSelectedLists.contains(list)) {
              continue;
            }

            // List got selected
            if (!selectedLists.contains(list) &&
                newSelectedLists.contains(list)) {
              hasChanged = true;
              await daoProductList.bulkSet(
                ProductList.user(list),
                barcodes.toList(),
              );
            }

            // List got unselected
            if (selectedLists.contains(list) &&
                !newSelectedLists.contains(list)) {
              hasChanged = true;
              await daoProductList.bulkSet(
                ProductList.user(list),
                barcodes.toList(),
                include: false,
              );
            }
          }

          return hasChanged;
        },
      ),
    );
  }
}

/// List of all lists the user has
/// Handles click rebuilds
class _UserLists extends StatefulWidget {
  const _UserLists({
    required this.lists,
    required this.selectedLists,
    required this.onListsSubmitted,
  });

  final Set<String> lists;
  final Set<String> selectedLists;
  final Future<bool> Function(Set<String> selectedLists) onListsSubmitted;

  @override
  State<_UserLists> createState() => _UserListsState();
}

class _UserListsState extends State<_UserLists> {
  late Set<String> selectedLists;

  @override
  void initState() {
    selectedLists = widget.selectedLists;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothAlertDialog(
      close: true,
      title: appLocalizations.user_list_add_product,
      negativeAction: _cancelButton(appLocalizations, context),
      positiveAction: SmoothActionButton(
        text: appLocalizations.save,
        onPressed: () async {
          Navigator.of(context).pop(
            await widget.onListsSubmitted(selectedLists),
          );
        },
      ),
      body: Column(
        children: widget.lists.map((String name) {
          return ListTile(
              leading: Icon(
                selectedLists.contains(name)
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
              ),
              title: Text(name),
              onTap: () {
                if (selectedLists.contains(name)) {
                  selectedLists.removeWhere((String e) => e == name);
                } else {
                  selectedLists.add(name);
                }
                setState(() {});
              });
        }).toList(growable: false),
      ),
    );
  }
}

/// Widget indicate that the user has no lists yet
/// Pop returns true if a new list is created
class _UserEmptyLists extends StatefulWidget {
  const _UserEmptyLists(
    this.daoProductList,
  );

  final DaoProductList daoProductList;

  @override
  State<_UserEmptyLists> createState() => _UserEmptyListsState();
}

class _UserEmptyListsState extends State<_UserEmptyLists> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothAlertDialog(
      body: Column(
        children: <Widget>[
          SvgPicture.asset('assets/misc/error.svg'),
          const SizedBox(height: LARGE_SPACE),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: MEDIUM_SPACE,
              vertical: SMALL_SPACE,
            ),
            child: Text(
              appLocalizations.user_list_empty_label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          const SizedBox(height: LARGE_SPACE),
        ],
      ),
      actionsAxis: Axis.vertical,
      actionsOrder: SmoothButtonsBarOrder.auto,
      positiveAction: SmoothActionButton(
        onPressed: () async {
          final ProductList? productList =
              await ProductListUserDialogHelper(widget.daoProductList)
                  .showCreateUserListDialog(context);

          if (productList != null && context.mounted) {
            Navigator.pop<bool>(context, true);
          }
        },
        text: appLocalizations.user_list_button_new,
      ),
      negativeAction: _cancelButton(appLocalizations, context),
    );
  }
}

/// Closes the dialog and returns false, as no products were added
SmoothActionButton _cancelButton(
        AppLocalizations appLocalizations, BuildContext context) =>
    SmoothActionButton(
      onPressed: () => Navigator.pop(context, false),
      text: appLocalizations.cancel,
    );
