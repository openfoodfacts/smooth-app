import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/product_list_user_dialog_helper.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
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

  static const double MIN_ITEM_HEIGHT = 58.0;

  @override
  Widget build(BuildContext context) {
    final _ProductUserListsWithState state = context
        .watch<_ProductUserListsProvider>()
        .value as _ProductUserListsWithState;
    final List<MapEntry<String, bool>> userLists = state.userLists;
    final bool? scrollBarVisible = userLists.length > 5 ? true : null;

    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 15.0,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      child: SliverFillRemaining(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Scrollbar(
                thumbVisibility: scrollBarVisible,
                trackVisibility: scrollBarVisible,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: userLists.length,
                  itemBuilder: (BuildContext context, int index) {
                    final MapEntry<String, bool> entry = userLists[index];
                    return KeyedSubtree(
                      key: ValueKey<String>(entry.key),
                      child: _AddToProductListItem(
                        listId: entry.key,
                        selected: entry.value,
                        // Force the divider when there is just one item
                        includeDivider: userLists.length == 1 ||
                            index < userLists.length - 1,
                      ),
                    );
                  },
                ),
              ),
            ),
            _AddToProductListAddNewList(
              userLists:
                  userLists.map((MapEntry<String, bool> entry) => entry.key),
            )
          ],
        ),
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
    extends State<_AddToProductListAddNewList>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _animationController;
  Animation<Color?>? _colorAnimation;
  int animationRepeat = 0;

  bool _editMode = false;
  bool _inputValid = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.short,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initAnimation();
    });
  }

  void _initAnimation() {
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final bool lightTheme = context.lightTheme(listen: false);

    _colorAnimation = ColorTween(
      begin: lightTheme ? extension.primaryLight : extension.primarySemiDark,
      end: extension.red,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        // Run back and forth the animation twice
        if (status == AnimationStatus.completed && animationRepeat < 2) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed && animationRepeat < 1) {
          animationRepeat++;
          _animationController.forward();
        }
      });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final bool lightTheme = context.lightTheme();

    final Color iconColor = lightTheme
        ? Theme.of(context)
            .checkboxTheme
            .fillColor!
            .resolve(<WidgetState>{WidgetState.selected})!
        : Colors.white;

    return IconTheme(
      data: IconThemeData(color: iconColor),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
        child: InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
          onTap: () {
            setState(() {
              if (!_editMode) {
                _controller.clear();
                _editMode = true;
                _inputValid = false;
              }
            });
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              color: _colorAnimation?.value,
              border: Border.all(
                color: lightTheme
                    ? extension.primaryNormal
                    : extension.primaryLight,
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: _AddToProductListWithLists.MIN_ITEM_HEIGHT,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: (Platform.isIOS || Platform.isMacOS) ? 18.5 : 21.0,
                    end: 5.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.add_circle_rounded),
                      const SizedBox(width: VERY_LARGE_SPACE),
                      Expanded(
                        child: _editMode
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    bottom: 1.0),
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
                                  onSubmitted: (_) => _addList(context),
                                ),
                              )
                            : Text(
                                appLocalizations.user_list_button_new,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      if (_editMode)
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () => setState(() => _editMode = false),
                          tooltip: MaterialLocalizations.of(context)
                              .cancelButtonLabel,
                        ),
                      if (_editMode)
                        IconButton(
                          icon: const Icon(Icons.check_circle),
                          color: _inputValid
                              ? iconColor
                              : iconColor.withOpacity(0.4),
                          tooltip: appLocalizations.product_list_create_tooltip,
                          onPressed: () => _addList(context),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
      _notifyWrongInput();
      return;
    }

    SmoothHapticFeedback.lightNotification();
    Provider.of<_ProductUserListsProvider>(context, listen: false)
        .createUserList(_controller.value.text);

    setState(() => _editMode = false);
  }

  void _notifyWrongInput() {
    animationRepeat = 0;
    _animationController.forward(from: 0.0);
    SmoothHapticFeedback.error();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A dashed divider
class _AddToProductListDivider extends StatelessWidget {
  const _AddToProductListDivider();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: LARGE_SPACE,
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 1.0),
        painter: _AddToProductListDividerPainter(
          dashWidth: 8.0,
          dashSpace: 5.0,
          color: context.lightTheme()
              ? extension.primaryNormal
              : extension.primaryLight,
        ),
      ),
    );
  }
}

class _AddToProductListDividerPainter extends CustomPainter {
  _AddToProductListDividerPainter({
    required Color color,
    required this.dashWidth,
    required this.dashSpace,
  })  : assert(color != Colors.transparent),
        assert(dashWidth >= 0),
        assert(dashSpace >= 0),
        _paint = Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

  final Paint _paint;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        _paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_AddToProductListDividerPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_AddToProductListDividerPainter oldDelegate) =>
      false;
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
