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
    //ignore: use_build_context_synchronously
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
      productQuery: KeywordsProductQuery(value),
      context: context,
    );

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      body: ChangeNotifierProvider<TextEditingController>(
        create: (_) => _searchTextController,
        child: Column(
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
      ),
    );
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }
}

class SearchField extends StatefulWidget {
  const SearchField({
    this.autofocus = false,
    this.showClearButton = true,
    this.onFocus,
    this.backgroundColor,
    this.foregroundColor,
  });

  final bool autofocus;
  final bool showClearButton;
  final void Function()? onFocus;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final FocusNode _focusNode = FocusNode();
  bool _isEmpty = true;

  static const Duration _animationDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    TextEditingController controller;

    try {
      controller = Provider.of<TextEditingController>(context);
    } catch (err) {
      controller = TextEditingController();
    }

    return TextField(
      textInputAction: TextInputAction.search,
      controller: controller,
      focusNode: _focusNode,
      onSubmitted: (String query) => _performSearch(context, query),
      decoration: InputDecoration(
        fillColor: widget.backgroundColor,
        labelStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
              color: widget.foregroundColor,
            ),
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: CIRCULAR_BORDER_RADIUS,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20.0),
        hintText: localizations.search,
        suffixIcon:
            widget.showClearButton ? _buildClearButton(controller) : null,
      ),
      style: const TextStyle(fontSize: 24.0),
    );
  }

  Widget _buildClearButton(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: IconButton(
        onPressed: () => _handleClear(controller),
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

  void _handleTextChange(TextEditingController textController) {
    //Only rebuild the widget if the text length is 0 or 1 as we only check if
    //the text length is empty or not
    if (textController.text.isEmpty || textController.text.length == 1) {
      setState(() {
        _isEmpty = textController.text.isEmpty;
      });
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && widget.onFocus != null) {
      _focusNode.unfocus();
      widget.onFocus?.call();
    }
  }

  void _handleClear(TextEditingController textController) {
    if (_isEmpty) {
      Navigator.pop(context);
    } else {
      textController.clear();
    }
  }
}
