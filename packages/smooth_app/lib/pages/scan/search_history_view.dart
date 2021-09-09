import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/search_history.dart';

class SearchHistoryView extends StatefulWidget {
  const SearchHistoryView({
    this.height,
    this.scrollController,
    this.onTap,
  });

  final double? height;
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
    final SearchHistory history = context.watch<SearchHistory>();
    final List<String> queries = await history.getAll();
    setState(() {
      _queries = queries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: _queries.length,
        itemBuilder: (BuildContext context, int i) =>
            _buildSearchHistoryTile(context, _queries[i]),
      ),
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
    setState(() {
      _queries.remove(query);
    });
    final SearchHistory history = context.read<SearchHistory>();
    await history.remove(query);
  }
}
