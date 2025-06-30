import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_category.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_category_widget.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_ext.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/raw_data_edit_helper.dart';

class ProductRawDataPage extends StatefulWidget {
  const ProductRawDataPage(this.product);

  final Product product;

  @override
  State<StatefulWidget> createState() => _ProductRawDataPageState();
}

class _ProductRawDataPageState extends State<ProductRawDataPage> {
  late final List<ProductRawDataCategory> productRawDatas;

  @override
  void initState() {
    super.initState();

    productRawDatas = widget.product.toRawDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        for (final ProductRawDataCategory category in productRawDatas)
          ProductRawDataCategoryWidget(
            category,
            getEditCallbackForCategory(context, category, widget.product),
          ),
      ],
    ));
  }

  GestureTapCallback? getEditCallbackForCategory(
    BuildContext context,
    ProductRawDataCategory category,
    Product product,
  ) {
    switch (category.category) {
      case ProductRawDataCategories.labels:
        return () async {
          RawDataEditHelper().onInformationsEdit(context, product);
        };
      case ProductRawDataCategories.category:
        return () async {
          RawDataEditHelper().onCategoryEditClick(context, product);
        };
      case ProductRawDataCategories.ingredients:
        return () async {
          RawDataEditHelper().onIngredientsEditClick(context, product);
        };
      case ProductRawDataCategories.nutriment:
        return () async {
          RawDataEditHelper().onNutritionEditClick(context, product);
        };
      case ProductRawDataCategories.packaging:
        return () {
          RawDataEditHelper().onPackagingEditClick(context, product);
        };
      case ProductRawDataCategories.stores:
        return () async {
          RawDataEditHelper().onStoresEditClick(context, product);
        };
      case ProductRawDataCategories.countries:
        return () async {
          RawDataEditHelper().onCountriesEditClick(
              context, product, context.read<UserPreferences>());
        };
    }
  }
}