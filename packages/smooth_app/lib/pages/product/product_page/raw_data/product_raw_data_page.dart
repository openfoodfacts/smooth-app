import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';

import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_category.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_category_widget.dart';

import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_ext.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/raw_data_edit_helper.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
      body: ListView.separated(
        itemCount: productRawDatas.length,
        separatorBuilder: (BuildContext context, _) =>
          //remove default margin between elements
          EMPTY_WIDGET,
        itemBuilder: (_, int index) {
          return ProductRawDataCategoryWidget(
            productRawDatas[index],
            switch (productRawDatas[index].category) {
              ProductRawDataCategories.labels => () async {
                  RawDataEditHelper()
                      .onInformationsEdit(context, widget.product);
                },
              ProductRawDataCategories.category => () async {
                  RawDataEditHelper()
                      .onCategoryEditClick(context, widget.product);
                },
              ProductRawDataCategories.ingredients => () async {
                  RawDataEditHelper()
                      .onIngredientsEditClick(context, widget.product);
                },
              ProductRawDataCategories.nutriment => () async {
                  RawDataEditHelper()
                      .onNutritionEditClick(context, widget.product);
                },
              ProductRawDataCategories.packaging => () {
                  RawDataEditHelper()
                      .onPackagingEditClick(context, widget.product);
                },
              ProductRawDataCategories.stores => () async {
                  RawDataEditHelper()
                      .onStoresEditClick(context, widget.product);
                },
              ProductRawDataCategories.countries => () async {
                  RawDataEditHelper().onCountriesEditClick(
                      context, widget.product, context.read<UserPreferences>());
                },
            },
          );
        },
      ),
    );
  }
}
