import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/roots/faq_root.dart';
import 'package:smooth_app/query/product_query.dart';

/// Projects with specific preferences.
enum PreferencesPageProjects {
  food,
  products,
  beauty,
  pets;

  ProductType get productType => switch (this) {
    PreferencesPageProjects.food => ProductType.food,
    PreferencesPageProjects.products => ProductType.product,
    PreferencesPageProjects.beauty => ProductType.beauty,
    PreferencesPageProjects.pets => ProductType.petFood,
  };

  String get projectKey => switch (this) {
    PreferencesPageProjects.food => 'food',
    PreferencesPageProjects.products => 'products',
    PreferencesPageProjects.beauty => 'beauty',
    PreferencesPageProjects.pets => 'pets',
  };

  String getTitle(AppLocalizations appLocalizations) => switch (this) {
    PreferencesPageProjects.food => appLocalizations.myPreferences_food_title,
    PreferencesPageProjects.products =>
      appLocalizations.myPreferences_product_title,
    PreferencesPageProjects.beauty =>
      appLocalizations.myPreferences_beauty_title,
    PreferencesPageProjects.pets =>
      appLocalizations.myPreferences_pet_food_title,
  };

  String getSubtitle(AppLocalizations appLocalizations) => switch (this) {
    PreferencesPageProjects.food =>
      appLocalizations.myPreferences_food_subtitle,
    PreferencesPageProjects.products =>
      appLocalizations.myPreferences_product_subtitle,
    PreferencesPageProjects.beauty =>
      appLocalizations.myPreferences_beauty_subtitle,
    PreferencesPageProjects.pets =>
      appLocalizations.myPreferences_pet_food_subtitle,
  };

  UriProductHelper getUriProductHelper() => switch (this) {
    PreferencesPageProjects.food => uriHelperFoodProd,
    PreferencesPageProjects.products => uriHelperProductsProd,
    PreferencesPageProjects.beauty => uriHelperBeautyProd,
    PreferencesPageProjects.pets => uriHelperPetFoodProd,
  };

  String get _assetSubfolder => switch (this) {
    PreferencesPageProjects.food => 'open_food_facts',
    PreferencesPageProjects.products => 'open_products_facts',
    PreferencesPageProjects.beauty => 'open_beauty_facts',
    PreferencesPageProjects.pets => 'open_pet_food_facts',
  };

  Widget getLeadingIcon(final bool lightTheme, {EdgeInsetsGeometry? padding}) =>
      FaqRoot.createLeadingIcon(
        'assets/'
        'guides/'
        '$_assetSubfolder/'
        'thumb_${lightTheme ? 'light' : 'dark'}.svg.vec',
        padding: padding,
      );

  Future<List<AttributeGroup>?> fetchAttributeGroups() async {
    try {
      final String languageCode = ProductQuery.getLanguage().code;
      final Uri uri = AvailableAttributeGroups.getUri(
        languageCode,
        uriHelper: getUriProductHelper(),
      );

      // TODO(monsieurtanuki): cache it?
      final http.Response response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final AvailableAttributeGroups availableAttributeGroups =
          AvailableAttributeGroups.loadFromJSONString(response.body);
      return availableAttributeGroups.attributeGroups;
    } catch (e) {
      debugPrint('Error fetching attribute groups for $name: $e');
      return null;
    }
  }
}
