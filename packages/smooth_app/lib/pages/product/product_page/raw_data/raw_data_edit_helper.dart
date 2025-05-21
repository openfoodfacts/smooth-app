import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page_loader.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';

//Je n'aime pas le fait que j'ai du copié collé des fonctions dans edit_product_page
//TODO s'assurer qu'il soit connecté
class RawDataEditHelper {
  Future<void> onInformationsEdit(BuildContext context, Product upToDateProduct) async {
        ProductFieldDetailsEditor().edit(
            context: context,
            product: upToDateProduct,
          );
  }

  void onPackagingEditClick(BuildContext context, Product upToDateProduct){
    ProductFieldPackagingEditor().edit(
                  context: context,
                  product: upToDateProduct,
                );
  }

  void onNutritionEdit(){

  }

  void onPackagingEdit(){

  }

  void onStoresEdit(){

  }

  void onCountriesEdit(){
    
  }

}
  