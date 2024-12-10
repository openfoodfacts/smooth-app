import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_add_other_price.dart';
import 'package:smooth_app/background/background_task_add_price.dart';
import 'package:smooth_app/background/background_task_crop.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/background/background_task_download_products.dart';
import 'package:smooth_app/background/background_task_full_refresh.dart';
import 'package:smooth_app/background/background_task_hunger_games.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_language_refresh.dart';
import 'package:smooth_app/background/background_task_offline.dart';
import 'package:smooth_app/background/background_task_progressing.dart';
import 'package:smooth_app/background/background_task_refresh_later.dart';
import 'package:smooth_app/background/background_task_top_barcodes.dart';
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
  offlineBarcodes('B', 'OFFLINE_BARCODES'),
  offlineProducts('P', 'OFFLINE_PRODUCTS'),
  fullRefresh('F', 'FULL_REFRESH'),
  languageRefresh('L', 'LANGUAGE_REFRESH'),
  addPrice('A', 'ADD_PRICE'),
  addOtherPrice('E', 'ADD_OTHER_PRICE'),
  details('D', 'PRODUCT_EDIT');

  const OperationType(this.header, this.processName);

  final String header;

  /// Process Name, that helps building tasks.
  final String processName;

  static const String _transientHeaderSeparator = ';';

  static const String _uniqueSequenceKey = 'OperationType';

  Future<String> getNewKey(
    final LocalDatabase localDatabase, {
    final String? barcode = BackgroundTaskProgressing.noBarcode,
    final int? totalSize,
    final int? soFarSize,
    final String? work,
    final ProductType? productType,
  }) async {
    final int sequentialId =
        await getNextSequenceNumber(DaoInt(localDatabase), _uniqueSequenceKey);
    return '$header'
        '$_transientHeaderSeparator$sequentialId'
        '$_transientHeaderSeparator$barcode'
        '$_transientHeaderSeparator${totalSize == null ? '' : totalSize.toString()}'
        '$_transientHeaderSeparator${soFarSize == null ? '' : soFarSize.toString()}'
        '$_transientHeaderSeparator${work ?? ''}'
        '$_transientHeaderSeparator${productType == null ? '' : productType.offTag}';
  }

  BackgroundTask fromJson(Map<String, dynamic> map) => switch (this) {
        crop => BackgroundTaskCrop.fromJson(map),
        addPrice => BackgroundTaskAddPrice.fromJson(map),
        addOtherPrice => BackgroundTaskAddOtherPrice.fromJson(map),
        details => BackgroundTaskDetails.fromJson(map),
        hungerGames => BackgroundTaskHungerGames.fromJson(map),
        image => BackgroundTaskImage.fromJson(map),
        refreshLater => BackgroundTaskRefreshLater.fromJson(map),
        unselect => BackgroundTaskUnselect.fromJson(map),
        offline => BackgroundTaskOffline.fromJson(map),
        offlineBarcodes => BackgroundTaskTopBarcodes.fromJson(map),
        offlineProducts => BackgroundTaskDownloadProducts.fromJson(map),
        fullRefresh => BackgroundTaskFullRefresh.fromJson(map),
        languageRefresh => BackgroundTaskLanguageRefresh.fromJson(map),
      };

  bool matches(final TransientOperation action) =>
      action.key.startsWith('$header$_transientHeaderSeparator');

  String getLabel(final AppLocalizations appLocalizations) => switch (this) {
        OperationType.details =>
          appLocalizations.background_task_operation_details,
        OperationType.addPrice => 'Add price',
        OperationType.addOtherPrice => 'Add price to existing proof',
        OperationType.image => appLocalizations.background_task_operation_image,
        OperationType.unselect => 'Unselect a product image',
        OperationType.hungerGames => 'Answering to a Hunger Games question',
        OperationType.crop => 'Crop an existing image',
        OperationType.refreshLater =>
          'Waiting 10 min before refreshing product to get all automatic edits',
        OperationType.offline => 'Downloading top n products for offline usage',
        OperationType.offlineBarcodes => 'Downloading top n barcodes',
        OperationType.offlineProducts => 'Downloading products',
        OperationType.fullRefresh => 'Refreshing the full local database',
        OperationType.languageRefresh =>
          'Refreshing the local database to a new language',
      };

  static int getSequentialId(final TransientOperation operation) {
    final List<String> keyItems =
        operation.key.split(_transientHeaderSeparator);
    return int.parse(keyItems[1]);
  }

  static String getBarcode(final String key) => _getNthParameter(key, 2)!;

  static int? getTotalSize(final String key) => _getNthIntParameter(key, 3);

  static int? getSoFarSize(final String key) => _getNthIntParameter(key, 4);

  static String? getWork(final String key) => _getNthParameter(key, 5);

  static String? getProductType(final String key) => _getNthParameter(key, 6);

  static String? _getNthParameter(final String key, final int index) {
    final List<String> keyItems = key.split(_transientHeaderSeparator);
    if (keyItems.length <= index) {
      return null;
    }
    return keyItems[index];
  }

  static int? _getNthIntParameter(final String key, final int index) {
    final String? parameter = _getNthParameter(key, index);
    if (parameter == null) {
      return null;
    }
    return int.tryParse(parameter);
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
