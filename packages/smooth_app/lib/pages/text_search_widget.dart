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
    this.color,
    required this.daoProduct,
    this.addProductCallback,
  });

  /// Icon color
  final Color? color;
  final DaoProduct daoProduct;

  /// Callback after a product page is reached from the search, then pop'ed
  final Future<void> Function(Product product)? addProductCallback;

  @override
  _TextSearchWidgetState createState() => _TextSearchWidgetState();
}

class _TextSearchWidgetState extends State<TextSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  bool _visibleCloseButton = false;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return SmoothCard(
      child: TypeAheadField<Product?>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          autofocus: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(20.0),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _getIcon(Icons.search),
            ),
            suffixIcon: _getInvisibleIconButton(
              Icons.close,
              () => setState(
                () {
                  FocusScope.of(context).unfocus();
                  _searchController.text = '';
                  _visibleCloseButton = false;
                },
              ),
            ),
            border: InputBorder.none,
            hintText: appLocalizations.what_are_you_looking_for,
            hintStyle: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(fontWeight: FontWeight.w300),
          ),
        ),
        hideOnEmpty: true,
        hideOnLoading: true,
        suggestionsCallback: (String value) async => _search(value),
        transitionBuilder: (BuildContext context, Widget suggestionsBox,
                AnimationController? controller) =>
            suggestionsBox,
        itemBuilder: (BuildContext context, Product? suggestion) {
          if (suggestion == null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Click here for server search'),
                onPressed: () => ChoosePage.onSubmitted(
                  _searchController.text,
                  this.context, // careful, here use the "main" context and not the transient item context
                  widget.daoProduct.localDatabase,
                ),
              ),
            );
          }
          return ListTile(
            leading: SmoothProductImage(
              product: suggestion,
              width: screenSize.height / 10,
              height: screenSize.height / 10,
            ),
            title: Text(
              suggestion.productName ?? suggestion.barcode ?? 'Unknown',
            ),
            subtitle: Text('(local result) (${suggestion.barcode})'),
          );
        },
        onSuggestionSelected: (Product? suggestion) async {
          await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => ProductPage(
                product: suggestion!,
              ),
            ),
          );
          if (widget.addProductCallback != null) {
            widget.addProductCallback!(suggestion!);
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

  Future<List<Product?>> _search(String pattern) async {
    const int _MINIMUM_TEXT_SIZE = 3;
    final bool _oldVisibleCloseButton = _visibleCloseButton;
    _visibleCloseButton = pattern.isNotEmpty;
    if (_oldVisibleCloseButton != _visibleCloseButton) {
      setState(() {});
    }
    final List<Product?> result = <Product?>[];
    if (pattern.length < _MINIMUM_TEXT_SIZE) {
      return result;
    }
    result.add(null);
    result.addAll(
      await widget.daoProduct.getSuggestions(pattern, _MINIMUM_TEXT_SIZE),
    );
    return result;
  }
}
