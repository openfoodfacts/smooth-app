import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/query/product_query.dart';

/// Abstract background task.
abstract class AbstractBackgroundTask {
  const AbstractBackgroundTask({
    required this.processName,
    required this.uniqueId,
    required this.barcode,
    required this.languageCode,
    required this.user,
    required this.country,
  });

  /// Typically, similar to the name of the class that extends this one.
  ///
  /// To be used when deserializing, in order to check who is who.
  final String processName;

  /// Unique task identifier, needed e.g. for task overwriting.
  final String uniqueId;

  final String barcode;
  final String languageCode;
  final String user;
  final String country;

  Map<String, dynamic> toJson();

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromJson(final Map<String, dynamic> map) =>
      BackgroundTaskDetails.fromJson(map) ?? BackgroundTaskImage.fromJson(map);

  /// Response code sent by the server in case of a success.
  @protected
  static const int SUCCESS_CODE = 1;

  /// Executes the background task: upload, download, update locally.
  Future<void> execute(final LocalDatabase localDatabase) async {
    await upload();
    await _downloadAndRefresh(localDatabase);
  }

  /// Runs _instantly_ temporary code in order to "fake" the background task.
  ///
  /// For instance, here we can pretend that we've changed the product name
  /// by doing it locally, but the background task that talks to the server
  /// is not even started.
  Future<void> preExecute(final LocalDatabase localDatabase);

  /// Cleans the temporary data changes performed in [preExecute].
  Future<void> postExecute(final LocalDatabase localDatabase);

  /// Uploads data changes.
  @protected
  Future<void> upload();

  /// SnackBar message when we add the task, like "Added to the task queue!"
  @protected
  String getSnackBarMessage(final AppLocalizations appLocalizations);

  /// Adds this task to the [BackgroundTaskManager].
  @protected
  Future<void> addToManager(final State<StatefulWidget> widget) async {
    if (!widget.mounted) {
      return;
    }
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    await BackgroundTaskManager(localDatabase).add(this);
    if (!widget.mounted) {
      return;
    }
    ScaffoldMessenger.of(widget.context).showSnackBar(
      SnackBar(
        content: Text(
          getSnackBarMessage(AppLocalizations.of(widget.context)),
        ),
        duration: SnackBarDuration.medium,
      ),
    );
  }

  @protected
  OpenFoodFactsLanguage getLanguage() => LanguageHelper.fromJson(languageCode);

  @protected
  OpenFoodFactsCountry? getCountry() => CountryHelper.fromJson(country);

  @protected
  User getUser() => User.fromJson(jsonDecode(user) as Map<String, dynamic>);

  /// Downloads the whole product, updates locally.
  Future<void> _downloadAndRefresh(final LocalDatabase localDatabase) async {
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      language: getLanguage(),
      country: getCountry(),
    );

    final ProductResult queryResult =
        await OpenFoodAPIClient.getProduct(configuration);
    if (queryResult.status == AbstractBackgroundTask.SUCCESS_CODE) {
      final Product? product = queryResult.product;
      if (product != null) {
        await daoProduct.put(product);
        localDatabase.upToDate.setLatestDownloadedProduct(product);
        localDatabase.notifyListeners();
        return;
      }
    }
    throw Exception('Could not download product!');
  }
}
