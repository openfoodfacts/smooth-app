import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SearchHistoryView extends StatefulWidget {
  const SearchHistoryView({
    this.scrollController,
    this.onTap,
  });

  final ScrollController? scrollController;
  final void Function(String)? onTap;

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

  Future<void> _fetchQueries() async {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final List<String> queries = await DaoStringList(localDatabase).getAll();
    setState(() => _queries = queries.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: _queries.length,
      itemBuilder: (BuildContext context, int i) =>
          _buildSearchHistoryTile(context, _queries[i]),
    );
  }

  Widget _buildSearchHistoryTile(BuildContext context, String query) {
    return Dismissible(
      key: Key(query),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) async =>
          _handleDismissed(context, query),
      background: Container(color: RED_COLOR),
      child: ListTile(
        leading: const Padding(
          padding: EdgeInsetsDirectional.only(top: VERY_SMALL_SPACE),
          child: Icon(Icons.search, size: 18.0),
        ),
        trailing: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            final TextEditingController controller =
                Provider.of<TextEditingController>(
              context,
              listen: false,
            );

            controller.text = query;
            controller.selection =
                TextSelection.fromPosition(TextPosition(offset: query.length));

            Focus.maybeOf(context)?.requestFocus();
          },
          child: const Padding(
            padding: EdgeInsets.all(SMALL_SPACE),
            child: Icon(Icons.edit, size: 18.0),
          ),
        ),
        minLeadingWidth: 10,
        title: Text(query, style: const TextStyle(fontSize: 20.0)),
        onTap: () => widget.onTap?.call(query),
      ),
    );
  }

  Future<void> _handleDismissed(BuildContext context, String query) async {
    // we need an immediate action for the display refresh
    _queries.remove(query);
    // and we need to impact the database too
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoStringList(localDatabase).remove(query);
    setState(() {});
  }
}
