import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_ingredients_page.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatefulWidget {
  const EditProductPage(this.product);

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  int _changes = 0;
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          getProductName(_product, appLocalizations),
          maxLines: 2,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
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
              subtitle:
                  _product.barcode == null ? null : Text(_product.barcode!),
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_details_title,
              subtitle:
                  appLocalizations.edit_product_form_item_details_subtitle,
              onTap: () async {
                if (!await ProductRefresher().checkIfLoggedIn(context)) {
                  return;
                }
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) =>
                        AddBasicDetailsPage(_product),
                  ),
                );
                if (refreshed ?? false) {
                  _changes++;
                }
              },
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_photos_title,
              subtitle: appLocalizations.edit_product_form_item_photos_subtitle,
              onTap: () async {
                if (!await ProductRefresher().checkIfLoggedIn(context)) {
                  return;
                }
                final List<ProductImageData> allProductImagesData =
                    getAllProductImagesData(_product, appLocalizations);
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => ProductImageGalleryView(
                      productImageData: allProductImagesData.first,
                      allProductImagesData: allProductImagesData,
                      title: allProductImagesData.first.title,
                      barcode: _product.barcode,
                    ),
                  ),
                );
                if (refreshed ?? false) {
                  _changes++;
                }
              },
            ),
            _getSimpleListTileItem(
              SimpleInputPageLabelHelper(_product, appLocalizations),
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_ingredients_title,
              onTap: () async {
                if (!await ProductRefresher().checkIfLoggedIn(context)) {
                  return;
                }
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => EditIngredientsPage(
                      product: _product,
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
            _getSimpleListTileItem(
              SimpleInputPageStoreHelper(_product, appLocalizations),
            ),
            _getSimpleListTileItem(
              SimpleInputPageCategoryHelper(_product, appLocalizations),
            ),
            _ListTitleItem(
              title:
                  appLocalizations.edit_product_form_item_nutrition_facts_title,
              subtitle: appLocalizations
                  .edit_product_form_item_nutrition_facts_subtitle,
              onTap: () async {
                if (!await ProductRefresher().checkIfLoggedIn(context)) {
                  return;
                }
                final OrderedNutrientsCache? cache =
                    await OrderedNutrientsCache.getCache(context);
                if (cache == null) {
                  return;
                }
                if (!mounted) {
                  return;
                }
                final bool? refreshed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => NutritionPageLoaded(
                      _product,
                      cache.orderedNutrients,
                    ),
                  ),
                );
                if (refreshed ?? false) {
                  _changes++;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSimpleListTileItem(final AbstractSimpleInputPageHelper helper) =>
      _ListTitleItem(
        title: helper.getTitle(),
        subtitle: helper.getSubtitle(),
        onTap: () async {
          if (!await ProductRefresher().checkIfLoggedIn(context)) {
            return;
          }
          final Product? refreshed = await Navigator.push<Product>(
            context,
            MaterialPageRoute<Product>(
              builder: (BuildContext context) => SimpleInputPage(helper),
            ),
          );
          if (refreshed != null) {
            _product = refreshed;
          }
          setState(() {});
        },
      );
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey;
              }
              return colorScheme.primary;
            },
          ),
        ),
        child: Text(appLocalizations.edit_product_form_save),
      ),
    );
  }
}
