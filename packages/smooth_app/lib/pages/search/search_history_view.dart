import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/pages/product/common/search_preloaded_item.dart';
import 'package:smooth_app/pages/search/search_hint.dart';
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
  List<String> _queries = <String>[];

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
    final int count = _queries.length + widget.preloadedList.length;
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

    return ListTileTheme(
      data: ListTileThemeData(
        titleTextStyle: const TextStyle(fontSize: 18.0),
        minLeadingWidth: 10.0,
        iconColor: theme.colorScheme.onSurface,
        textColor: theme.colorScheme.onSurface,
      ),
      child: Column(
        children: <Widget>[
          const _SearchHistoryTitle(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsetsDirectional.zero,
              itemBuilder: (BuildContext context, int i) {
                if (i < widget.preloadedList.length) {
                  final SearchPreloadedItem item = widget.preloadedList[i];
                  return item.getWidget(
                    context,
                    onDismissItem: () async {
                      // we need an immediate action for the display refresh
                      widget.preloadedList.removeAt(i);
                      // and we need to impact the database too
                      await item.delete(context);

                      setState(() {});
                    },
                  );
                }
                i -= widget.preloadedList.length;

                final String query = _queries[i];
                return _SearchHistoryTile(
                  query: query,
                  bottomBorder: i < _queries.length - 1,
                  onTap: () => widget.onTap.call(query),
                  onEditItem: () => _onEditItem(query),
                  onRemoveItem: () async {
                    // we need an immediate action for the display refresh
                    _queries.remove(query);
                    // and we need to impact the database too
                    final LocalDatabase localDatabase = context
                        .read<LocalDatabase>();
                    await widget.searchHelper.removeQuery(localDatabase, query);
                    setState(() {});
                  },
                );
              },
              itemCount: count,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              bottom: math.max(
                MediaQuery.viewPaddingOf(context).bottom,
                MediaQuery.viewInsetsOf(context).bottom,
              ),
            ),
            child: _SearchItemPasteFromClipboard(
              onData: (String data) => widget.onTap.call(data),
            ),
          ),
        ],
      ),
    );
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
  const _SearchHistoryTitle();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: LARGE_SPACE,
          bottom: VERY_SMALL_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: ANGULAR_BORDER_RADIUS,
            color: theme.primaryMedium,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SMALL_SPACE,
              vertical: BALANCED_SPACE,
            ),
            child: Text(
              AppLocalizations.of(context).search_history,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.primaryBlack,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
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
    this.bottomBorder = true,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onEditItem;
  final VoidCallback onRemoveItem;
  final bool bottomBorder;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final Color color = lightTheme ? theme.primaryBlack : theme.primaryMedium;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 23.0,
          end: LARGE_SPACE,
        ),
        child: Ink(
          decoration: BoxDecoration(
            border: bottomBorder
                ? DashedBorder(
                    dashLength: 3.0,
                    spaceLength: 3.0,
                    bottom: BorderSide(color: theme.primaryMedium),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 2.0, bottom: 2.0),
            child: IconButtonTheme(
              data: IconButtonThemeData(
                style: IconButton.styleFrom(
                  backgroundColor: theme.primaryMedium,
                  foregroundColor: theme.primaryBlack,
                  minimumSize: const Size(18.0, 18.0),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SmoothCircle.indicator(color: color, size: 10.0),
                  const SizedBox(width: BALANCED_SPACE),
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
                    icon: const icons.Edit(size: 15.0),
                  ),
                ],
              ),
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
      color: lightTheme ? extension.primaryLight : extension.primaryDark,
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
