import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';

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
                Navigator.pop(context, textEditingController.text);
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
              Navigator.pop(context, textEditingController.text);
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

  /// Shows all user lists with checkboxes, adds all [barcodes] to the selected lists.
  /// Pre-checks all lists where [barcodes][0] is included if [barcodes.length] == 1
  /// Returns true if products were added
  Future<bool?> showUserAddProductsDialog(
    final BuildContext context,
    final Set<String> barcodes,
  ) async {
    final List<String>? lists = await LoadingDialog.run<List<String>>(
      context: context,
      future: daoProductList.getUserLists(),
    );

    late final Widget widget;

    if (lists == null || lists.isEmpty) {
      widget = _UserEmptyLists(daoProductList);
    } else {
      List<String>? selectedLists = <String>[];

      // We only check if the barcode is in the list if we only pass a single barcode
      if (barcodes.length == 1) {
        selectedLists = await LoadingDialog.run<List<String>>(
          context: context,
          future: daoProductList.getUserLists(withBarcode: barcodes.first),
        );
      }

      widget = _UserListsDialogContent(
        daoProductList: daoProductList,
        allLists: lists.toSet(),
        selectedLists: selectedLists?.toSet() ?? <String>{},
        barcodes: barcodes,
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => widget,
    );
  }
}

/// Dialog content to add/remove products from users' lists
class _UserListsDialogContent extends StatefulWidget {
  const _UserListsDialogContent({
    required this.barcodes,
    required this.allLists,
    this.selectedLists = const <String>{},
    required this.daoProductList,
    Key? key,
  }) : super(key: key);

  final Set<String> barcodes;
  final Set<String> allLists;
  final Set<String> selectedLists;
  final DaoProductList daoProductList;

  @override
  State<_UserListsDialogContent> createState() =>
      _UserListsDialogContentState();
}

class _UserListsDialogContentState extends State<_UserListsDialogContent> {
  final Set<String> addTo = <String>{};
  final Set<String> removeFrom = <String>{};

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothAlertDialog(
      close: true,
      title: appLocalizations.user_list_add_product,
      body: _UserLists(
        lists: widget.allLists,
        selectedLists: widget.selectedLists,
        onListSelected: (String list) {
          addTo.add(list);
          removeFrom.removeWhere((String e) => e == list);
        },
        onListUnselected: (String list) {
          removeFrom.add(list);
          addTo.removeWhere((String e) => e == list);
        },
      ),
      negativeAction: _cancelButton(appLocalizations, context),
      positiveAction: SmoothActionButton(
        onPressed: () async {
          for (final String name in removeFrom) {
            await widget.daoProductList.set(
              ProductList.user(name),
              // Removal only works for single product addition
              widget.barcodes.first,
              false,
            );
          }

          for (final String name in addTo) {
            await widget.daoProductList
                .bulkInsert(ProductList.user(name), widget.barcodes.toList());
          }

          widget.daoProductList.localDatabase.notifyListeners();

          // ignore: use_build_context_synchronously
          Navigator.pop(context, true);
        },
        text: appLocalizations.save,
      ),
    );
  }
}

/// List of all lists the user has
/// Handles click rebuilds
class _UserLists extends StatefulWidget {
  const _UserLists({
    Key? key,
    required this.lists,
    required this.selectedLists,
    required this.onListSelected,
    required this.onListUnselected,
  }) : super(key: key);

  final Set<String> lists;
  final Set<String> selectedLists;
  final void Function(String) onListSelected;
  final void Function(String) onListUnselected;

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
    return Column(
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
                widget.onListUnselected(name);
                selectedLists.removeWhere((String e) => e == name);
              } else {
                widget.onListSelected(name);
                selectedLists.add(name);
              }
              setState(() {});
            });
      }).toList(growable: false),
    );
  }
}

/// Widget indicate that the user has no lists yet
class _UserEmptyLists extends StatefulWidget {
  const _UserEmptyLists(this.daoProductList, {Key? key}) : super(key: key);

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
          const Icon(Icons.warning),
          const SizedBox(height: VERY_SMALL_SPACE),
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
              ),
            ),
          ),
          const SizedBox(height: LARGE_SPACE * 2.5),
        ],
      ),
      positiveAction: SmoothActionButton(
        onPressed: () async {
          final ProductList? productList =
              await ProductListUserDialogHelper(widget.daoProductList)
                  .showCreateUserListDialog(context);

          if (productList != null && mounted) {
            Navigator.pop<bool>(context, true);
          }
        },
        text: appLocalizations.user_list_button_new,
      ),
      negativeAction: _cancelButton(appLocalizations, context),
    );
  }
}

SmoothActionButton _cancelButton(
        AppLocalizations appLocalizations, BuildContext context) =>
    SmoothActionButton(
      onPressed: () => Navigator.pop(context, true),
      text: appLocalizations.cancel,
    );
