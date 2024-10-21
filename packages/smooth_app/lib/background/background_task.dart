import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_floating_message.dart';

/// Abstract background task.
abstract class BackgroundTask {
  BackgroundTask({
    required this.processName,
    required this.uniqueId,
    required this.stamp,
    final OpenFoodFactsLanguage? language,
  })   // TODO(monsieurtanuki): don't store the password in a clear format...
// TODO(monsieurtanuki): store the uriProductHelper as well
  : user = jsonEncode(ProductQuery.getWriteUser().toJson()),
        country = ProductQuery.getCountry().offTag,
        languageCode = (language ?? ProductQuery.getLanguage()).offTag;

  BackgroundTask._({
    required this.processName,
    required this.uniqueId,
    required this.languageCode,
    required this.user,
    required this.country,
    required this.stamp,
  });

  BackgroundTask.fromJson(Map<String, dynamic> json)
      : this._(
          processName: json[_jsonTagProcessName] as String,
          uniqueId: json[_jsonTagUniqueId] as String,
          languageCode: json[_jsonTagLanguageCode] as String,
          user: json[_jsonTagUser] as String,
          country: json[_jsonTagCountry] as String,
          stamp: json[_jsonTagStamp] as String,
        );

  static const String _jsonTagProcessName = 'processName';
  static const String _jsonTagUniqueId = 'uniqueId';
  static const String _jsonTagLanguageCode = 'languageCode';
  static const String _jsonTagUser = 'user';
  static const String _jsonTagCountry = 'country';
  static const String _jsonTagStamp = 'stamp';

  static String getProcessName(final Map<String, dynamic> map) =>
      map[_jsonTagProcessName] as String;

  /// Typically, similar to the name of the class that extends this one.
  ///
  /// To be used when deserializing, in order to check who is who.
  final String processName;

  /// Unique task identifier, needed e.g. for task overwriting.
  final String uniqueId;

  /// Generic task identifier, like "details:categories for barcode 1234", needed e.g. for task overwriting".
  final String stamp;

  final String languageCode;
  final String user;
  final String country;

  @mustCallSuper
  Map<String, dynamic> toJson() => <String, dynamic>{
        _jsonTagProcessName: processName,
        _jsonTagUniqueId: uniqueId,
        _jsonTagLanguageCode: languageCode,
        _jsonTagUser: user,
        _jsonTagCountry: country,
        _jsonTagStamp: stamp,
      };

  /// Executes the background task: upload, download, update locally.
  Future<void> execute(final LocalDatabase localDatabase);

  /// Executes the background task: upload, download, update locally.

  /// Runs _instantly_ temporary code in order to "fake" the background task.
  ///
  /// For instance, here we can pretend that we've changed the product name
  /// by doing it locally, but the background task that talks to the server
  /// is not even started.
  Future<void> preExecute(final LocalDatabase localDatabase);

  /// To be executed _after_ the actual run.
  ///
  /// Mostly, cleans the temporary data changes performed in [preExecute].
  /// [success] indicates (if `true`) that so far the operation was a success.
  /// With that `bool` we're able to deal with 2 cases:
  /// 1. everything is fine and we may have to do something more than cleaning
  /// 2. something bad happened and we just need to clear the task
  @mustCallSuper
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async =>
      localDatabase.upToDate.terminate(uniqueId);

  /// Returns true if the task may run now.
  ///
  /// Most tasks should always run immediately, but some should not, like
  /// [BackgroundTaskRefreshLater].
  bool mayRunNow() => true;

  /// Floating message when we add the task, like "Added to the task queue!"
  /// Also pass an [AlignmentGeometry] to express where it should be displayed
  ///
  /// Null if no message wanted (like, stealth mode).
  @protected
  (String, AlignmentGeometry)? getFloatingMessage(
    final AppLocalizations appLocalizations,
  );

  /// Adds this task to the [BackgroundTaskManager].
  @protected
  Future<void> addToManager(
    final LocalDatabase localDatabase, {
    final BuildContext? context,
    final bool showSnackBar = true,
  }) async {
    await BackgroundTaskManager.getInstance(localDatabase).add(this);
    if (context == null || !context.mounted) {
      return;
    }
    if (!showSnackBar) {
      return;
    }

    if (!context.mounted) {
      return;
    }
    if (getFloatingMessage(AppLocalizations.of(context))
        case (
          final String message,
          final AlignmentGeometry alignment,
        )) {
      SmoothFloatingMessage(message: message).show(
        context,
        duration: SnackBarDuration.medium,
        alignment: alignment,
      );
    }
  }

  @protected
  OpenFoodFactsLanguage getLanguage() => LanguageHelper.fromJson(languageCode);

  @protected
  OpenFoodFactsCountry? getCountry() =>
      OpenFoodFactsCountry.fromOffTag(country);

  @protected
  User getUser() {
    final User storedUser =
        User.fromJson(jsonDecode(user) as Map<String, dynamic>);
    final User currentUser = ProductQuery.getWriteUser();
    if (storedUser.userId == currentUser.userId) {
      // with a latest password.
      return currentUser;
    }
    return storedUser;
  }

  /// Checks that everything is fine and fix things if needed + if possible.
  ///
  /// To be run systematically for each task.
  /// Especially useful for transient files: if a user closed the app before
  /// successfully completing the upload task, the transient file - that is just
  /// a static variable - won't be there at app restart. Unless you recover.
  Future<void> recover(final LocalDatabase localDatabase) async {}

  /// Returns true if the task ends calling another task for immediate exec.
  ///
  /// We return true only in rare cases. Typically, when we split an task in
  /// subtasks that call the next one at the end.
  bool get hasImmediateNextTask => false;

  /// Returns true if tasks with the same stamp would overwrite each-other.
  bool isDeduplicable() => true;
}
