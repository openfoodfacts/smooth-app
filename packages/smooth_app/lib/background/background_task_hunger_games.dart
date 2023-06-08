import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/robotoff_insight_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Background task about answering a hunger games question.
class BackgroundTaskHungerGames extends AbstractBackgroundTask {
  const BackgroundTaskHungerGames._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.insightId,
    required this.insightAnnotation,
  });

  BackgroundTaskHungerGames._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          stamp: json['stamp'] as String,
          insightId: json['insightId'] as String,
          insightAnnotation: json['insightAnnotation'] as int,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'HUNGER_GAMES';

  static const OperationType _operationType = OperationType.hungerGames;

  final String insightId;
  final int insightAnnotation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'stamp': stamp,
        'insightId': insightId,
        'insightAnnotation': insightAnnotation,
      };

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromJson(final Map<String, dynamic> map) {
    try {
      final AbstractBackgroundTask result =
          BackgroundTaskHungerGames._fromJson(map);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  /// Adds the background task about hunger games.
  static Future<void> addTask({
    required final String barcode,
    required final String insightId,
    required final InsightAnnotation insightAnnotation,
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode,
    );
    final AbstractBackgroundTask task = _getNewTask(
      barcode,
      insightId,
      insightAnnotation.value,
      uniqueId,
    );
    await task.addToManager(localDatabase, widget: widget);
  }

  @override
  String? getSnackBarMessage(final AppLocalizations appLocalizations) => null;

  /// Returns a new background task about hunger games.
  static BackgroundTaskHungerGames _getNewTask(
    final String barcode,
    final String insightId,
    final int insightAnnotation,
    final String uniqueId,
  ) =>
      BackgroundTaskHungerGames._(
        processName: _PROCESS_NAME,
        uniqueId: uniqueId,
        barcode: barcode,
        languageCode: ProductQuery.getLanguage().offTag,
        user: jsonEncode(ProductQuery.getUser().toJson()),
        country: ProductQuery.getCountry()!.offTag,
        stamp: _getStamp(barcode, insightId),
        insightId: insightId,
        insightAnnotation: insightAnnotation,
      );

  static String _getStamp(final String barcode, final String insightId) =>
      '$barcode;hungerGames;$insightId';

  @override
  Future<void> preExecute(final LocalDatabase localDatabase) async {}

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    final RobotoffInsightHelper robotoffInsightHelper =
        RobotoffInsightHelper(localDatabase);
    await robotoffInsightHelper.cacheInsightAnnotationVoted(
      barcode,
      insightId,
    );
  }

  /// Unselects the product image.
  @override
  Future<void> upload() async {
    final InsightAnnotation? annotation =
        _getInsightAnnotation(insightAnnotation);
    if (annotation == null) {
      // very unlikely
      return;
    }
    await RobotoffAPIClient.postInsightAnnotation(
      insightId.isEmpty ? null : insightId,
      annotation,
      deviceId: OpenFoodAPIConfiguration.uuid,
    );
  }

  // TODO(monsieurtanuki): move to off-dart
  static InsightAnnotation? _getInsightAnnotation(final int annotation) {
    for (final InsightAnnotation insightAnnotation
        in InsightAnnotation.values) {
      if (annotation == insightAnnotation.value) {
        return insightAnnotation;
      }
    }
    return null;
  }
}
