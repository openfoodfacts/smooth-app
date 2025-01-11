import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/add_other_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_product_barcode.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page_loading_indicator.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatefulWidget {
  const EditProductPage(this.product);

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> with UpToDateMixin {
  final ScrollController _controller = ScrollController();
  bool _actionsVisibleInAppbar = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _controller.addListener(_onScrollChanged);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    refreshUpToDate();
    final ThemeData theme = Theme.of(context);
    final bool lightTheme = context.lightTheme();

    final String productName = getProductName(
      upToDateProduct,
      appLocalizations,
    );
    final String productBrand =
        getProductBrands(upToDateProduct, appLocalizations);

    return SmoothScaffold(
      backgroundColor: lightTheme
          ? theme.extension<SmoothColorsThemeExtension>()!.primaryLight
          : null,
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        backgroundColor: lightTheme ? Colors.white : null,
        title: Semantics(
          value: productName,
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  '${productName.trim()}, ${productBrand.trim()}',
                  minFontSize:
                      theme.textTheme.titleLarge?.fontSize?.clamp(10.0, 13.0) ??
                          13.0,
                  maxFontSize:
                      theme.textTheme.titleLarge?.fontSize?.clamp(13.0, 20.0) ??
                          18.0,
                  maxLines: !_actionsVisibleInAppbar ? 2 : 1,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (barcode.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: _actionsVisibleInAppbar ? 14.0 : 0.0,
                    child: Text(
                      barcode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        height: 0.9,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Semantics(
            button: true,
            value: appLocalizations.open_product_website,
            excludeSemantics: true,
            child: Builder(builder: (BuildContext context) {
              return IconButton(
                icon: const icons.ExternalLink(
                  size: 20.0,
                ),
                tooltip: appLocalizations.open_product_website,
                onPressed: () {
                  LaunchUrlHelper.launchURLAndFollowDeepLinks(
                    context,
                    switch (upToDateProduct.productType) {
                      ProductType.beauty =>
                        'https://world.openbeautyfacts.org/product/${upToDateProduct.barcode}',
                      ProductType.petFood =>
                        'https://world.openpetfoodfacts.org/product/${upToDateProduct.barcode}',
                      ProductType.product =>
                        'https://world.openproductsfacts.org/product/${upToDateProduct.barcode}',
                      _ =>
                        'https://world.openfoodfacts.org/product/${upToDateProduct.barcode}',
                    },
                  );
                },
              );
            }),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ProductRefresher().fetchAndRefresh(
          barcode: barcode,
          context: context,
        ),
        child: Scrollbar(
          controller: _controller,
          child: ListView(
            padding: EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              start: MEDIUM_SPACE,
              end: MEDIUM_SPACE,
              bottom: MEDIUM_SPACE + MediaQuery.viewPaddingOf(context).bottom,
            ),
            controller: _controller,
            children: <Widget>[
              if (EditProductBarcode.isAValidBarcode(barcode))
                EditProductBarcode(barcode: upToDateProduct.barcode ?? ''),
              _ListTitleItem(
                leading: const icons.Edit(size: 18.0),
                title: appLocalizations.edit_product_form_item_details_title,
                subtitle:
                    appLocalizations.edit_product_form_item_details_subtitle,
                onTap: () async => ProductFieldDetailsEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
              ),
              _ListTitleItem(
                leading: const Icon(Icons.add_a_photo_rounded),
                title: appLocalizations.edit_product_form_item_photos_title,
                subtitle:
                    appLocalizations.edit_product_form_item_photos_subtitle,
                onTap: () async {
                  AnalyticsHelper.trackProductEdit(
                    AnalyticsEditEvents.photos,
                    upToDateProduct,
                  );

                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ProductImageGalleryView(
                        product: upToDateProduct,
                      ),
                    ),
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
              if (upToDateProduct.productType != ProductType.product)
                _ListTitleItem(
                  leading: const icons.Ingredients.alt(),
                  title:
                      appLocalizations.edit_product_form_item_ingredients_title,
                  onTap: () async => ProductFieldOcrIngredientEditor().edit(
                    context: context,
                    product: upToDateProduct,
                  ),
                ),
              if (upToDateProduct.productType == null ||
                  upToDateProduct.productType == ProductType.food)
                _getSimpleListTileItem(SimpleInputPageCategoryHelper())
              else
                _getSimpleListTileItem(SimpleInputPageCategoryNotFoodHelper()),
              if (upToDateProduct.productType != ProductType.beauty &&
                  upToDateProduct.productType != ProductType.product)
                _ListTitleItem(
                    leading: const icons.NutritionFacts(size: 18.0),
                    title: appLocalizations
                        .edit_product_form_item_nutrition_facts_title,
                    subtitle: appLocalizations
                        .edit_product_form_item_nutrition_facts_subtitle,
                    onTap: () async {
                      if (!await ProductRefresher().checkIfLoggedIn(
                        context,
                        isLoggedInMandatory: true,
                      )) {
                        return;
                      }
                      AnalyticsHelper.trackProductEdit(
                        AnalyticsEditEvents.nutrition_Facts,
                        upToDateProduct,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      await NutritionPageLoaded.showNutritionPage(
                        product: upToDateProduct,
                        isLoggedInMandatory: true,
                        context: context,
                      );
                    }),
              _getSimpleListTileItem(SimpleInputPageLabelHelper()),
              _ListTitleItem(
                leading: const icons.Packaging(),
                title: appLocalizations.edit_packagings_title,
                onTap: () async => ProductFieldPackagingEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
              ),
              _ListTitleItem(
                leading: const icons.Recycling(),
                title: appLocalizations.edit_product_form_item_packaging_title,
                onTap: () async => ProductFieldOcrPackagingEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
              ),
              _getSimpleListTileItem(SimpleInputPageStoreHelper()),
              _getSimpleListTileItem(SimpleInputPageOriginHelper()),
              _getSimpleListTileItem(SimpleInputPageEmbCodeHelper()),
              _getSimpleListTileItem(SimpleInputPageCountryHelper()),
              _ListTitleItem(
                title:
                    appLocalizations.edit_product_form_item_other_details_title,
                subtitle: appLocalizations
                    .edit_product_form_item_other_details_subtitle,
                onTap: () async {
                  if (!await ProductRefresher().checkIfLoggedIn(
                    context,
                    isLoggedInMandatory: true,
                  )) {
                    return;
                  }
                  if (!context.mounted) {
                    return;
                  }
                  AnalyticsHelper.trackProductEdit(
                    AnalyticsEditEvents.otherDetails,
                    upToDateProduct,
                  );
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AddOtherDetailsPage(upToDateProduct),
                    ),
                  );
                },
              ),
              Consumer<UserPreferences>(
                builder:
                    (BuildContext context, UserPreferences preferences, _) {
                  return _ListTitleItem(
                    title: appLocalizations.prices_add_a_price,
                    leading: icons.AddPrice(
                      CurrencySelectorHelper().getSelected(
                        preferences.userCurrencyCode,
                      ),
                    ),
                    onTap: () async => ProductPriceAddPage.showProductPage(
                      context: context,
                      product: PriceMetaProduct.product(upToDateProduct),
                      proofType: ProofType.priceTag,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UpToDateChanges(localDatabase)
              .hasNotTerminatedOperations(upToDateProduct.barcode!)
          ? const ProductPageLoadingIndicator(
              addSafeArea: true,
            )
          : null,
    );
  }

  Widget _getSimpleListTileItem(final AbstractSimpleInputPageHelper helper) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _ListTitleItem(
      leading: helper.getIcon(),
      title: helper.getTitle(appLocalizations),
      subtitle: helper.getSubtitle(appLocalizations),
      onTap: () async => ProductFieldSimpleEditor(helper).edit(
        context: context,
        product: upToDateProduct,
      ),
    );
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
      onTap: () async {
        if (!await ProductRefresher().checkIfLoggedIn(
          context,
          isLoggedInMandatory: true,
        )) {
          return;
        }
        if (!mounted) {
          return;
        }
        AnalyticsHelper.trackProductEdit(
          AnalyticsEditEvents.powerEditScreen,
          upToDateProduct,
        );
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SimpleInputPage.multiple(
              helpers: helpers,
              product: upToDateProduct,
            ),
          ),
        );
      },
    );
  }

  void _onScrollChanged() {
    final bool visibleBarcode =
        _controller.offset > EditProductBarcode.barcodeHeight + 80.0;

    if (visibleBarcode != _actionsVisibleInAppbar) {
      setState(() {
        _actionsVisibleInAppbar = visibleBarcode;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScrollChanged);
    _controller.dispose();
    super.dispose();
  }
}

class _ListTitleItem extends SmoothListTileCard {
  _ListTitleItem({
    Widget? leading,
    String? title,
    String? subtitle,
    super.onTap,
  }) : super.icon(
          title: title == null
              ? null
              : Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
          icon: leading,
          subtitle: subtitle == null ? null : Text(subtitle),
          margin: const EdgeInsetsDirectional.only(
            top: SMALL_SPACE,
          ),
        );
}
