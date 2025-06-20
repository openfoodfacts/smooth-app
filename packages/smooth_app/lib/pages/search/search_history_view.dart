import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/pages/product/common/search_preloaded_item.dart';

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
    final List<String> queries =
        widget.searchHelper.getAllQueries(localDatabase);
    setState(() => _queries = queries);
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: ListTileThemeData(
        titleTextStyle: const TextStyle(fontSize: 18.0),
        minLeadingWidth: 10.0,
        iconColor: Theme.of(context).colorScheme.onSurface,
        textColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int i) {
          if (i == 0) {
            return _SearchItemPasteFromClipboard(
              onData: (String data) => widget.onTap.call(data),
            );
          }
          i--;

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
            onTap: () => widget.onTap.call(query),
            onEditItem: () => _onEditItem(query),
            onDismissItem: () async {
              // we need an immediate action for the display refresh
              _queries.remove(query);
              // and we need to impact the database too
              final LocalDatabase localDatabase = context.read<LocalDatabase>();
              await widget.searchHelper.removeQuery(localDatabase, query);
              setState(() {});
            },
          );
        },
        itemCount: _queries.length +
            widget.preloadedList.length +
            1, // +1 for the "Copy from clipboard"
      ),
    );
  }

  void _onEditItem(String query) {
    final TextEditingController controller = Provider.of<TextEditingController>(
      context,
      listen: false,
    );

    controller.text = query;
    controller.selection =
        TextSelection.fromPosition(TextPosition(offset: query.length));

    // If the keyboard is hidden, show it.
    if (View.of(context).viewInsets.bottom == 0) {
      widget.focusNode.unfocus();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(widget.focusNode);
      });
    }
  }
}

class _SearchHistoryTile extends StatelessWidget {
  const _SearchHistoryTile({
    required this.query,
    required this.onTap,
    required this.onEditItem,
    required this.onDismissItem,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onEditItem;
  final VoidCallback onDismissItem;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Dismissible(
      key: Key(query),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) async => onDismissItem(),
      background: Container(
        color: RED_COLOR,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: LARGE_SPACE * 2),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8.0),
          child: ListTile(
            leading: const Padding(
              padding: EdgeInsetsDirectional.only(top: VERY_SMALL_SPACE),
              child: Icon(
                Icons.search,
              ),
            ),
            trailing: InkWell(
              customBorder: const CircleBorder(),
              onTap: onEditItem,
              child: Tooltip(
                message: localizations.search_history_item_edit_tooltip,
                enableFeedback: true,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, size: 18.0),
                ),
              ),
            ),
            minLeadingWidth: 10.0,
            title: Text(query),
          ),
        ),
      ),
    );
  }
}

class _SearchItemPasteFromClipboard extends StatelessWidget {
  const _SearchItemPasteFromClipboard({
    required this.onData,
  });

  final Function(String) onData;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return InkWell(
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
        padding: const EdgeInsetsDirectional.only(start: 8.0, end: 13.0),
        child: ListTile(
          title: Text(localizations.paste_from_clipboard),
          leading: const Icon(Icons.copy),
          minLeadingWidth: 10.0,
        ),
      ),
    );
  }
}
