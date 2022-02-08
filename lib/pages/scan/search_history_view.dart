import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';

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
      onDismissed: (DismissDirection direction) =>
          _handleDismissed(context, query),
      background: Container(color: Colors.red),
      child: ListTile(
        leading: const SizedBox(
          height: double.infinity, // Vertically center the icon.
          child: Icon(Icons.search, size: 18.0),
        ),
        minLeadingWidth: 10,
        title: Text(query, style: const TextStyle(fontSize: 20.0)),
        onTap: () => widget.onTap?.call(query),
      ),
    );
  }

  Future<void> _handleDismissed(BuildContext context, String query) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoStringList(localDatabase).remove(query);
    setState(() {});
  }
}
