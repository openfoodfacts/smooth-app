import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_crop.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/background/background_task_full_refresh.dart';
import 'package:smooth_app/background/background_task_hunger_games.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_offline.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_unselect.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/database_helper.dart';

/// Type of a transient operation.
///
/// We need a type to discriminate between operations (cf. [getNewKey]).
/// When we are in a collection of operations, the keys will helper us know
/// * which type (cf. [matches])
/// * which order (cf. [getSequentialId], [sort])
/// * possibly, which barcode (not useful yet)
enum OperationType {
  image('I', 'IMAGE_UPLOAD'),
  crop('C', 'IMAGE_CROP'),
  unselect('U', 'IMAGE_UNSELECT'),
  hungerGames('H', 'HUNGER_GAMES'),
  refreshLater('R', 'PRODUCT_REFRESH_LATER'),
  offline('O', 'OFFLINE_PREDOWNLOAD'),
  fullRefresh('F', 'FULL_REFRESH'),
  details('D', 'PRODUCT_EDIT');

  const OperationType(this.header, this.processName);

  final String header;

  /// Process Name, that helps building tasks.
  final String processName;

  static const String _transientHeaderSeparator = ';';

  static const String _uniqueSequenceKey = 'OperationType';

  Future<String> getNewKey(
    final LocalDatabase localDatabase,
    final String barcode,
  ) async {
    final int sequentialId =
        await getNextSequenceNumber(DaoInt(localDatabase), _uniqueSequenceKey);
    return '$header'
        '$_transientHeaderSeparator$sequentialId'
        '$_transientHeaderSeparator$barcode';
  }

  BackgroundTask fromJson(Map<String, dynamic> map) {
    switch (this) {
      case crop:
        return BackgroundTaskCrop.fromJson(map);
      case details:
        return BackgroundTaskDetails.fromJson(map);
      case hungerGames:
        return BackgroundTaskHungerGames.fromJson(map);
      case image:
        return BackgroundTaskImage.fromJson(map);
      case refreshLater:
        return BackgroundTaskRefreshLater.fromJson(map);
      case unselect:
        return BackgroundTaskUnselect.fromJson(map);
      case offline:
        return BackgroundTaskOffline.fromJson(map);
      case fullRefresh:
        return BackgroundTaskFullRefresh.fromJson(map);
    }
  }

  bool matches(final TransientOperation action) =>
      action.key.startsWith('$header$_transientHeaderSeparator');

  String getLabel(final AppLocalizations appLocalizations) {
    switch (this) {
      case OperationType.details:
        return appLocalizations.background_task_operation_details;
      case OperationType.image:
        return appLocalizations.background_task_operation_image;
      case OperationType.unselect:
        return 'Unselect a product image';
      case OperationType.hungerGames:
        return 'Answering to a Hunger Games question';
      case OperationType.crop:
        return 'Crop an existing image';
      case OperationType.refreshLater:
        return 'Waiting 10 min before refreshing product to get all automatic edits';
      case OperationType.offline:
        return 'Downloading top n products for offline usage';
      case OperationType.fullRefresh:
        return 'Refreshing the full local database';
    }
  }

  static int getSequentialId(final TransientOperation operation) {
    final List<String> keyItems =
        operation.key.split(_transientHeaderSeparator);
    return int.parse(keyItems[1]);
  }

  static String getBarcode(final String key) {
    final List<String> keyItems = key.split(_transientHeaderSeparator);
    return keyItems[2];
  }

  static OperationType? getOperationType(final String key) {
    final List<String> keyItems = key.split(_transientHeaderSeparator);
    final String find = keyItems[0];
    for (final OperationType operationType in OperationType.values) {
      if (operationType.header == find) {
        return operationType;
      }
    }
    return null;
  }

  static int sort(
    final TransientOperation operationA,
    final TransientOperation operationB,
  ) =>
      getSequentialId(operationA).compareTo(getSequentialId(operationB));
}
