import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/pages/product/product_page.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Local product search by text
class TextSearchWidget extends StatefulWidget {
  const TextSearchWidget({
    @required this.color,
    @required this.daoProduct,
    this.addProductCallback,
  });

  /// Icon color
  final Color color;
  final DaoProduct daoProduct;

  /// Callback after a product page is reached from the search, then pop'ed
  final Future<void> Function(Product product) addProductCallback;

  @override
  _TextSearchWidgetState createState() => _TextSearchWidgetState();
}

class _TextSearchWidgetState extends State<TextSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  bool _visibleCloseButton = false;

  @override
  Widget build(BuildContext context) => SmoothCard(
        child: ListTile(
          leading: _getIcon(Icons.search),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: _getTextField(AppLocalizations.of(context))),
              _getInvisibleIconButton(
                CupertinoIcons.arrow_up_right,
                () => ChoosePage.onSubmitted(
                  _searchController.text,
                  context,
                  widget.daoProduct.localDatabase,
                ),
              ),
              _getInvisibleIconButton(
                Icons.close,
                () => setState(
                  () {
                    FocusScope.of(context).unfocus();
                    _searchController.text = '';
                    _visibleCloseButton = false;
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _getTextField(AppLocalizations appLocalizations) =>
      TypeAheadFormField<Product>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          autofocus: false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: appLocalizations.what_are_you_looking_for,
          ),
        ),
        hideOnEmpty: true,
        hideOnLoading: true,
        suggestionsCallback: (String value) async => _search(value),
        transitionBuilder: (BuildContext context, Widget suggestionsBox,
                AnimationController controller) =>
            suggestionsBox,
        itemBuilder: (BuildContext context, Product suggestion) => ListTile(
          title: Text(
            suggestion.productName ??
                suggestion.productNameEN ??
                suggestion.productNameFR ??
                suggestion.productNameDE ??
                suggestion.barcode,
          ),
          leading: SmoothProductImage(
            product: suggestion,
          ),
        ),
        onSuggestionSelected: (Product suggestion) async {
          await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => ProductPage(
                product: suggestion,
              ),
            ),
          );
          if (widget.addProductCallback != null) {
            widget.addProductCallback(suggestion);
          }
        },
      );

  Widget _getInvisibleIconButton(
    final IconData iconData,
    final void Function() onPressed,
  ) =>
      AnimatedOpacity(
        opacity: _visibleCloseButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 100),
        child: IgnorePointer(
          ignoring: !_visibleCloseButton,
          child: IconButton(icon: _getIcon(iconData), onPressed: onPressed),
        ),
      );

  Icon _getIcon(final IconData iconData) => Icon(iconData, color: widget.color);

  Future<List<Product>> _search(String pattern) async {
    final bool _oldVisibleCloseButton = _visibleCloseButton;
    _visibleCloseButton = pattern.isNotEmpty;
    if (_oldVisibleCloseButton != _visibleCloseButton) {
      setState(() {});
    }
    return await widget.daoProduct.getSuggestions(pattern, 3);
  }
}
