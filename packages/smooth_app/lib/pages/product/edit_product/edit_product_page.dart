mport 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/onboarding/currency_selector_helper.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/add_other_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_product/edit_product_footer.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page_loader.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatefulWidget {
  const EditProductPage(this.product);

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> with UpToDateMixin {

  List<Widget> items=[];
  List<Widget> originalItems=[];
  String? selectedOption="Fields";

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  void _sortByMissingData(){
    setState(() {
      items.sort((a, b){
        if(a is _ListTitleItem && b is _ListTitleItem){
          Color ca=a.color ?? Color(0xFF219653);
          Color cb=b.color ?? Color(0xFF219653);
          final List<Color> order=[Color(0xFFEB5757), Color(0xFFFB8229), Color(0xFF219653)];
          return order.indexOf(ca).compareTo(order.indexOf(cb));
        }
        return 0;
      });
    });
  }

  void _sortByField() {
    setState(() {
      items = List.from(originalItems); // Restore original order
    });
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if(items.isEmpty){
      items=[
      _ListTitleItem(
                leading: Icon(
                    Icons.edit,
                    size: 18.0,
                    ),
                title: appLocalizations.edit_product_form_item_details_title,
                error: [
                  (upToDateProduct.productName==null) ? appLocalizations.product_name : "",
                  (upToDateProduct.quantity==null) ? appLocalizations.quantity: "",
                  (upToDateProduct.brands==null) ? appLocalizations.brand_name: "",
                ],
                onTap: () async => ProductFieldDetailsEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
              ),
              _ListTitleItem(
                leading: Icon(
                    Icons.add_a_photo_rounded,
                  ),
                title: appLocalizations.edit_product_form_item_photos_title,
                error:[
                  (upToDateProduct.imageFrontSmallUrl==null && upToDateProduct.imageFrontUrl==null) ? appLocalizations.front_photo : "",
                  (upToDateProduct.imageIngredientsSmallUrl==null && upToDateProduct.imageIngredientsUrl==null) ? appLocalizations.ingredients_photo : "",
                  (upToDateProduct.imageNutritionSmallUrl==null && upToDateProduct.imageNutritionUrl==null) ? appLocalizations.nutrition_facts_photo : "",
                ],
                warning: [
                  (upToDateProduct.imagePackagingSmallUrl==null) ? appLocalizations.packaging_information_photo : "",
                ],
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
                  SimpleInputPageCountryHelper(
                    context.read<UserPreferences>(),
                  ),
                  SimpleInputPageCategoryHelper(),
                ],
              ),
              if (upToDateProduct.productType != ProductType.product)
                _ListTitleItem(
                  leading: const icons.Ingredients.alt(),
                  title:
                      appLocalizations.edit_product_form_item_ingredients_title,
                  error: [
                    (upToDateProduct.ingredients==null) ? appLocalizations.ingredients : "",
                  ],
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
                    error: [
                      (upToDateProduct.nutritionData==true) ? 
                          (upToDateProduct.servingSize==null) ? appLocalizations.nutrition_page_serving_size : ""
                       : "",
                    ],
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
                      await NutritionPageLoader.showNutritionPage(
                        product: upToDateProduct,
                        isLoggedInMandatory: true,
                        context: context,
                      );
                    }),
              _getSimpleListTileItem(SimpleInputPageLabelHelper()),
              _ListTitleItem(
                leading: const icons.Packaging(),
                title: appLocalizations.edit_packagings_title,
                warning: [
                  (upToDateProduct.packagings==null) ? appLocalizations.edit_packagings_title : "",
                ],
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
              _getSimpleListTileItem(SimpleInputPageCountryHelper(
                context.read<UserPreferences>(),
              )),
              _ListTitleItem(
                title:
                    appLocalizations.edit_product_form_item_other_details_title,
                //subtitle: appLocalizations.edit_product_form_item_other_details_subtitle,
                warning: [
                  (upToDateProduct.website==null) ? appLocalizations.edit_product_form_item_other_details_title : "",
                ],
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
    ];
    originalItems=List.from(items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    refreshUpToDate();

    final String productName = getProductName(
      upToDateProduct,
      appLocalizations,
    );
    final String productBrands =
        getProductBrands(upToDateProduct, appLocalizations);
    final bool hasUploadIndicator = UpToDateChanges(localDatabase)
        .hasNotTerminatedOperations(upToDateProduct.barcode!);

    return Provider<Product>.value(
      value: upToDateProduct,
      child: SmoothScaffold2(
        backgroundColor: lightTheme ? extension.primaryLight : null,
        brightness: Brightness.light,
        topBar: SmoothTopBar2(
          title: AppLocalizations.of(context).edit_product_label,
          subTitle: '$productName, $productBrands',
          leadingAction: SmoothTopBarLeadingAction.back,
          backgroundColor:
              lightTheme ? extension.primaryBlack : extension.primaryUltraBlack,
          foregroundColor: lightTheme ? Colors.white : null,
          elevationColor: lightTheme ? Colors.black54 : Colors.white12,
          elevationOnScroll: false,
          productType: upToDateProduct.productType,
          reducedHeightOnScroll: true,
        ),
        padding: const EdgeInsetsDirectional.only(
          top: VERY_SMALL_SPACE,
          start: MEDIUM_SPACE,
          end: MEDIUM_SPACE,
          bottom: MEDIUM_SPACE + ProductFooter.kHeight + LARGE_SPACE,
        ),
        bottomSafeArea: true,
        floatingBottomBar: EditProductFooter(
          uploadIndicator: hasUploadIndicator,
        ),
        children: <Widget>[
          SliverList.list(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: lightTheme ? extension.primaryBlack : extension.primaryDark,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, 
                      children: [
                        SizedBox(width: 10,),
                        Icon(Icons.sort, color: extension.primaryLight,),
                        Icon(Icons.arrow_downward, color: extension.primaryLight,),
                        Text(
                          "Sort by :",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: extension.primaryLight, 
                          ),
                        ),
                        SizedBox(width: 8), 
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: extension.primaryLight, 
                              borderRadius: BorderRadius.circular(20), 
                              border: Border.all(color: extension.primaryBlack, width: 2), 
                            ),
                            child: DropdownButton<String>(
                              value: selectedOption,
                              icon: Icon(Icons.keyboard_arrow_down_sharp, color: extension.primaryBlack), 
                              iconSize: 24,
                              isDense: true,
                              style: TextStyle(
                                color: extension.primaryBlack,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue == null) return;
                                setState(() {
                                  selectedOption = newValue;
                                });
                                if (newValue == appLocalizations.sort_by_missing_data) {
                                  _sortByMissingData();
                                } else {
                                  _sortByField();
                                }
                              }, // Brown text
                              items: [
                                  appLocalizations.sort_by_fields, 
                                  appLocalizations.sort_by_missing_data
                                ]
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ),
              ...items,
            ],
          ),
        ],
      ),
    );
  }

  Widget _getSimpleListTileItem(final AbstractSimpleInputPageHelper helper) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _ListTitleItem(
      leading: helper.getIcon(),
      title: helper.getTitle(appLocalizations),
      error: [
        (helper.getTitle(appLocalizations)==appLocalizations.edit_product_form_item_countries_title) ?
          (upToDateProduct.countries==null) ? appLocalizations.edit_product_form_item_countries_title : ""
         :"",
         (helper.getTitle(appLocalizations)==appLocalizations.edit_product_form_item_categories_title) ?
          (upToDateProduct.categories==null) ? appLocalizations.edit_product_form_item_categories_title : ""
         :"",
      ],
      warning: [
        (helper.getTitle(appLocalizations)==appLocalizations.edit_product_form_item_labels_title) ?
          (upToDateProduct.labels==null) ? appLocalizations.edit_product_form_item_labels_title : ""
        :"",
        (helper.getTitle(appLocalizations)==appLocalizations.edit_product_form_item_origins_title) ?
          (upToDateProduct.origins==null) ? appLocalizations.edit_product_form_item_origins_title : ""
         :"",
         (helper.getTitle(appLocalizations)==appLocalizations.edit_product_form_item_stores_title) ?
          (upToDateProduct.stores==null) ? appLocalizations.edit_product_form_item_stores_title : ""
         :"",
         (helper.getTitle(appLocalizations)==appLocalizations.edit_product_form_item_emb_codes_title) ?
          (upToDateProduct.embCodes==null) ? appLocalizations.edit_product_form_item_emb_codes_title : ""
         :"",
      ],
      //subtitle: helper.getSubtitle(appLocalizations),
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
      error: [
        (upToDateProduct.countries==null) ? appLocalizations.edit_product_form_item_countries_type : "",
        (upToDateProduct.categories==null) ? appLocalizations.category_picker_screen_title : "",
      ],
      warning: [
        (upToDateProduct.labels==null) ? appLocalizations.edit_product_form_item_labels_title : "",
        (upToDateProduct.stores==null) ? appLocalizations.edit_product_form_item_stores_title : "",
        (upToDateProduct.origins==null) ? appLocalizations.edit_product_form_item_origins_title : "",
        (upToDateProduct.embCodes==null) ? appLocalizations.edit_product_form_item_emb_codes_title : "",
      ],
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
}

class _ListTitleItem extends SmoothListTileCard {
  _ListTitleItem({
    Widget? leading,
    String? title,
    List<String>? error,
    List<String>? warning,
    super.onTap,
  }) : super.icon(
          title: Row(
            children: [
              Expanded(
                child: Text(
                          title ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
            ],
          ),
          subtitle: error!=null || warning!=null 
           ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error != null)
                      ...error
                          .where((e) => e.isNotEmpty) 
                          .map(
                            (e) => Row(
                              children: [
                                const Icon(Icons.error, color: Color(0xFFEB5757), size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    if (warning != null)
                      ...warning
                          .where((w) => w.isNotEmpty)
                          .map(
                            (w) => Row(
                              children: [
                                const Icon(Icons.warning, color: Color(0xFFFB8229), size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    w,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ],
                  )
          : SizedBox(),
          icon: leading,
          color: _getIconBackgroundColor(title, error, warning),
          margin: const EdgeInsetsDirectional.only(
            top: SMALL_SPACE,
          ),
        );

        static _getIconBackgroundColor(String? title, List<String>? error, List<String>? warning){
          if(error!=null && error.any((e) => e.isNotEmpty)){
            return Color(0xFFEB5757);
          }
          else if(warning!=null && warning.any((w) => w.isNotEmpty)){
            return Color(0xFFFB8229);
          }
          else{
            return Color(0xFF219653);
          }
        }
}