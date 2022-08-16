import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_ingredients_page.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ocr_ingredients_helper.dart';
import 'package:smooth_app/pages/product/ocr_packaging_helper.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
        final Brightness brightness = Theme.of(context).brightness;

        return SmoothScaffold(
          appBar: AppBar(
            title: AutoSizeText(
              getProductName(_product, appLocalizations),
              maxLines: 2,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => _refreshProduct(context),
            child: ListView(
              children: <Widget>[
                if (_product.barcode != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(width: MINIMUM_TOUCH_SIZE),
                      BarcodeWidget(
                        barcode: _product.barcode!.length == 8
                            ? Barcode.ean8()
                            : Barcode.ean13(),
                        data: _product.barcode!,
                        color: brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        errorBuilder: (final BuildContext context, String? _) =>
                            Text(
                          '${appLocalizations.edit_product_form_item_barcode}\n'
                          '${_product.barcode}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        iconSize: MINIMUM_TOUCH_SIZE,
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _product.barcode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appLocalizations.clipboard_barcode_copied(
                                    _product.barcode!),
                              ),
                            ),
                          );
                        },
                      )
                    ],
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
                        builder: (_) => AddBasicDetailsPage(_product),
                      ),
                    );
                  },
                ),
                _ListTitleItem(
                  leading: const Icon(Icons.add_a_photo_outlined),
                  title: appLocalizations.edit_product_form_item_photos_title,
                  subtitle:
                      appLocalizations.edit_product_form_item_photos_subtitle,
                  onTap: () async {
                    if (!await ProductRefresher().checkIfLoggedIn(context)) {
                      return;
                    }
                    final List<ProductImageData> allProductImagesData =
                        getAllProductImagesData(_product, appLocalizations);
                    final bool? refreshed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (BuildContext context) =>
                            ProductImageGalleryView(
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
                _getMultipleListTileItem(
                  <AbstractSimpleInputPageHelper>[
                    SimpleInputPageLabelHelper(),
                    SimpleInputPageStoreHelper(),
                    SimpleInputPageOriginHelper(),
                    SimpleInputPageEmbCodeHelper(),
                    SimpleInputPageCountryHelper(),
                    SimpleInputPageCategoryHelper(),
                  ],
                ),
                _ListTitleItem(
                  leading:
                      const _SvgIcon('assets/cacheTintable/ingredients.svg'),
                  title:
                      appLocalizations.edit_product_form_item_ingredients_title,
                  onTap: () async {
                    if (!await ProductRefresher().checkIfLoggedIn(context)) {
                      return;
                    }
                    await Navigator.push<Product?>(
                      context,
                      MaterialPageRoute<Product>(
                        builder: (BuildContext context) => EditOcrPage(
                          product: _product,
                          helper: OcrIngredientsHelper(),
                        ),
                      ),
                    );
                  },
                ),
                _getSimpleListTileItem(SimpleInputPageCategoryHelper()),
                _ListTitleItem(
                  leading:
                      const _SvgIcon('assets/cacheTintable/scale-balance.svg'),
                  title: appLocalizations
                      .edit_product_form_item_nutrition_facts_title,
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
                _getSimpleListTileItem(SimpleInputPageLabelHelper()),
                _ListTitleItem(
                  leading: const Icon(Icons.recycling),
                  title:
                      appLocalizations.edit_product_form_item_packaging_title,
                  onTap: () async {
                    if (!await ProductRefresher().checkIfLoggedIn(context)) {
                      return;
                    }
                    await Navigator.push<Product?>(
                      context,
                      MaterialPageRoute<Product>(
                        builder: (BuildContext context) => EditOcrPage(
                          product: _product,
                          helper: OcrPackagingHelper(),
                        ),
                      ),
                    );
                  },
                ),
                _getSimpleListTileItem(SimpleInputPageStoreHelper()),
                _getSimpleListTileItem(SimpleInputPageOriginHelper()),
                _getSimpleListTileItem(SimpleInputPageEmbCodeHelper()),
                _getSimpleListTileItem(SimpleInputPageCountryHelper()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getSimpleListTileItem(final AbstractSimpleInputPageHelper helper) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return _ListTitleItem(
      leading: helper.getIcon(),
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

  Future<bool> _refreshProduct(BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final bool result = await ProductRefresher().fetchAndRefresh(
      context: context,
      localDatabase: localDatabase,
      barcode: _product.barcode!,
    );
    if (mounted && result) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.product_refreshed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return result;
  }

  Widget _getMultipleListTileItem(
    final List<AbstractSimpleInputPageHelper> helpers,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> titles = <String>[];
    for (final AbstractSimpleInputPageHelper element in helpers) {
      titles.add(element.getTitle(appLocalizations));
    }
    return _ListTitleItem(
      leading: const Icon(Icons.interests),
      title: titles.join(', '),
      subtitle: null,
      onTap: () async {
        if (!await ProductRefresher().checkIfLoggedIn(context)) {
          return;
        }
        await Navigator.push<Product>(
          context,
          MaterialPageRoute<Product>(
            builder: (BuildContext context) => SimpleInputPage.multiple(
              helpers: helpers,
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
    this.leading,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => SmoothCard(
        child: ListTile(
          onTap: onTap,
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          // we use a Column to have the icon centered vertically
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[leading ?? const Icon(Icons.edit)],
          ),
          trailing: Icon(ConstantIcons.instance.getForwardIcon()),
        ),
      );
}

/// SVG that looks like a ListTile icon.
class _SvgIcon extends StatelessWidget {
  const _SvgIcon(this.assetName);

  final String assetName;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        assetName,
        height: DEFAULT_ICON_SIZE,
        width: DEFAULT_ICON_SIZE,
        color: _iconColor(Theme.of(context)),
      );

  /// Returns the standard icon color in a [ListTile].
  ///
  /// Simplified version from [ListTile], which was anyway not kind enough
  /// to make it public.
  Color _iconColor(ThemeData theme) {
    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return Colors.white;
    }
  }
}
