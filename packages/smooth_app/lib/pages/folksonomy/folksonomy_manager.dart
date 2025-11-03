import 'dart:async';
import 'dart:collection';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_folksonomy.dart';
import 'package:smooth_app/database/dao_transient_folksonomy.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/query/product_query.dart';

/// Writer class around Folksonomy, temporary until we implement BackgroundTasks
class FolksonomyManager {
  FolksonomyManager(this._localDatabase);

  final LocalDatabase _localDatabase;
  DaoFolksonomy get _daoFolksonomy => DaoFolksonomy(_localDatabase);
  DaoTransientFolksonomy get _daoTransientFolksonomy =>
      DaoTransientFolksonomy(_localDatabase);

  String? _bearerToken;

  Future<void> addTag(String barcode, String key, String value) async {
    final List<ProductTag> currentTags =
        await _daoFolksonomy.get(barcode) ?? <ProductTag>[];
    final bool exists = currentTags.any((ProductTag tag) => tag.key == key);
    if (exists) {
      throw Exception('This tag already exists!');
    }

    final ProductTag newProductTag = ProductTag(
      barcode: barcode,
      key: key,
      value: value,
      owner: '',
      version: 1,
      editor: '',
      lastEdit: DateTime.now(),
      comment: '',
    );

    await _daoTransientFolksonomy.put(barcode, <FolksonomyOperation>[
      ...getPendingOperationsByBarcode(barcode),
      FolksonomyOperation(type: FolksonomyAction.add, tag: newProductTag),
    ]);
    unawaited(syncProductTags(barcode));
  }

  Future<void> editTag(
    String barcode,
    String key,
    String newValue,
    int newVersion,
  ) async {
    final ProductTag editedProductTag = ProductTag(
      barcode: barcode,
      key: key,
      value: newValue,
      owner: '',
      version: newVersion,
      editor: '',
      lastEdit: DateTime.now(),
      comment: '',
    );

    await _daoTransientFolksonomy.put(barcode, <FolksonomyOperation>[
      ...getPendingOperationsByBarcode(barcode),
      FolksonomyOperation(type: FolksonomyAction.edit, tag: editedProductTag),
    ]);
    unawaited(syncProductTags(barcode));
  }

  Future<void> deleteTag(String barcode, String key, int version) async {
    final ProductTag tagToDelete = ProductTag(
      barcode: barcode,
      key: key,
      value: '',
      owner: '',
      version: version,
      editor: '',
      lastEdit: DateTime.now(),
      comment: '',
    );

    await _daoTransientFolksonomy.put(barcode, <FolksonomyOperation>[
      ...getPendingOperationsByBarcode(barcode),
      FolksonomyOperation(type: FolksonomyAction.remove, tag: tagToDelete),
    ]);
    unawaited(syncProductTags(barcode));
  }

  Future<void> syncAllProductTags() async {
    final List<String> barcodes = _daoTransientFolksonomy.getAllBarcodes();
    for (final String barcode in barcodes) {
      await syncProductTags(barcode);
    }
  }

  Future<void> syncProductTags(String barcode) async {
    final List<FolksonomyOperation> initialPendingOperations =
        getPendingOperationsByBarcode(barcode);
    if (initialPendingOperations.isEmpty) {
      return;
    }

    final Queue<FolksonomyOperation> pendingQueue =
        Queue<FolksonomyOperation>.of(initialPendingOperations);
    while (pendingQueue.isNotEmpty) {
      try {
        final FolksonomyOperation operation = pendingQueue.first;
        if (operation.type == FolksonomyAction.add) {
          await _syncAdd(operation.tag);
        } else if (operation.type == FolksonomyAction.edit) {
          await _syncEdit(operation.tag);
        } else if (operation.type == FolksonomyAction.remove) {
          await _syncDelete(operation.tag);
        }
        pendingQueue.removeFirst();
      } catch (e) {
        break;
      }
    }

    final List<FolksonomyOperation> stillPendingOperations = pendingQueue
        .toList();
    if (stillPendingOperations.isEmpty) {
      await _daoTransientFolksonomy.delete(barcode);
    } else {
      await _daoTransientFolksonomy.put(barcode, stillPendingOperations);
    }

    if (stillPendingOperations.length == initialPendingOperations.length) {
      // Avoid refreshing data and notifying listeners if no operations have been performed.
      return;
    }

    try {
      await refreshTagsFromRemote(barcode);
    } catch (e) {
      return;
    }
  }

  Future<void> _syncAdd(ProductTag tag) async {
    try {
      final String? bearerToken = await _getBearerToken();
      if (bearerToken == null) {
        return;
      }

      // FIXME: The addProduct tag method does not yet have a way to add a comment.
      final MaybeError<bool> result = await FolksonomyAPIClient.addProductTag(
        barcode: tag.barcode,
        key: tag.key,
        value: tag.value,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );
      if (result.isError) {
        throw Exception('${result.error}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _syncEdit(ProductTag tag) async {
    try {
      final String? bearerToken = await _getBearerToken();
      if (bearerToken == null) {
        return;
      }

      final MaybeError<bool> result =
          await FolksonomyAPIClient.updateProductTag(
            barcode: tag.barcode,
            key: tag.key,
            value: tag.value,
            version: tag.version,
            bearerToken: bearerToken,
            uriHelper: ProductQuery.uriFolksonomyHelper,
          );
      if (result.isError) {
        throw Exception('${result.error}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _syncDelete(ProductTag tag) async {
    try {
      final String? bearerToken = await _getBearerToken();
      if (bearerToken == null) {
        return;
      }

      final MaybeError<bool> result =
          await FolksonomyAPIClient.deleteProductTag(
            barcode: tag.barcode,
            key: tag.key,
            version: tag.version,
            bearerToken: bearerToken,
            uriHelper: ProductQuery.uriFolksonomyHelper,
          );
      if (result.isError) {
        throw Exception('${result.error}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshTagsFromRemote(String barcode) async {
    final Map<String, ProductTag> tags =
        await FolksonomyAPIClient.getProductTags(
          barcode: barcode,
          uriHelper: ProductQuery.uriFolksonomyHelper,
        );
    await _daoFolksonomy.put(barcode, tags.values.toList());

    _localDatabase.notifyListeners();
  }

  Future<String?> _getBearerToken() async {
    if (_bearerToken != null) {
      return _bearerToken!;
    }

    final User? user = OpenFoodAPIConfiguration.globalUser;
    if (user == null) {
      throw Exception('No user found');
    }

    try {
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

      _bearerToken = token.value;
      return token.value;
    } catch (err) {
      throw Exception('Could not get token');
    }
  }

  List<FolksonomyOperation> getPendingOperationsByBarcode(
    final String barcode,
  ) => _daoTransientFolksonomy.get(barcode);
}
