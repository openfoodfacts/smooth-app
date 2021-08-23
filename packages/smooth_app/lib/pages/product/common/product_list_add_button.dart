import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/product/common/smooth_chip.dart';

/// "Add button" related to a user product list type
class ProductListAddButton extends StatelessWidget {
  const ProductListAddButton({
    required this.onPressed,
    required this.onlyIcon,
    required this.productListType,
  });

  final VoidCallback onPressed;
  final bool onlyIcon;
  final String productListType;

  @override
  Widget build(BuildContext context) => SmoothChip(
        onPressed: onPressed,
        iconData: Icons.add,
        label: onlyIcon
            ? null
            : ProductQueryPageHelper.getCreateListLabel(
                productListType,
                AppLocalizations.of(context)!,
              ),
        shape: ProductQueryPageHelper.getShape(productListType),
      );
}
