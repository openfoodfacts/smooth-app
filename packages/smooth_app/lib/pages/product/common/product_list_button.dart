import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class ProductListButton extends StatelessWidget {
  const ProductListButton({
    @required this.productList,
    @required this.onPressed,
  });

  const ProductListButton.add({
    @required this.onPressed,
  }) : productList = null;

  final ProductList productList;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    if (productList == null) {
      return _build(
        const Icon(Icons.add),
        Flexible(
          child: Text(
            AppLocalizations.of(context).new_list,
            overflow: TextOverflow.fade,
          ),
        ),
        null,
      );
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return _build(
      productList.getIcon(
        colorScheme,
        ColorDestination.BUTTON_FOREGROUND,
      ),
      Text(
        ProductQueryPageHelper.getProductListLabel(
          productList,
          context,
          verbose: false,
        ),
        style: TextStyle(
          color: SmoothTheme.getColor(
            colorScheme,
            productList.getMaterialColor(),
            ColorDestination.BUTTON_FOREGROUND,
          ),
        ),
      ),
      SmoothTheme.getColor(
        colorScheme,
        productList.getMaterialColor(),
        ColorDestination.BUTTON_BACKGROUND,
      ),
    );
  }

  Widget _build(
    final Widget icon,
    final Widget label,
    final Color primary,
  ) =>
      ElevatedButton.icon(
        icon: icon,
        label: label,
        onPressed: () async => await onPressed(),
        style: ElevatedButton.styleFrom(
          primary: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
      );
}
