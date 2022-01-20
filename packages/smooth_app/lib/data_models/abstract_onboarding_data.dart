import 'package:flutter/material.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';

/// Abstraction of data we download, store and reuse at onboarding.
abstract class AbstractOnboardingData<T> {
  AbstractOnboardingData(this._localDatabase);

  final LocalDatabase _localDatabase;

  /// Fake barcode provided by the back-end, designed for onboarding.
  static const String barcode = 'example';

  /// Gets the data, either as recently downloaded, or as asset (fallback).
  Future<T> getData(final AssetBundle rootBundle) async {
    try {
      return getDataFromString(
        await DaoString(_localDatabase).get(_getDatabaseKey()),
      )!;
    } catch (e) {
      //
    }
    return getDataFromString(
      await rootBundle.loadString(getAssetPath()),
    )!;
  }

  /// Removes the downloaded data from the database.
  ///
  /// Typical use case: data we downloaded just for the onboarding,
  /// that we can clear after the onboarding.
  Future<void> clear() async =>
      DaoString(_localDatabase).put(_getDatabaseKey(), null);

  /// Downloads data and store it locally.
  Future<void> downloadData() async {
    try {
      final String string = await downloadDataString();
      final DaoString daoString = DaoString(_localDatabase);
      await daoString.put(_getDatabaseKey(), string);
    } catch (e) {
      //
    }
  }

  /// Converts a string into the expected object, even null.
  T? getDataFromString(final String? jsonString) {
    if (jsonString == null) {
      return null;
    }
    return getDataFromNonNullString(jsonString);
  }

  /// Converts a string into the expected object.
  @protected
  T getDataFromNonNullString(final String jsonString);

  /// Downloads a data and returns it.
  @protected
  Future<String> downloadDataString();

  /// Asset Path to the fallback string.
  @protected
  String getAssetPath();

  /// Database key used to store the string.
  String _getDatabaseKey() => '${getAssetPath()}'
      '/${ProductQuery.getLanguage()}'
      '/${ProductQuery.getCountry()}';
}
