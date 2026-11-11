import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/pages/product/common/search_preloaded_item.dart';
import 'package:smooth_app/pages/search/search_hint.dart';
import 'package:smooth_app/pages/search/sort_pinned_first.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_circle.dart';

class SearchHistoryView extends StatefulWidget {
  const SearchHistoryView({
    required this.onTap,
    required this.focusNode,
    required this.searchHelper,
    required this.preloadedList,
  });

  final void Function(String) onTap;
  final FocusNode focusNode;
  final SearchHelper searchHelper;
  final List<SearchPreloadedItem> preloadedList;

  @override
  State<SearchHistoryView> createState() => _SearchHistoryViewState();
}

class _SearchHistoryViewState extends State<SearchHistoryView> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  List<String> _queries = <String>[];

  /// The displayed order of the preloaded items. [widget.preloadedList] keeps
  /// the last access order and is the source of every re-derivation.
  late final List<SearchPreloadedItem> _items;

  /// The removed items that are still sliding out: until they are gone, the
  /// title above them stays.
  int _leavingItems = 0;

  bool get _showItems => _items.isNotEmpty || _leavingItems > 0;

  @override
  void initState() {
    super.initState();
    _items = _derive();
  }

  List<SearchPreloadedItem> _derive() => sortPinnedFirst(
    widget.preloadedList,
    (SearchPreloadedItem item) => item.isPinned(context),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchQueries();
  }

  void _fetchQueries() {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final List<String> queries = widget.searchHelper.getAllQueries(
      localDatabase,
    );
    setState(() => _queries = queries);
  }

  @override
  Widget build(BuildContext context) {
    final int count = _queries.length + _items.length;
    if (count == 0) {
      return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 2.0,
          start: widget.searchHelper.getLeadingWidget(context) != null
              ? VERY_LARGE_SPACE
              : SMALL_SPACE,
        ),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: SearchHint(
            text: widget.searchHelper.getHelpText(AppLocalizations.of(context)),
          ),
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String? itemsTitle = widget.searchHelper.getPreloadedItemsTitle(
      appLocalizations,
    );

    final bool showPasteFromClipboard =
        widget.searchHelper.showPasteFromClipboard;
    final double bottomPadding = math.max(
      MediaQuery.viewPaddingOf(context).bottom,
      MediaQuery.viewInsetsOf(context).bottom,
    );

    return ListTileTheme(
      data: ListTileThemeData(
        titleTextStyle: const TextStyle(fontSize: 18.0),
        minLeadingWidth: 10.0,
        iconColor: theme.colorScheme.onSurface,
        textColor: theme.colorScheme.onSurface,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                if (_showItems && itemsTitle != null)
                  SliverToBoxAdapter(
                    child: _SearchHistoryTitle(
                      title: itemsTitle,
                      icon: widget.searchHelper.getPreloadedItemsTitleIcon(),
                    ),
                  ),
                SliverAnimatedList(
                  key: _listKey,
                  initialItemCount: _items.length,
                  itemBuilder:
                      (
                        BuildContext context,
                        int index,
                        Animation<double> animation,
                      ) {
                        final SearchPreloadedItem item = _items[index];
                        return KeyedSubtree(
                          key: ObjectKey(item),
                          child: _SlideTransition(
                            animation: animation,
                            child: item.getWidget(
                              context,
                              onDeleteItem: () => _onDeleteItem(item),
                              onFavoriteChanged: () => _onFavoriteChanged(item),
                            ),
                          ),
                        );
                      },
                ),
                if (_showItems && _queries.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: MEDIUM_SPACE),
                  ),
                if (_queries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SearchHistoryTitle(
                      title: appLocalizations.search_history,
                      icon: widget.searchHelper.getQueriesTitleIcon(),
                    ),
                  ),
                _buildQueries(),
                // Inside the list, so the cards scroll under the system bar
                if (!showPasteFromClipboard)
                  SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
              ],
            ),
          ),
          if (showPasteFromClipboard)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: SMALL_SPACE,
                bottom: bottomPadding,
              ),
              child: _SearchItemPasteFromClipboard(
                onData: (String data) => widget.onTap.call(data),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQueries() => SliverList.builder(
    itemCount: _queries.length,
    itemBuilder: (BuildContext context, int i) {
      final String query = _queries[i];

      return _SearchHistoryTile(
        query: query,
        onTap: () => widget.onTap.call(query),
        onEditItem: () => _onEditItem(query),
        onRemoveItem: () async {
          // we need an immediate action for the display refresh
          _queries.remove(query);
          // and we need to impact the database too
          final LocalDatabase localDatabase = context.read<LocalDatabase>();
          await widget.searchHelper.removeQuery(localDatabase, query);
          setState(() {});
        },
      );
    },
  );

  Duration get _animationDuration => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : SmoothAnimationsDuration.long;

  void _removeItemAt(int index, SearchPreloadedItem item) {
    final Duration duration = _animationDuration;
    _items.removeAt(index);
    if (duration > Duration.zero) {
      _leavingItems++;
      Future<void>.delayed(duration, () {
        if (mounted) {
          setState(() => _leavingItems--);
        }
      });
    }
    _listKey.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) => IgnorePointer(
        child: _SlideTransition(
          animation: animation,
          removed: true,
          child: item.getWidget(context),
        ),
      ),
      duration: duration,
    );
  }

  Future<void> _onDeleteItem(SearchPreloadedItem item) async {
    final int index = _items.indexOf(item);
    if (index < 0) {
      return;
    }

    setState(() => _removeItemAt(index, item));
    // and the item must not come back when this view is re-created
    widget.preloadedList.remove(item);
    // and we need to impact the database too
    await item.delete(context);
  }

  void _onFavoriteChanged(SearchPreloadedItem item) {
    if (!mounted) {
      return;
    }

    final int oldIndex = _items.indexOf(item);
    if (oldIndex < 0) {
      // Deleted in the meantime
      return;
    }

    final int newIndex = _derive().indexOf(item);
    if (newIndex == oldIndex) {
      return;
    }

    // Both edits stay in the same synchronous block, with the same duration,
    // so the list height above the viewport stays stable.
    _removeItemAt(oldIndex, item);
    _items.insert(newIndex, item);
    _listKey.currentState?.insertItem(newIndex, duration: _animationDuration);
  }

  void _onEditItem(String query) {
    final TextEditingController controller = Provider.of<TextEditingController>(
      context,
      listen: false,
    );

    controller.text = query;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );

    // If the keyboard is hidden, show it.
    if (View.of(context).viewInsets.bottom == 0) {
      widget.focusNode.unfocus();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(widget.focusNode);
      });
    }
  }
}

class _SearchHistoryTitle extends StatelessWidget {
  const _SearchHistoryTitle({required this.title, this.icon});

  final String title;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: MEDIUM_SPACE,
          // Aligned with the icons of the cards and of the history entries
          start: SMALL_SPACE + MEDIUM_SPACE,
          end: SMALL_SPACE + MEDIUM_SPACE,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: ROUNDED_BORDER_RADIUS,
            color: theme.primaryMedium,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SMALL_SPACE,
              vertical: BALANCED_SPACE,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SMALL_SPACE,
              children: <Widget>[
                if (icon != null)
                  IconTheme.merge(
                    data: IconThemeData(color: theme.primaryBlack, size: 18.0),
                    child: icon!,
                  ),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.primaryBlack,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHistoryTile extends StatelessWidget {
  const _SearchHistoryTile({
    required this.query,
    required this.onTap,
    required this.onEditItem,
    required this.onRemoveItem,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onEditItem;
  final VoidCallback onRemoveItem;

  /// The size of the icons of the cards above.
  static const double _leadingSize = 20.0;
  static const double _editIconSize = 15.0;
  static const double _buttonPadding = SMALL_SPACE;
  static const double _editButtonSize = _editIconSize + 2 * _buttonPadding;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final Color color = lightTheme ? theme.primaryBlack : theme.primaryMedium;
    final Color iconColor = lightTheme
        ? theme.primaryNormal
        : theme.primaryMedium;

    return SmoothCard(
      elevation: 0.0,
      margin: const EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        start: SMALL_SPACE,
        end: SMALL_SPACE,
      ),
      padding: EdgeInsets.zero,
      color: lightTheme ? null : theme.primaryUltraBlack,
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: SMALL_SPACE + MEDIUM_SPACE,
            // The edit button is drawn smaller than its tap area
            end:
                SMALL_SPACE +
                MEDIUM_SPACE -
                (kMinInteractiveDimension - _editButtonSize) / 2,
            top: 2.0,
            bottom: 2.0,
          ),
          child: IconButtonTheme(
            data: IconButtonThemeData(
              style: IconButton.styleFrom(
                backgroundColor: theme.primaryMedium,
                foregroundColor: theme.primaryBlack,
                minimumSize: const Size(18.0, 18.0),
                padding: const EdgeInsets.all(_buttonPadding),
              ),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: _leadingSize,
                  child: Center(
                    child: SmoothCircle.indicator(
                      color: iconColor,
                      size: 10.0,
                    ),
                  ),
                ),
                const SizedBox(width: SMALL_SPACE),
                Expanded(
                  child: Text(
                    query,
                    style: TextStyle(
                      color: lightTheme ? color : Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: localizations.search_history_item_remove_tooltip,
                  onPressed: onRemoveItem,
                  icon: const icons.Trash(size: 17.0),
                ),
                const SizedBox(width: VERY_SMALL_SPACE),
                IconButton(
                  tooltip: localizations.search_history_item_edit_tooltip,
                  onPressed: onEditItem,
                  icon: const icons.Edit(size: _editIconSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchItemPasteFromClipboard extends StatelessWidget {
  const _SearchItemPasteFromClipboard({required this.onData});

  final Function(String) onData;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Material(
      color: lightTheme ? Colors.white : extension.primaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: CIRCULAR_BORDER_RADIUS,
        side: BorderSide(
          color: lightTheme ? extension.primaryNormal : extension.primaryTone,
        ),
      ),
      child: InkWell(
        borderRadius: CIRCULAR_BORDER_RADIUS,
        onTap: () async {
          final ClipboardData? data = await Clipboard.getData('text/plain');
          if (data?.text?.isNotEmpty == true) {
            onData(data!.text!);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SmoothFloatingSnackbar(
                content: Text(localizations.no_data_available_in_clipboard),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: SMALL_SPACE,
            horizontal: LARGE_SPACE,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const icons.Clipboard.right(size: 22.0),
              const SizedBox(width: MEDIUM_SPACE),
              Text(
                localizations.paste_from_clipboard,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inserted: the room opens, then the item slides in from the start.
/// Removed (the animation runs backwards): the item slides out to the end,
/// then its room closes.
class _SlideTransition extends StatelessWidget {
  const _SlideTransition({
    required this.animation,
    required this.child,
    this.removed = false,
  });

  final Animation<double> animation;
  final Widget child;
  final bool removed;

  @override
  Widget build(BuildContext context) {
    final Animation<double> size = animation.drive(
      CurveTween(curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    // Not a SizeTransition: it clips the shadow of the cards. No clip is
    // needed, as the item is out of sight while its room opens or closes.
    return AnimatedBuilder(
      animation: size,
      builder: (BuildContext context, Widget? child) => Align(
        alignment: Alignment.topCenter,
        heightFactor: size.value,
        child: child,
      ),
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: Offset(removed ? 1.0 : -1.0, 0.0),
            end: Offset.zero,
          ).chain(
            CurveTween(
              curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
            ),
          ),
        ),
        textDirection: Directionality.of(context),
        child: child,
      ),
    );
  }
}
