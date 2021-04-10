import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_ui_library/widgets/smooth_product_image.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/pages/product/product_page.dart';
import 'package:smooth_app/pages/choose_page.dart';

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
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return SmoothCard(
      child: TypeAheadField<Product>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          autofocus: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(20.0),
            prefixIcon: _getIcon(Icons.search),
            suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
            border: InputBorder.none,
            hintText: 'What are you looking for?',
          ),
        ),
        hideOnEmpty: true,
        hideOnLoading: true,
        suggestionsCallback: (String value) async => _search(value),
        transitionBuilder: (BuildContext context, Widget suggestionsBox,
                AnimationController controller) =>
            suggestionsBox,
        itemBuilder: (BuildContext context, Product suggestion) => Container(
          height: screenSize.height / 10,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4),
                child: SmoothProductImage(
                  product: suggestion,
                  width: screenSize.height / 10,
                  height: screenSize.height / 10,
                ),
              ),
              SizedBox(
                width: screenSize.width / 40,
              ),
              Expanded(
                child: Text(
                  suggestion.productName ??
                      suggestion.productNameEN ??
                      suggestion.productNameFR ??
                      suggestion.productNameDE ??
                      suggestion.barcode,
                ),
              ),
            ],
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
      ),
    );
  }

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
