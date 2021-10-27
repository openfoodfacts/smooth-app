import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/search_history.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/scan/search_history_view.dart';

void _performSearch(BuildContext context, String query) {
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

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: SearchField(autofocus: true),
          ),
          Expanded(
            child: SearchHistoryView(
              onTap: (String query) => _performSearch(context, query),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  const SearchField({
    this.autofocus = false,
    this.showClearButton = true,
    this.onFocus,
  });

  final bool autofocus;
  final bool showClearButton;
  final void Function()? onFocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEmpty = true;

  static const Duration _animationDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return TextField(
      textInputAction: TextInputAction.search,
      controller: _textController,
      focusNode: _focusNode,
      onSubmitted: (String query) => _performSearch(context, query),
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20.0),
        hintText: localizations.search,
        suffixIcon: widget.showClearButton ? _buildClearButton() : null,
      ),
      style: const TextStyle(fontSize: 24.0),
    );
  }

  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: IconButton(
        onPressed: _handleClear,
        icon: AnimatedCrossFade(
          duration: _animationDuration,
          crossFadeState:
              _isEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          // Closes the page.
          firstChild: const Icon(Icons.close),
          // Clears the text.
          secondChild: const Icon(Icons.cancel),
        ),
      ),
    );
  }

  void _handleTextChange() {
    setState(() {
      _isEmpty = _textController.text.isEmpty;
    });
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && widget.onFocus != null) {
      _focusNode.unfocus();
      widget.onFocus?.call();
    }
  }

  void _handleClear() {
    if (_isEmpty) {
      Navigator.pop(context);
    } else {
      _textController.clear();
    }
  }
}
