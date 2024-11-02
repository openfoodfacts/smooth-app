import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_checkbox.dart';

class AddProductToListContainer extends StatelessWidget {
  const AddProductToListContainer({required this.barcode, super.key});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_ProductUserListsProvider>(
      create: (BuildContext context) => _ProductUserListsProvider(
        DaoProductList(context.read<LocalDatabase>()),
        barcode,
      ),
      child: Consumer<_ProductUserListsProvider>(
        builder: (
          final BuildContext context,
          final _ProductUserListsProvider productUserListsProvider,
          final Widget? child,
        ) {
          return switch (productUserListsProvider.value) {
            _ProductUserListsLoadingState _ => const _AddToProductListLoading(),
            _ProductUserListsEmptyState _ =>
              const _AddToProductListNoListAvailable(),
            _ProductUserListsWithState _ => const _AddToProductListWithLists(),
          };
        },
      ),
    );
  }
}

/// Widget when the [_ProductUserListsProvider] is loading lists
class _AddToProductListLoading extends StatelessWidget {
  const _AddToProductListLoading();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

/// Widget when there is no user list
/// A button to create a new list (in a dialog)
class _AddToProductListNoListAvailable extends StatelessWidget {
  const _AddToProductListNoListAvailable();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: LARGE_SPACE,
            end: LARGE_SPACE,
            bottom: VERY_LARGE_SPACE,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ExcludeSemantics(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .extension<SmoothColorsThemeExtension>()!
                        .secondaryLight,
                  ),
                  padding: const EdgeInsets.all(VERY_LARGE_SPACE),
                  child: const Milk(
                    size: 40.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: VERY_LARGE_SPACE),
              Text(
                appLocalizations.user_list_empty_label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: VERY_LARGE_SPACE),
              SmoothSimpleButton(
                onPressed: () async {
                  final ProductList? list = await ProductListUserDialogHelper(
                          DaoProductList(context.read<LocalDatabase>()))
                      .showCreateUserListDialog(
                    context,
                  );

                  if (list != null && context.mounted) {
                    final _ProductUserListsProvider provider =
                        context.read<_ProductUserListsProvider>();
                    await provider.addAProductToAList(list.parameters);
                    await provider.reloadLists();
                  }
                },
                child: Text(
                  appLocalizations.user_list_button_new,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget when there are user lists
/// A list of:
/// -> Add new list button
/// -> List of user lists
class _AddToProductListWithLists extends StatelessWidget {
  const _AddToProductListWithLists();

  static const double MIN_ITEM_HEIGHT = 48.0;

  @override
  Widget build(BuildContext context) {
    final _ProductUserListsWithState state = context
        .watch<_ProductUserListsProvider>()
        .value as _ProductUserListsWithState;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return _AddToProductListAddNewList(
              userLists: state.userLists.map((MapEntry<String, bool> entry) {
                return entry.key;
              }),
            );
          } else if (index <= state.userLists.length) {
            final MapEntry<String, bool> entry = state.userLists[index - 1];
            return _AddToProductListItem(
              listId: entry.key,
              selected: entry.value,
              includeDivider: index < state.userLists.length,
            );
          } else {
            return SizedBox(height: MediaQuery.viewPaddingOf(context).bottom);
          }
        },
        childCount: state.userLists.length + 2,
      ),
    );
  }
}

/// An item showing a user list and handling the click
class _AddToProductListItem extends StatelessWidget {
  const _AddToProductListItem({
    required this.listId,
    required this.selected,
    required this.includeDivider,
  });

  final String listId;
  final bool selected;
  final bool includeDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            SmoothHapticFeedback.lightNotification();
            Provider.of<_ProductUserListsProvider>(context, listen: false)
                .toggleProductToList(listId);
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _AddToProductListWithLists.MIN_ITEM_HEIGHT,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: LARGE_SPACE,
                // The CupertinoCheckbox has huge paddings
                // (that we can't override)
                vertical:
                    (Platform.isIOS || Platform.isMacOS) ? 2.0 : MEDIUM_SPACE,
              ),
              child: Row(
                children: <Widget>[
                  IgnorePointer(
                    child: SmoothCheckbox(
                      value: selected,
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: MEDIUM_SPACE),
                  Expanded(
                    child: Text(
                      listId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (includeDivider) const _AddToProductListDivider()
      ],
    );
  }
}

/// Widget that shows an inline way to create a list
class _AddToProductListAddNewList extends StatefulWidget {
  const _AddToProductListAddNewList({required this.userLists});

  final Iterable<String> userLists;

  @override
  State<_AddToProductListAddNewList> createState() =>
      _AddToProductListAddNewListState();
}

class _AddToProductListAddNewListState
    extends State<_AddToProductListAddNewList> {
  final TextEditingController _controller = TextEditingController();
  bool _editMode = false;
  bool _inputValid = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Color? mainColor = Theme.of(context)
        .checkboxTheme
        .fillColor!
        .resolve(<WidgetState>{WidgetState.selected});

    return Column(
      children: <Widget>[
        IconTheme(
          data: IconThemeData(color: mainColor),
          child: InkWell(
            onTap: () {
              setState(() {
                if (!_editMode) {
                  _controller.clear();
                  _editMode = true;
                  _inputValid = false;
                }
              });
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: _AddToProductListWithLists.MIN_ITEM_HEIGHT,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal:
                      (Platform.isIOS || Platform.isMacOS) ? 25.5 : 28.0,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.add_circle_rounded),
                    const SizedBox(width: VERY_LARGE_SPACE),
                    Expanded(
                      child: _editMode
                          ? Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(bottom: 1.0),
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: appLocalizations
                                      .user_list_name_input_hint,
                                  hintStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                textInputAction: TextInputAction.done,
                                maxLines: 1,
                                textAlignVertical: TextAlignVertical.top,
                                style: DefaultTextStyle.of(context).style,
                                onChanged: _checkInput,
                                onSubmitted: (_) => _inputValid
                                    ? () => _addList(context)
                                    : null,
                              ),
                            )
                          : Text(
                              appLocalizations.user_list_button_new,
                            ),
                    ),
                    if (_editMode)
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => setState(() => _editMode = false),
                      ),
                    if (_editMode)
                      IconButton(
                        icon: const Icon(Icons.check_circle),
                        onPressed: _inputValid ? () => _addList(context) : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const _AddToProductListDivider(),
      ],
    );
  }

  void _checkInput(String value) {
    final bool validInput =
        value.trim().isNotEmpty && !widget.userLists.containsIgnoreCase(value);

    if (validInput != _inputValid) {
      setState(() {
        _inputValid = validInput;
      });
    }
  }

  void _addList(BuildContext context) {
    if (!_inputValid) {
      return;
    }

    SmoothHapticFeedback.lightNotification();
    Provider.of<_ProductUserListsProvider>(context, listen: false)
        .createUserList(_controller.value.text);

    setState(() => _editMode = false);
  }
}

class _AddToProductListDivider extends StatelessWidget {
  const _AddToProductListDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: LARGE_SPACE,
      ),
      child: SizedBox(
        height: 1.0,
        width: double.infinity,
        child: ColoredBox(
          color: Theme.of(context)
              .extension<SmoothColorsThemeExtension>()!
              .primaryLight,
        ),
      ),
    );
  }
}

/// Logic for the user lists
class _ProductUserListsProvider extends ValueNotifier<_ProductUserListsState> {
  _ProductUserListsProvider(this.dao, this.barcode)
      : super(const _ProductUserListsLoadingState()) {
    reloadLists();
  }

  final DaoProductList dao;
  final String barcode;

  Future<void> reloadLists() async {
    emit(const _ProductUserListsLoadingState());

    final List<String> lists = dao.getUserLists();
    if (lists.isEmpty) {
      emit(const _ProductUserListsEmptyState());
      return;
    }

    // Sort by ignoring case
    lists.sort(
      (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );

    // Create a list of user lists with a boolean if the product is in it
    final List<String> listsWithProduct =
        await dao.getUserListsWithBarcodes(<String>[barcode]);

    final List<MapEntry<String, bool>> userLists = <MapEntry<String, bool>>[];
    for (final String listId in lists) {
      userLists.add(
        MapEntry<String, bool>(listId, listsWithProduct.contains(listId)),
      );
    }

    emit(_ProductUserListsWithState(userLists));
  }

  Future<bool> toggleProductToList(String listId) async {
    if (value is! _ProductUserListsWithState) {
      return false;
    }

    /// Fake the UI first (otherwise there is a slight delay)
    final bool selected = !(value as _ProductUserListsWithState)
        .userLists
        .firstWhere((MapEntry<String, bool> item) => item.key == listId)
        .value;

    _fakeStateChange(
      listId,
      selected,
    );

    return dao.set(
      ProductList.user(listId),
      barcode,
      selected,
    );
  }

  /// Create a new user list and add the product to it
  Future<bool> createUserList(String listId) async {
    /// Fake the UI first (otherwise there is a slight delay)
    _fakeStateChange(listId, true);

    final ProductList userList = ProductList.user(listId);
    await dao.put(userList);
    return addAProductToAList(listId);
  }

  Future<bool> addAProductToAList(String listId) {
    return dao.set(ProductList.user(listId), barcode, true);
  }

  /// Force reload the UI.
  /// If [listId] doesn't exist, it will be added at the top.
  bool _fakeStateChange(String listId, bool selected) {
    final List<MapEntry<String, bool>> lists = List<MapEntry<String, bool>>.of(
        (value as _ProductUserListsWithState).userLists);

    final int position =
        lists.indexWhere((MapEntry<String, bool> item) => item.key == listId);

    if (position >= 0) {
      lists[position] = MapEntry<String, bool>(listId, selected);
    } else {
      lists.insert(0, MapEntry<String, bool>(listId, selected));
    }

    emit(_ProductUserListsWithState(lists));
    return true;
  }
}

sealed class _ProductUserListsState {
  const _ProductUserListsState();
}

class _ProductUserListsLoadingState extends _ProductUserListsState {
  const _ProductUserListsLoadingState();
}

class _ProductUserListsEmptyState extends _ProductUserListsState {
  const _ProductUserListsEmptyState();
}

class _ProductUserListsWithState extends _ProductUserListsState {
  _ProductUserListsWithState(this.userLists);

  final List<MapEntry<String, bool>> userLists;
}
