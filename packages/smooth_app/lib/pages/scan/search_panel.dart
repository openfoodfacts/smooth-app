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
  final PanelController _controller = PanelController();
  final FocusNode _focusNode = FocusNode();
  double _position = 0.0;

  static const double _IS_OPEN_THRESHOLD = 0.5;
  bool get _isOpen => _position > _IS_OPEN_THRESHOLD;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.open();
      } else {
        _controller.close();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _build);
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {
    return SlidingUpPanel(
      controller: _controller,
      borderRadius: BorderRadius.vertical(
        top: _isOpen ? Radius.zero : const Radius.circular(20.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: _isOpen ? 0.0 : 12.0),
      onPanelSlide: _onPanelSlide,
      panel: Column(
        children: <Widget>[
          const SizedBox(height: 25.0),
          if (!_isOpen)
            Container(
              padding: const EdgeInsets.only(bottom: 22.0),
              child: const Text('Search or scan your first product'),
            ),
          Container(
            // A key is required to preserve state when the above container is
            // disappears from the tree.
            key: const Key('input'),
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
      focusNode: _focusNode,
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

  void _onPanelSlide(double newPosition) {
    if (newPosition < _position && !_isOpen) {
      FocusScope.of(context).unfocus();
    }
    if (newPosition > _position && _isOpen) {
      _focusNode.requestFocus();
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
