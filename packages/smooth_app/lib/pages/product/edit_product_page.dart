import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/local_database.dart';
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
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final Scaffold scaffold = Scaffold(
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
        body: ListView(
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
                await Navigator.push<Product?>(
                  context,
                  MaterialPageRoute<Product>(
                    builder: (BuildContext context) =>
                        AddBasicDetailsPage(_product),
                  ),
                );
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
                // TODO(monsieurtanuki): do the refresh uptream with a new ProductRefresher method
                if (refreshed != true) {
                  return;
                }
                //Refetch product if needed for new urls, since no product in ProductImageGalleryView
                if (!mounted) {
                  return;
                }
                final LocalDatabase localDatabase =
                    context.read<LocalDatabase>();
                await ProductRefresher().fetchAndRefresh(
                  context: context,
                  localDatabase: localDatabase,
                  barcode: _product.barcode!,
                );
              },
            ),
            _getSimpleListTileItem(SimpleInputPageLabelHelper()),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_ingredients_title,
              onTap: () async {
                if (!await ProductRefresher().checkIfLoggedIn(context)) {
                  return;
                }
                await Navigator.push<Product?>(
                  context,
                  MaterialPageRoute<Product>(
                    builder: (BuildContext context) => EditIngredientsPage(
                      product: _product,
                    ),
                  ),
                );
              },
            ),
            _ListTitleItem(
              title: appLocalizations.edit_product_form_item_packaging_title,
            ),
            _getSimpleListTileItem(SimpleInputPageStoreHelper()),
            _getSimpleListTileItem(SimpleInputPageEmbCodeHelper()),
            _getSimpleListTileItem(SimpleInputPageCountryHelper()),
            _getSimpleListTileItem(SimpleInputPageCategoryHelper()),
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
                await Navigator.push<Product?>(
                  context,
                  MaterialPageRoute<Product>(
                    builder: (BuildContext context) => NutritionPageLoaded(
                      _product,
                      cache.orderedNutrients,
                    ),
                  ),
                );
              },
            ),
          ],
        ));
    return Consumer<UpToDateProductProvider>(
      builder: (
        final BuildContext context,
        final UpToDateProductProvider provider,
        final Widget? child,
      ) {
        final Product? refreshedProduct = provider.get(_product);
        if (refreshedProduct != null) {
          _product = refreshedProduct;
        }
        return scaffold;
      },
    );
  }

  Widget _getSimpleListTileItem(final AbstractSimpleInputPageHelper helper) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return _ListTitleItem(
      title: helper.getTitle(appLocalizations),
      subtitle: helper.getSubtitle(appLocalizations),
      onTap: () async {
        if (!await ProductRefresher().checkIfLoggedIn(context)) {
          return;
        }
        await Navigator.push<Product>(
          context,
          MaterialPageRoute<Product>(
            builder: (BuildContext context) => SimpleInputPage(
              helper: helper,
              product: _product,
            ),
          ),
        );
      },
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: ElevatedButton(
        onPressed: onTap,
        child: Text(appLocalizations.edit_product_form_save),
      ),
    );
  }
}
