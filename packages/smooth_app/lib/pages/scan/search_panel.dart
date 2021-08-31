import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smooth_app/database/local_database.dart';
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
    return SlidingUpPanel(
      controller: _controller,
      borderRadius: BorderRadius.vertical(
        top: _isOpen ? Radius.zero : const Radius.circular(20.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: _isOpen ? 0.0 : 12.0),
      onPanelSlide: _handlePanelSlide,
      panel: Column(
        children: <Widget>[
          const SizedBox(height: 25.0),
          if (!_isOpen)
            Container(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: Text(localizations.searchPanelHeader),
            ),
          Container(
            // A key is required to preserve state when the above container
            // disappears from the tree.
            key: const Key('searchField'),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchField(context),
          )
        ],
      ),
      minHeight: 150.0,
      maxHeight: constraints.maxHeight,
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
    ChoosePage.onSubmitted(
      query,
      context,
      context.read<LocalDatabase>(),
    );
  }
}
