import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
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
              onFieldSubmitted: (_) => _onNewListValueSubmitted(
                context,
                formKey,
                textEditingController,
              ),
            ),
          ),
          actionsAxis: Axis.vertical,
          negativeAction: SmoothActionButton(
            onPressed: () => Navigator.pop(context),
            text: appLocalizations.cancel,
          ),
          positiveAction: SmoothActionButton(
            onPressed: () => _onNewListValueSubmitted(
              context,
              formKey,
              textEditingController,
            ),
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

  /// Event raised when the user validates a new list name.
  void _onNewListValueSubmitted(
    final BuildContext context,
    final GlobalKey<FormState> formKey,
    final TextEditingController textEditingController,
  ) {
    if (!formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(context, textEditingController.text);
  }

  /// Shows all user lists with "contains [barcode]?" checkboxes.
  Future<bool> showUserListsWithBarcodeDialog(
    final BuildContext context,
    final Product product,
  ) async {
    final bool? res = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => _UserListsDialogContent(
        daoProductList: daoProductList,
        product: product,
      ),
    );

    return res ?? true;
  }

  /// Shows all user lists with checkboxes, adds all [barcodes] to the selected lists.
  /// Filters for duplicates
  Future<void> showBulkInsertUserListsDialog(
    final BuildContext context,
    final List<String> barcodes,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> lists = await daoProductList.getUserLists();
    final Set<String> selectedLists = <String>{};

    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (
          BuildContext context,
          void Function(VoidCallback fn) setState,
        ) {
          return SmoothAlertDialog(
            body: _UserLists(
              lists: lists,
              selectedLists: selectedLists,
              onListSelected: (String name) {
                selectedLists.add(name);
                setState(() {});
              },
              onListUnselected: (String name) {
                selectedLists.removeWhere((String element) => element == name);
                setState(() {});
              },
            ),
            positiveAction: SmoothActionButton(
                text: appLocalizations.save,
                onPressed: () async {
                  for (final String name in selectedLists) {
                    await daoProductList.bulkInsert(
                      ProductList.user(name),
                      barcodes,
                    );
                  }

                  //ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }),
            negativeAction: SmoothActionButton(
              text: appLocalizations.cancel,
              onPressed: () => Navigator.pop(context),
            ),
          );
        },
      ),
    );
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

/// Dialog to add/remove a product from users' lists
class _UserListsDialogContent extends StatefulWidget {
  const _UserListsDialogContent({
    required this.product,
    required this.daoProductList,
    Key? key,
  }) : super(key: key);

  final Product product;
  final DaoProductList daoProductList;

  @override
  State<_UserListsDialogContent> createState() =>
      _UserListsDialogContentState();
}

class _UserListsDialogContentState extends State<_UserListsDialogContent> {
  final List<String> all = <String>[];
  final List<String> withBarcode = <String>[];
  final Set<String> newWithBarcode = <String>{};

  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _loadUserLists();
  }

  Future<void> _loadUserLists() async {
    _isLoading = true;

    await _loadAllUserLists();

    withBarcode.clear();
    withBarcode.addAll(await widget.daoProductList
        .getUserLists(withBarcode: widget.product.barcode));

    newWithBarcode.clear();
    newWithBarcode.addAll(withBarcode);

    if (mounted) {
      _isLoading = false;
      setState(() {});
    }
  }

  Future<void> _loadAllUserLists() async {
    all.clear();
    all.addAll(await widget.daoProductList.getUserLists());
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    } else {
      content = _hasLists
          ? _UserLists(
              lists: all,
              selectedLists: newWithBarcode,
              onListSelected: (String barcode) {
                setState(() {
                  newWithBarcode.add(barcode);
                });
              },
              onListUnselected: (String barcode) {
                setState(() {
                  newWithBarcode.remove(barcode);
                });
              },
            )
          : const _UserEmptyLists();
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothAlertDialog(
      close: true,
      title: appLocalizations.user_list_add_product,
      body: content,
      actionsAxis: Axis.vertical,
      actionsOrder: _order,
      negativeAction: _negativeButton(appLocalizations),
      positiveAction: _positiveButton(appLocalizations),
    );
  }

  String get _barcode => widget.product.barcode!;

  bool get _hasLists => all.isNotEmpty;

  SmoothButtonsBarOrder get _order {
    if (_hasLists) {
      return SmoothButtonsBarOrder.numerical;
    } else {
      return SmoothButtonsBarOrder.auto;
    }
  }

  SmoothActionButton _positiveButton(AppLocalizations appLocalizations) {
    if (_hasLists) {
      return _saveListsButton(appLocalizations);
    } else {
      return _createListButton(appLocalizations);
    }
  }

  SmoothActionButton _negativeButton(AppLocalizations appLocalizations) {
    if (_hasLists) {
      return _createListButton(appLocalizations);
    } else {
      return _createCancelButton(appLocalizations);
    }
  }

  SmoothActionButton _createListButton(AppLocalizations appLocalizations) =>
      SmoothActionButton(
        onPressed: () async {
          final ProductList? productList =
              await ProductListUserDialogHelper(widget.daoProductList)
                  .showCreateUserListDialog(context);

          if (productList != null) {
            await _loadUserLists();
            setState(() {});
          }
        },
        text: appLocalizations.user_list_button_new,
      );

  SmoothActionButton _createCancelButton(AppLocalizations appLocalizations) =>
      SmoothActionButton(
        onPressed: () => Navigator.pop(context, true),
        text: appLocalizations.cancel,
      );

  SmoothActionButton _saveListsButton(AppLocalizations appLocalizations) {
    return SmoothActionButton(
      onPressed: () async {
        final Set<String> possibleChanges = <String>{};
        possibleChanges.addAll(withBarcode);
        possibleChanges.addAll(newWithBarcode);
        for (final String name in possibleChanges) {
          if (withBarcode.contains(name) && newWithBarcode.contains(name)) {
            continue;
          }
          if ((!withBarcode.contains(name)) &&
              (!newWithBarcode.contains(name))) {
            continue;
          }
          final ProductList productList = ProductList.user(name);
          await widget.daoProductList.set(
            productList,
            _barcode,
            newWithBarcode.contains(name),
          );
        }

        widget.daoProductList.localDatabase.notifyListeners();

        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      },
      text: appLocalizations.save,
    );
  }
}

class _UserLists extends StatelessWidget {
  const _UserLists({
    Key? key,
    required this.lists,
    required this.selectedLists,
    required this.onListSelected,
    required this.onListUnselected,
  }) : super(key: key);

  final List<String> lists;
  final Set<String> selectedLists;
  final void Function(String) onListSelected;
  final void Function(String) onListUnselected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lists.map((String name) {
        return ListTile(
            leading: Icon(
              selectedLists.contains(name)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            title: Text(name),
            onTap: () {
              if (selectedLists.contains(name)) {
                onListUnselected(name);
              } else {
                onListSelected(name);
              }
            });
      }).toList(growable: false),
    );
  }
}

class _UserEmptyLists extends StatelessWidget {
  const _UserEmptyLists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
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
        const Icon(Icons.arrow_circle_down),
      ],
    );
  }
}
