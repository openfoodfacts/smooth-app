import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
import 'package:openfoodfacts/personalized_search/available_attribute_groups.dart';
import 'package:openfoodfacts/personalized_search/available_preference_importances.dart';
import 'package:openfoodfacts/personalized_search/available_product_preferences.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_manager.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:smooth_app/data_models/downloadable_string.dart';
import 'package:smooth_app/database/dao_string.dart';

class ProductPreferences extends ProductPreferencesManager with ChangeNotifier {
  ProductPreferences(
    final ProductPreferencesSelection productPreferencesSelection, {
    this.daoString,
  }) : super(productPreferencesSelection);

  final DaoString? daoString;

  /// Where we keep the language of the latest successful download.
  static const String _DAO_STRING_KEY_LANGUAGE = 'latest_language';

  /// Were those data freshly downloaded? (and therefore good enough)
  bool _isNetwork = false;

  /// Is currently trying to download data?
  bool _isDownloading = false;

  /// Notifies listeners.
  ///
  /// Comments added only in order to avoid a "warning"
  /// For the record, we need to override the method
  /// because the parent's is protected
  @override
  void notifyListeners() => super.notifyListeners();

  static const String _DEFAULT_LANGUAGE_CODE = 'en';
  static String _getImportanceAssetPath(final String languageCode) =>
      'assets/metadata/init_preferences_$languageCode.json';
  static String _getAttributeAssetPath(final String languageCode) =>
      'assets/metadata/init_attribute_groups_$languageCode.json';

  /// Inits with the best available not-network references.
  ///
  /// That means trying with assets and local database.
  Future<void> init(final AssetBundle assetBundle) async {
    // trying the local database with the latest download language...
    if (daoString != null) {
      final String? latestLanguage =
          await daoString!.get(_DAO_STRING_KEY_LANGUAGE);
      if (latestLanguage != null) {
        final bool successful = await _loadFromDatabase(latestLanguage);
        if (successful) {
          return;
        }
      }
    }
    // fallback: assets in English
    await _loadFromAssets(assetBundle);
  }

  /// Refreshes the references with network data.
  Future<void> refresh(final String languageCode) async {
    if (_isNetwork) {
      return;
    }
    if (_isDownloading) {
      return;
    }
    _isDownloading = true;
    final bool successful = await _loadFromNetwork(languageCode);
    if (successful) {
      _isNetwork = true;
      if (daoString != null) {
        await daoString!.put(_DAO_STRING_KEY_LANGUAGE, languageCode);
      }
      notify();
    }
    _isDownloading = false;
  }

  /// Loads the references of importance and attribute groups from assets.
  Future<bool> _loadFromAssets(final AssetBundle assetBundle) async {
    try {
      const String languageCode = _DEFAULT_LANGUAGE_CODE;
      final String importanceAssetPath = _getImportanceAssetPath(languageCode);
      final String attributeGroupAssetPath =
          _getAttributeAssetPath(languageCode);
      final String preferenceImportancesString =
          await assetBundle.loadString(importanceAssetPath);
      final String attributeGroupsString =
          await assetBundle.loadString(attributeGroupAssetPath);
      _loadFromStrings(
        languageCode,
        preferenceImportancesString,
        attributeGroupsString,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads the references of importance and attribute groups from urls.
  ///
  /// The downloaded strings are automatically stored in the database.
  Future<bool> _loadFromNetwork(String languageCode) async {
    try {
      final String importanceUrl =
          AvailablePreferenceImportances.getUrl(languageCode);
      final String attributeGroupUrl =
          AvailableAttributeGroups.getUrl(languageCode);
      final DownloadableString downloadableImportance;
      downloadableImportance =
          DownloadableString(Uri.parse(importanceUrl), dao: daoString);
      final bool differentImportance = await downloadableImportance.download();
      final DownloadableString downloadableAttributes =
          DownloadableString(Uri.parse(attributeGroupUrl), dao: daoString);
      final bool differentAttributes = await downloadableAttributes.download();
      // the downloaded values are identical to what was stored locally.
      if ((!differentImportance) && (!differentAttributes)) {
        return false;
      }
      final String preferenceImportancesString = downloadableImportance.value!;
      final String attributeGroupsString = downloadableAttributes.value!;
      _loadFromStrings(
        languageCode,
        preferenceImportancesString,
        attributeGroupsString,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads the references of importance and attribute groups from database.
  Future<bool> _loadFromDatabase(final String languageCode) async {
    if (daoString == null) {
      return false;
    }
    try {
      final String importanceUrl =
          AvailablePreferenceImportances.getUrl(languageCode);
      final String attributeGroupUrl =
          AvailableAttributeGroups.getUrl(languageCode);
      final String? preferenceImportancesString =
          await daoString!.get(importanceUrl);
      final String? attributeGroupsString =
          await daoString!.get(attributeGroupUrl);
      if (preferenceImportancesString == null &&
          attributeGroupsString == null) {
        return false;
      }
      _loadFromStrings(
        languageCode,
        preferenceImportancesString!,
        attributeGroupsString!,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads the references of importance and attribute groups from strings.
  ///
  /// May throw an exception.
  void _loadFromStrings(
    final String languageCode,
    final String preferenceImportancesString,
    final String attributeGroupsString,
  ) {
    final AvailableProductPreferences myAvailableProductPreferences =
        AvailableProductPreferences.loadFromJSONStrings(
      preferenceImportancesString: preferenceImportancesString,
      attributeGroupsString: attributeGroupsString,
    );
    availableProductPreferences = myAvailableProductPreferences;
  }

  @override
  String getImportanceIdForAttributeId(String attributeId) =>
      _getRefinedImportanceId(super.getImportanceIdForAttributeId(attributeId));

  /// Downgrades "very important" to "important" (from 4 to 3 choices, simpler).
  static String _getRefinedImportanceId(final String importanceId) =>
      importanceId == PreferenceImportance.ID_VERY_IMPORTANT
          ? PreferenceImportance.ID_IMPORTANT
          : importanceId;

  Future<void> resetImportances() async {
    await clearImportances(notifyListeners: false);
    if (attributeGroups != null) {
      for (final AttributeGroup attributeGroup in attributeGroups!) {
        if (attributeGroup.attributes != null) {
          for (final Attribute attribute in attributeGroup.attributes!) {
            final String? defaultF = attribute.defaultF;
            if (attribute.id != null && defaultF != null) {
              await setImportance(
                attribute.id!,
                _getRefinedImportanceId(defaultF),
                notifyListeners: false,
              );
            }
          }
        }
      }
    }
    notify();
  }

  AttributeGroup getAttributeGroup(final String attributeId) {
    for (final AttributeGroup attributeGroup in attributeGroups!) {
      for (final Attribute item in attributeGroup.attributes!) {
        if (item.id == attributeId) {
          return attributeGroup;
        }
      }
    }
    throw Exception('unknown attribute group for $attributeId');
  }
}
