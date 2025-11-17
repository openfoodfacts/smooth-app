import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_folksonomy.dart';
import 'package:smooth_app/database/dao_transient_folksonomy.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_operation.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/query/product_query.dart';

class BackgroundTaskFolksonomy extends BackgroundTask {
  BackgroundTaskFolksonomy._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    required this.barcode,
  });

  BackgroundTaskFolksonomy.fromJson(super.json)
    : barcode = json[_jsonTagBarcode] as String,
      super.fromJson();

  final String barcode;

  static const String _jsonTagBarcode = 'barcode';
  static const OperationType _operationType = OperationType.folksonomy;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagBarcode] = barcode;
    return result;
  }

  static Future<void> addTask(
    final String barcode,
    final LocalDatabase localDatabase,
  ) async {
    final String uniqueId = await _operationType.getNewKey(
      localDatabase,
      barcode: barcode,
    );
    final BackgroundTask task = _getNewTask(uniqueId, barcode);
    await task.addToManager(localDatabase, queue: BackgroundTaskQueue.fast);
  }

  static BackgroundTask _getNewTask(
    final String uniqueId,
    final String barcode,
  ) => BackgroundTaskFolksonomy._(
    processName: _operationType.processName,
    uniqueId: uniqueId,
    stamp: '$barcode;folksonomy;',
    barcode: barcode,
  );

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
    AppLocalizations appLocalizations,
  ) => (
    appLocalizations.background_task_title_folksonomy,
    AlignmentDirectional.bottomCenter,
  );

  @override
  Future<void> execute(LocalDatabase localDatabase) async {
    final DaoTransientFolksonomy daoTransientFolksonomy =
        DaoTransientFolksonomy(localDatabase);
    final DaoFolksonomy daoFolksonomy = DaoFolksonomy(localDatabase);

    String? bearerToken;
    while (true) {
      final FolksonomyOperation? operation = _getPendingOperations(
        barcode,
        daoTransientFolksonomy,
      )?.firstOrNull;

      if (operation == null) {
        return;
      }

      if (!operation.isPerformed) {
        bearerToken ??= await _getBearerToken();

        switch (operation.type) {
          case FolksonomyAction.add:
            await _serverAdd(operation.tag, bearerToken);
            break;
          case FolksonomyAction.edit:
            await _serverEdit(operation.tag, bearerToken);
            break;
          case FolksonomyAction.remove:
            await _serverDelete(operation.tag, bearerToken);
            break;
          default:
            throw Exception('Invalid operation type: ${operation.type}');
        }

        final List<FolksonomyOperation>? pendingOperations =
            _getPendingOperations(barcode, daoTransientFolksonomy);
        if (pendingOperations == null || pendingOperations.isEmpty) {
          throw Exception(
            'As we have just performed an operation, there should be at least this operation in the queue.',
          );
        }

        pendingOperations[0].isPerformed = true;
        await daoTransientFolksonomy.put(barcode, pendingOperations);
      }

      await serverRefresh(barcode, daoFolksonomy, localDatabase);

      final List<FolksonomyOperation>? pendingOperations =
          _getPendingOperations(barcode, daoTransientFolksonomy);
      if (pendingOperations == null ||
          pendingOperations.isEmpty ||
          !pendingOperations.first.isPerformed) {
        throw Exception(
          'As we have just performed an operation, there should be at least this operation, as performed, in the queue.',
        );
      }

      pendingOperations.removeAt(0);

      if (pendingOperations.isEmpty) {
        await daoTransientFolksonomy.delete(barcode);
      } else {
        await daoTransientFolksonomy.put(barcode, pendingOperations);
      }
    }
  }

  Future<void> _serverAdd(ProductTag tag, String bearerToken) async {
    // FIXME: The addProduct tag method does not yet have a way to add a comment.
    final MaybeError<bool> result = await FolksonomyAPIClient.addProductTag(
      barcode: tag.barcode,
      key: tag.key,
      value: tag.value,
      bearerToken: bearerToken,
      uriHelper: ProductQuery.uriFolksonomyHelper,
    );
    if (result.isError) {
      throw Exception('Cannot add product tag: ${result.error}');
    }
  }

  Future<void> _serverEdit(ProductTag tag, String bearerToken) async {
    final MaybeError<bool> result = await FolksonomyAPIClient.updateProductTag(
      barcode: tag.barcode,
      key: tag.key,
      value: tag.value,
      version: tag.version,
      bearerToken: bearerToken,
      uriHelper: ProductQuery.uriFolksonomyHelper,
    );
    if (result.isError) {
      throw Exception('Cannot edit product tag: ${result.error}');
    }
  }

  Future<void> _serverDelete(ProductTag tag, String bearerToken) async {
    final MaybeError<bool> result = await FolksonomyAPIClient.deleteProductTag(
      barcode: tag.barcode,
      key: tag.key,
      version: tag.version,
      bearerToken: bearerToken,
      uriHelper: ProductQuery.uriFolksonomyHelper,
    );
    if (result.isError) {
      throw Exception('Cannot delete product tag: ${result.error}');
    }
  }

  static Future<void> serverRefresh(
    String barcode,
    DaoFolksonomy daoFolksonomy,
    LocalDatabase localDatabase,
  ) async {
    final Map<String, ProductTag> tags =
        await FolksonomyAPIClient.getProductTags(
          barcode: barcode,
          uriHelper: ProductQuery.uriFolksonomyHelper,
        );
    await daoFolksonomy.put(barcode, tags.values.toList());

    localDatabase.notifyListeners();
  }

  List<FolksonomyOperation>? _getPendingOperations(
    String barcode,
    DaoTransientFolksonomy daoTransientFolksonomy,
  ) => daoTransientFolksonomy.get(barcode);

  Future<String> _getBearerToken() async {
    final User? user = OpenFoodAPIConfiguration.globalUser;
    if (user == null) {
      throw Exception('No user found');
    }

    final MaybeError<String> token =
        await FolksonomyAPIClient.getAuthenticationToken(
          username: user.userId,
          password: user.password,
          uriHelper: ProductQuery.uriFolksonomyHelper,
        );

    if (token.isError) {
      throw Exception('Could not get token: ${token.error}');
    }

    if (token.value.isEmpty) {
      throw Exception('Unexpected empty token');
    }

    return token.value;
  }

  @override
  Future<void> preExecute(LocalDatabase localDatabase) async {}
}
