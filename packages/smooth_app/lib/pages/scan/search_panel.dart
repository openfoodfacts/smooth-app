import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/search_history.dart';
import 'package:smooth_app/pages/choose_page.dart';

class SearchPanel extends StatefulWidget {
  @override
  State<SearchPanel> createState() => SearchPanelState();
}

class SearchPanelState extends State<SearchPanel> {
  final FocusNode _searchFieldFocusNode = FocusNode();
  final PanelController _controller = PanelController();
  double _position = 0.0;

  bool get _isOpen => _position > _isOpenThreshold;
  static const double _isOpenThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _searchFieldFocusNode.addListener(() {
      if (_searchFieldFocusNode.hasFocus) {
        _controller.open();
      } else {
        _controller.close();
      }
    });
  }

  @override
  void dispose() {
    _searchFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    const double minHeight = 160.0;
    final double maxHeight = constraints.maxHeight;
    return SlidingUpPanel(
      controller: _controller,
      borderRadius: BorderRadius.vertical(
        top: _isOpen ? Radius.zero : const Radius.circular(20.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: _isOpen ? 0.0 : 12.0),
      onPanelSlide: _handlePanelSlide,
      panelBuilder: (ScrollController scrollController) {
        const double textBoxHeight = 44.0;
        final Widget textBox = SizedBox(
          height: textBoxHeight,
          child: Container(
            padding: const EdgeInsets.only(bottom: 22.0),
            child: Text(
              localizations.searchPanelHeader,
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
        );
        final double searchBoxHeight =
            _isOpen ? minHeight - textBoxHeight : minHeight;
        final Widget searchBox = SizedBox(
          height: searchBoxHeight,
          child: Column(children: <Widget>[
            const SizedBox(height: 25.0),
            if (!_isOpen) textBox,
            Container(
              // A key is required to preserve state when the above container
              // disappears from the tree.
              key: const Key('searchField'),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSearchField(context),
            ),
          ]),
        );
        return Column(
          children: <Widget>[
            searchBox,
            SearchHistoryView(
              height: maxHeight - searchBoxHeight,
              scrollController: scrollController,
              onTap: _performSearch,
            ),
          ],
        );
      },
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return TextField(
      focusNode: _searchFieldFocusNode,
      onSubmitted: _performSearch,
      decoration: InputDecoration(
        fillColor: Colors.grey.shade300,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20.0),
        hintText: localizations.search,
      ),
      style: const TextStyle(fontSize: 24.0),
    );
  }

  void _handlePanelSlide(double newPosition) {
    if (newPosition < _position && !_isOpen) {
      _searchFieldFocusNode.unfocus();
    }
    if (newPosition > _position && _isOpen) {
      _searchFieldFocusNode.requestFocus();
    }
    setState(() {
      _position = newPosition;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      return;
    }
    final SearchHistory history = context.read<SearchHistory>();
    history.add(query);
    ChoosePage.onSubmitted(
      query,
      context,
      context.read<LocalDatabase>(),
    );
  }
}

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
    final List<String> queries = await history.getAllQueries();
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
