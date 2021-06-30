import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/smooth_chip.dart';

class ProductListButton extends StatelessWidget {
  const ProductListButton({
    required this.productList,
    required this.onPressed,
  }) : onlyIcon = false;

  const ProductListButton.add({
    required this.onPressed,
    required this.onlyIcon,
  }) : productList = null;

  final ProductList? productList;
  final Function onPressed;
  final bool onlyIcon;

  @override
  Widget build(BuildContext context) {
    if (productList == null) {
      return SmoothChip(
        onPressed: onPressed,
        iconData: Icons.add,
        label: onlyIcon ? null : AppLocalizations.of(context)!.new_list,
        shape: _shape,
      );
    }
    return SmoothChip(
      onPressed: onPressed,
      iconData: productList!.iconData,
      label: ProductQueryPageHelper.getProductListLabel(
        productList!,
        context,
        verbose: false,
      ),
      materialColor: productList!.getMaterialColor(),
      shape: _shape,
    );
  }

  static final OutlinedBorder _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(32.0),
  );
}
