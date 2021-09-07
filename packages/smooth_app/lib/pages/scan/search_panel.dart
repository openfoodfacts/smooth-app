import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/search_history.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/scan/search_history_view.dart';

class SearchPanel extends StatefulWidget {
  @override
  State<SearchPanel> createState() => SearchPanelState();
}

class SearchPanelState extends State<SearchPanel> {
  final TextEditingController _searchFieldController = TextEditingController();
  final FocusNode _searchFieldFocusNode = FocusNode();
  final PanelController _panelController = PanelController();
  double _position = 0.0;
  bool _isEmpty = true;

  bool get _isOpen => _position > _isOpenThreshold;
  static const double _isOpenThreshold = 0.5;

  static const Duration _animationDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _searchFieldController.addListener(_handleTextChange);
    _searchFieldFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
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
      controller: _panelController,
      borderRadius: BorderRadius.vertical(
        top: _isOpen ? Radius.zero : const Radius.circular(20.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: _isOpen ? 0.0 : 12.0),
      onPanelSlide: _handlePanelSlide,
      panelBuilder: (ScrollController scrollController) {
        const double textBoxHeight = 40.0;
        final double searchBoxHeight =
            _isOpen ? minHeight - textBoxHeight : minHeight;
        final Widget searchBox = SizedOverflowBox(
          size: Size.fromHeight(searchBoxHeight),
          alignment: Alignment.topCenter,
          child: Column(children: <Widget>[
            const SizedBox(height: 25.0),
            AnimatedCrossFade(
              duration: _animationDuration,
              crossFadeState: _isOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(),
              secondChild: Container(
                alignment: Alignment.topCenter,
                height: textBoxHeight,
                child: Text(
                  localizations.searchPanelHeader,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            Padding(
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
      textInputAction: TextInputAction.search,
      controller: _searchFieldController,
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
        suffixIcon: AnimatedOpacity(
          duration: _animationDuration,
          opacity: !_isEmpty || _isOpen ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: _handleClear,
              icon: AnimatedCrossFade(
                duration: _animationDuration,
                crossFadeState: _isEmpty
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: const Icon(Icons.cancel), // Closes the panel.
                secondChild: const Icon(Icons.clear), // Clears the text.
              ),
            ),
          ),
        ),
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

  void _handleTextChange() {
    setState(() {
      _isEmpty = _searchFieldController.text.isEmpty;
    });
  }

  void _handleFocusChange() {
    if (_searchFieldFocusNode.hasFocus) {
      _panelController.open();
    } else {
      _panelController.close();
    }
  }

  void _handleClear() {
    if (_isEmpty) {
      _panelController.close();
    } else {
      _searchFieldController.clear();
    }
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
