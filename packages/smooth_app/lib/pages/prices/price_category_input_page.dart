import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/input/smooth_autocomplete_text_field.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

const EdgeInsets _fieldPadding = EdgeInsets.symmetric(
  horizontal: LARGE_SPACE,
  vertical: MEDIUM_SPACE,
);
const BorderRadius _borderRadius = CIRCULAR_BORDER_RADIUS;

/// Page that lets the user type in and select a single category for prices.
class PriceCategoryInputPage extends StatefulWidget {
  const PriceCategoryInputPage();

  @override
  State<PriceCategoryInputPage> createState() => _PriceCategoryInputPageState();
}

class _PriceCategoryInputPageState extends State<PriceCategoryInputPage> {
  late final TextEditingController _categoryController;
  late final TextEditingController _originController;

  String? _categoryName;
  final List<String> _originNames = <String>[];
  bool _hasChanged = false;

  late final VoidCallback _changes;

  @override
  void initState() {
    super.initState();
    _changes = () {
      _hasChanged = true;
    };
    _categoryController = TextEditingController();
    _categoryController.addListener(_changes);
    _originController = TextEditingController();
    _originController.addListener(_changes);
  }

  @override
  void dispose() {
    _categoryController.removeListener(_changes);
    _categoryController.dispose();
    _originController.removeListener(_changes);
    _originController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope2(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        fixKeyboard: true,
        appBar: AppBar(
          title: Text(appLocalizations.prices_category_enter),
        ),
        body: Padding(
          padding: const EdgeInsets.all(SMALL_SPACE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SMALL_SPACE,
            children: <Widget>[
              Text(appLocalizations.prices_category_mandatory),
              if (_categoryName == null)
                _MyAutocomplete(
                  helper: SimpleInputPageCategoryHelper(),
                  controller: _categoryController,
                  onSelected: (final String selected) => setState(
                    () => _categoryName = selected,
                  ),
                )
              else
                _ReadOnlyTextField(_categoryName!),
              const Divider(),
              Text(appLocalizations.prices_category_optional),
              for (final String name in _originNames) _ReadOnlyTextField(name),
              _MyAutocomplete(
                helper: SimpleInputPageOriginHelper(),
                controller: _originController,
                onSelected: (final String selected) => setState(
                  () {
                    _originController.text = '';
                    _originNames.add(selected);
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text(appLocalizations.prices_add_an_item),
          icon: const Icon(Icons.add),
          onPressed: _categoryName == null
              ? null
              : () async {
                  final (bool, PriceMetaProduct?) result =
                      await _mayExitPage(saving: true);
                  if (result.$1) {
                    if (context.mounted) {
                      Navigator.of(context).pop(result.$2);
                    }
                  }
                },
        ),
      ),
    );
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<(bool, PriceMetaProduct?)> _mayExitPage({
    required final bool saving,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!_hasChanged) {
      if (saving) {
        Navigator.of(context).pop();
      }
      return (true, null);
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(
        context,
        title: appLocalizations.prices_category_enter,
      );
      if (pleaseSave == null) {
        return (false, null);
      }
      if (pleaseSave == false) {
        return (true, null);
      }
      if (!mounted) {
        return (false, null);
      }
    }

    if (_categoryName == null) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothSimpleErrorAlertDialog(
          title: appLocalizations.prices_category_enter,
          message: appLocalizations.prices_category_error_mandatory,
        ),
      );
      return (false, null);
    }
    if (!mounted) {
      return (false, null);
    }

    return (
      true,
      PriceMetaProduct.category(
        categoryName: _categoryName!,
        originNames: _originNames,
        language: ProductQuery.getLanguage(),
      ),
    );
  }
}

class _MyAutocomplete extends StatefulWidget {
  const _MyAutocomplete({
    required this.helper,
    required this.controller,
    required this.onSelected,
  });

  final AbstractSimpleInputPageHelper helper;
  final TextEditingController controller;
  final Function(String) onSelected;

  @override
  State<_MyAutocomplete> createState() => _MyAutocompleteState();
}

class _MyAutocompleteState extends State<_MyAutocomplete> {
  final Key _autocompleteKey = UniqueKey();
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (
          _,
          BoxConstraints constraints,
        ) =>
            SmoothAutocompleteTextField(
          autocompleteKey: _autocompleteKey,
          focusNode: _focusNode,
          constraints: constraints,
          onSelected: widget.onSelected,
          manager: AutocompleteManager(
            TagTypeAutocompleter(
              tagType: widget.helper.getTagType()!,
              language: ProductQuery.getLanguage(),
              country: ProductQuery.getCountry(),
              categories: null,
              shape: null,
              user: ProductQuery.getReadUser(),
              limit: 15,
              uriHelper: ProductQuery.getUriProductHelper(
                productType: ProductType.food,
              ),
            ),
          ),
          textCapitalization: widget.helper.getTextCapitalization(),
          allowEmojis: widget.helper.getAllowEmojis(),
          hintText: widget.helper.getAddHint(AppLocalizations.of(context)),
          controller: widget.controller,
          padding: _fieldPadding,
          borderRadius: _borderRadius,
        ),
      );
}

class _ReadOnlyTextField extends StatefulWidget {
  const _ReadOnlyTextField(this.name);

  final String name;

  @override
  State<_ReadOnlyTextField> createState() => _ReadOnlyTextFieldState();
}

class _ReadOnlyTextFieldState extends State<_ReadOnlyTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      enabled: true,
      decoration: const InputDecoration(
        contentPadding: _fieldPadding,
        isDense: true,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 5.0,
          ),
        ),
      ),
    );
  }
}
