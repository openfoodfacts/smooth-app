import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/edit_ingredients_page.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatefulWidget {
  const EditProductPage(this.product);

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  int _changes = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          getProductName(widget.product, appLocalizations),
          maxLines: 2,
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // cf. https://stackoverflow.com/questions/51927885/flutter-back-button-with-return-data
          // we want the same returned value for the app back button and the android back button
          final bool result = _changes > 0;
          Navigator.pop(context, result);
          return result;
        },
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                appLocalizations.edit_product_form_item_barcode,
              ),
              subtitle: widget.product.barcode == null
                  ? null
                  : Text(widget.product.barcode!),
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_details_title,
              subtitle:
                  appLocalizations.edit_product_form_item_details_subtitle,
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_photos_title,
              subtitle: appLocalizations.edit_product_form_item_photos_subtitle,
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_labels_title,
              subtitle: appLocalizations.edit_product_form_item_labels_subtitle,
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_ingredients_title,
              onTap: () async {
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => EditIngredientsPage(
                      product: widget.product,
                    ),
                  ),
                );
                if (refreshed ?? false) {
                  _changes++;
                }
              },
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_packaging_title,
            ),
            _ListTitleItem(
              title:
                  appLocalizations.edit_product_form_item_nutrition_facts_title,
              subtitle: appLocalizations
                  .edit_product_form_item_nutrition_facts_subtitle,
              onTap: () async {
                final OrderedNutrientsCache? cache =
                    await OrderedNutrientsCache.getCache(context);
                if (cache == null) {
                  return;
                }
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => NutritionPageLoaded(
                      widget.product,
                      cache.orderedNutrients,
                    ),
                  ),
                );
                if (refreshed ?? false) {
                  _changes++;
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class _ListTitleItem extends StatelessWidget {
  const _ListTitleItem({
    required final this.title,
    this.subtitle,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: ElevatedButton(
        child: Text(appLocalizations!.edit_product_form_save),
        onPressed: onTap,
      ),
    );
  }
}
