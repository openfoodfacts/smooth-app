import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';

class ProductTitleCard extends StatelessWidget {
  const ProductTitleCard(
    this.product,
    this.isSelectable, {
    this.dense = false,
    this.isRemovable = true,
    this.onRemove,
  });

  final Product product;
  final bool dense;
  final bool isSelectable;
  final bool isRemovable;
  final OnRemoveCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final String subtitleText;
    final Widget trailingWidget;
    final String brands = getProductBrands(product, appLocalizations);
    final String quantity = product.quantity ?? '';

    if (isRemovable && !isSelectable) {
      subtitleText = '$brands${quantity == '' ? '' : ', $quantity'}';
      trailingWidget = InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onRemove?.call(context),
        child: Tooltip(
          message: appLocalizations.product_card_remove_product_tooltip,
          child: const Padding(
            padding: EdgeInsets.all(SMALL_SPACE),
            child: Icon(
              Icons.clear_rounded,
              size: DEFAULT_ICON_SIZE,
            ),
          ),
        ),
      );
    } else {
      subtitleText = brands;
      trailingWidget = Text(
        quantity,
        style: themeData.textTheme.headline3,
      ).selectable(isSelectable: isSelectable);
    }
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: InkWell(
        onTap: (getProductName(product, appLocalizations) ==
                appLocalizations.unknownProductName)
            ? () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        AddBasicDetailsPage(product),
                  ),
                );
              }
            : null,
        child: ListTile(
          dense: dense,
          contentPadding: EdgeInsets.zero,
          title: Text(
            getProductName(product, appLocalizations),
            style: themeData.textTheme.headline4,
          ).selectable(isSelectable: isSelectable),
          subtitle: Text(
            subtitleText,
          ).selectable(isSelectable: isSelectable),
          trailing: trailingWidget,
        ),
      ),
    );
  }
}

typedef OnRemoveCallback = void Function(BuildContext context);
