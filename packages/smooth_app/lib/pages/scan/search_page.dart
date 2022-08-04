import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/new_product_page.dart';
import 'package:smooth_app/pages/scan/search_history_view.dart';
import 'package:smooth_app/query/keywords_product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
  // https://github.com/openfoodfacts/smooth-app/pull/2219
  final TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
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
}

class SearchField extends StatefulWidget {
  const SearchField({
    this.autofocus = false,
    this.showClearButton = true,
    this.readOnly = false,
    this.onFocus,
    this.backgroundColor,
    this.foregroundColor,
  });

  final bool autofocus;
  final bool showClearButton;

  /// If true, the Widget will only display the UI
  final bool readOnly;
  final void Function()? onFocus;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;

  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);

    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      _controller = Provider.of<TextEditingController>(context);
    } catch (err) {
      _controller = TextEditingController();
    }

    _controller.removeListener(_handleTextChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    try {
      _controller = Provider.of<TextEditingController>(context);
    } catch (err) {
      _controller = TextEditingController();
    }

    final InputDecoration inputDecoration = InputDecoration(
      fillColor: widget.backgroundColor,
      labelStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
            color: widget.foregroundColor,
          ),
      filled: true,
      border: const OutlineInputBorder(
        borderRadius: CIRCULAR_BORDER_RADIUS,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 17.0,
      ),
      hintText: localizations.search,
      suffixIcon: widget.showClearButton ? _buildClearButton() : null,
    );

    const TextStyle textStyle = TextStyle(fontSize: 18.0);

    if (widget.readOnly) {
      return InkWell(
        borderRadius: CIRCULAR_BORDER_RADIUS,
        splashColor: Theme.of(context).primaryColor,
        onTap: () {
          widget.onFocus?.call();
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : null,
          ),
          child: InputDecorator(
            decoration: inputDecoration,
            child: Text(
              inputDecoration.hintText!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).hintColor)
                  .merge(textStyle),
            ),
          ),
        ),
      );
    } else {
      return TextField(
        textInputAction: TextInputAction.search,
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: (String query) => _performSearch(context, query),
        decoration: inputDecoration,
        style: textStyle,
      );
    }
  }

  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: MEDIUM_SPACE),
      child: IconButton(
        onPressed: _handleClear,
        icon: AnimatedCrossFade(
          duration: SmoothAnimationsDuration.brief,
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
    if (_controller.text.isEmpty || _controller.text.length == 1) {
      setState(() {
        _isEmpty = _controller.text.isEmpty;
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
      _controller.clear();
    }
  }
}
