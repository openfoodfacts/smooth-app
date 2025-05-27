import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page/nutrition_page_loader.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';

//I don't like the fact that I had to copy and paste functions into edit_product_page
//TODO: Make sure it's connected
class RawDataEditHelper {
  Future<void> onInformationsEdit(BuildContext context, Product upToDateProduct) async {
        ProductFieldDetailsEditor().edit(
            context: context,
            product: upToDateProduct,
          );
  }

  Future<void> onCategoryEditClick(BuildContext context, Product upToDateProduct) async {
    ProductFieldSimpleEditor(SimpleInputPageCategoryHelper()).edit(
            context: context,
            product: upToDateProduct,
          );
  }

  Future<void> onIngredientsEditClick(BuildContext context, Product upToDateProduct) async {
    ProductFieldOcrIngredientEditor().edit(
                    context: context,
                    product: upToDateProduct,
            );
  }

  Future<void> onNutritionEditClick(BuildContext context, Product upToDateProduct) async {
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
  }

  void onPackagingEditClick(BuildContext context, Product upToDateProduct){
    ProductFieldPackagingEditor().edit(
                  context: context,
                  product: upToDateProduct,
                );
  }

  Future<void> onStoresEditClick(BuildContext context, Product upToDateProduct) async {
    ProductFieldSimpleEditor(SimpleInputPageStoreHelper()).edit(
            context: context,
            product: upToDateProduct,
          );
  }

  Future<void> onCountriesEditClick(BuildContext context, Product upToDateProduct, UserPreferences preferences) async {
    ProductFieldSimpleEditor(SimpleInputPageCountryHelper(preferences)).edit(
            context: context,
            product: upToDateProduct,
          );
  }

}
  