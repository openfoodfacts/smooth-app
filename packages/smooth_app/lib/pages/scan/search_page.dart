import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/keywords_product_query.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_app/pages/scan/search_history_view.dart';

void _performSearch(BuildContext context, String query) {
  if (query.trim().isEmpty) {
    return;
  }
  final LocalDatabase localDatabase = context.read<LocalDatabase>();
  DaoStringList(localDatabase).add(query);
  if (int.tryParse(query) != null) {
    _onSubmittedBarcode(
      query,
      context,
      localDatabase,
    );
  } else {
    _onSubmittedText(
      query,
      context,
      localDatabase,
    );
  }
}

// used to be in now defunct `ChoosePage`
Future<void> _onSubmittedBarcode(
  final String value,
  final BuildContext context,
  final LocalDatabase localDatabase,
) async {
  final ProductDialogHelper productDialogHelper = ProductDialogHelper(
    barcode: value,
    context: context,
    localDatabase: localDatabase,
    refresh: false,
  );
  final FetchedProduct fetchedProduct =
      await productDialogHelper.openBestChoice();
  if (fetchedProduct.status == FetchedProductStatus.ok) {
    AnalyticsHelper.trackSearch(
      search: value,
      searchCategory: 'barcode',
      searchCount: 1,
    );

    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ProductPage(fetchedProduct.product!),
      ),
    );
  } else {
    AnalyticsHelper.trackSearch(
      search: value,
      searchCategory: 'barcode',
      searchCount: 0,
    );
    productDialogHelper.openError(fetchedProduct);
  }
}

// used to be in now defunct `ChoosePage`
Future<void> _onSubmittedText(
  final String value,
  final BuildContext context,
  final LocalDatabase localDatabase,
) async =>
    ProductQueryPageHelper().openBestChoice(
      color: Colors.deepPurple,
      heroTag: 'search_bar',
      name: value,
      localDatabase: localDatabase,
      productQuery: KeywordsProductQuery(keywords: value, size: 500),
      context: context,
    );

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
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return TextField(
      textInputAction: TextInputAction.search,
      controller: _textController,
      focusNode: _focusNode,
      onSubmitted: (String query) => _performSearch(context, query),
      decoration: InputDecoration(
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: CIRCULAR_BORDER_RADIUS,
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
    //Only rebuild the widget if the text length is 0 or 1 as we only check if
    //the text length is empty or not
    if (_textController.text.isEmpty || _textController.text.length == 1) {
      setState(() {
        _isEmpty = _textController.text.isEmpty;
      });
    }
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
