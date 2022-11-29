import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

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
      BackgroundTaskDetails.fromJson(map) ??
      BackgroundTaskImage.fromJson(map) ??
      BackgroundTaskRefreshLater.fromJson(map);

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

  /// Returns true if the task may run now.
  ///
  /// Most tasks should always run immediately, but some should not, like
  /// [BackgroundTaskRefreshLater].
  bool mayRunNow() => true;

  /// SnackBar message when we add the task, like "Added to the task queue!"
  ///
  /// Null if no SnackBar message wanted (like, stealth mode).
  @protected
  String? getSnackBarMessage(final AppLocalizations appLocalizations);

  /// Adds this task to the [BackgroundTaskManager].
  @protected
  Future<void> addToManager(
    final LocalDatabase localDatabase, {
    final State<StatefulWidget>? widget,
  }) async {
    await BackgroundTaskManager(localDatabase).add(this);
    if (widget == null || !widget.mounted) {
      return;
    }
    final String? snackBarMessage =
        getSnackBarMessage(AppLocalizations.of(widget.context));
    if (snackBarMessage != null) {
      ScaffoldMessenger.of(widget.context).showSnackBar(
        SnackBar(
          content: Text(snackBarMessage),
          duration: SnackBarDuration.medium,
        ),
      );
    }
  }

  @protected
  OpenFoodFactsLanguage getLanguage() => LanguageHelper.fromJson(languageCode);

  @protected
  OpenFoodFactsCountry? getCountry() => CountryHelper.fromJson(country);

  @protected
  User getUser() => User.fromJson(jsonDecode(user) as Map<String, dynamic>);

  /// Downloads the whole product, updates locally.
  Future<void> _downloadAndRefresh(final LocalDatabase localDatabase) async =>
      ProductRefresher().silentFetchAndRefresh(
        barcode: barcode,
        localDatabase: localDatabase,
      );
}
