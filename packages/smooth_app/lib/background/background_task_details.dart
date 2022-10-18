import 'dart:convert';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/database/dao_transient_operation.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:task_manager/task_manager.dart';

/// Background task that changes product details (data, but no image upload).
class BackgroundTaskDetails extends AbstractBackgroundTask {
  const BackgroundTaskDetails._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required this.inputMap,
  });

  BackgroundTaskDetails._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          inputMap: json['inputMap'] as String,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'PRODUCT_EDIT';

  /// Serialized product.
  final String inputMap;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'inputMap': inputMap,
      };

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromTask(final Task task) {
    try {
      final AbstractBackgroundTask result =
          BackgroundTaskDetails._fromJson(task.data!);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  /// Adds the background task and the pending changes.
  ///
  /// Returns true if successful (task added, local change added).
  static Future<bool> addTask({
    required final Product minimalistProduct,
    required final LocalDatabase localDatabase,
    final List<ProductEditTask>? productEditTasks,
    final ProductEditTask? productEditTask,
  }) async {
    try {
      localDatabase.upToDate.addChange(minimalistProduct);
      final BackgroundTaskDetails backgroundTask = _computeNewTask(
        minimalistProduct,
        productEditTask: productEditTask,
        productEditTasks: productEditTasks,
        sequenceNumber: localDatabase.getLocalUniqueSequenceNumber(),
      );
      /*
      // TODO 0000 temporairement, ne pas utiliser les taches de fond
      // background version
      final Task task = Task(
        data: backgroundTask.toJson(),
        uniqueId: backgroundTask.uniqueId,
      );
      await TaskManager().addTask(task);
      */
      // TODO temporarily, execute now!
      backgroundTask.execute(localDatabase); // no `await`
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Returns the background task about changing a product.
  ///
  /// Either [productEditTask] or [productEditTasks] must be populated;
  /// we need that for classification purpose (and unique id computation).
  static BackgroundTaskDetails _computeNewTask(
    final Product minimalistProduct, {
    final List<ProductEditTask>? productEditTasks,
    final ProductEditTask? productEditTask,
    required final int sequenceNumber,
  }) {
    final String code;
    if (productEditTask != null) {
      if (productEditTasks != null) {
        throw Exception();
      }
      code = productEditTask.code;
    } else {
      if (productEditTasks == null || productEditTasks.isEmpty) {
        throw Exception();
      }
      final StringBuffer buffer = StringBuffer();
      for (final ProductEditTask task in productEditTasks) {
        buffer.write(task.code);
      }
      code = buffer.toString();
    }
    final String uniqueId = AbstractBackgroundTask.generateUniqueId(
      minimalistProduct.barcode!,
      code,
      sequenceNumber: sequenceNumber,
    );
    return BackgroundTaskDetails._(
      uniqueId: uniqueId,
      processName: _PROCESS_NAME,
      barcode: minimalistProduct.barcode!,
      languageCode: ProductQuery.getLanguage().code,
      inputMap: jsonEncode(minimalistProduct.toJson()),
      user: jsonEncode(ProductQuery.getUser().toJson()),
      country: ProductQuery.getCountry()!.iso2Code,
    );
  }

  /// Executes the background task: upload, download, update locally.
  @override
  Future<TaskResult> execute(final LocalDatabase localDatabase) async {
    final Iterable<TransientOperation>? sortedOperations =
        localDatabase.upToDate.getSortedChangeOperations(barcode);
    if (sortedOperations == null || sortedOperations.isEmpty) {
      // everything was already done before
      return TaskResult.success;
    }
    final Product product = localDatabase.upToDate.prepareChangesForServer(
      barcode,
      sortedOperations,
    );

    final Status status = await OpenFoodAPIClient.saveProduct(
      getUser(),
      product,
      language: getLanguage(),
      country: getCountry(),
    );
    if (status.status != AbstractBackgroundTask.SUCCESS_CODE) {
      return TaskResult.errorAndRetry;
    }

    final Product? downloaded = await downloadAndRefresh(localDatabase);
    if (downloaded == null) {
      return TaskResult.errorAndRetry;
    }
    localDatabase.upToDate.terminate(barcode, sortedOperations);
    localDatabase.upToDate.setLatestDownloadedProduct(downloaded);

    return TaskResult.success;
  }
}

/// Product edit single tasks.
///
/// Used for classification (and unique id computation).
enum ProductEditTask {
  nutrition('N'),
  packaging('P'),
  ingredient('I'),
  basic('B'),
  store('S'),
  origin('O'),
  emb('E'),
  label('L'),
  category('K'),
  country('C');

  const ProductEditTask(this.code);

  /// Code used to distinguish the tasks.
  ///
  /// Of course there shouldn't be duplicates.
  final String code;
}
