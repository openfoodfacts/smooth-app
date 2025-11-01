import 'dart:async';

import 'package:collection/collection.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_folksonomy.dart';
import 'package:smooth_app/database/dao_transient_folksonomy_operation.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/query/product_query.dart';

class FolksonomyManager {
  FolksonomyManager(this._localDatabase);

  final LocalDatabase _localDatabase;
  OperationType get _operationType => OperationType.folksonomy;
  DaoFolksonomy get _daoFolksonomy => DaoFolksonomy(_localDatabase);
  DaoTransientFolksonomyOperation get _daoTransientFolksonomyOperation =>
      DaoTransientFolksonomyOperation(_localDatabase);

  String? _bearerToken;

  Future<void> addTag(String barcode, String key, String value) async {
    final List<ProductTag> currentTags =
        await _daoFolksonomy.get(barcode) ?? <ProductTag>[];
    final bool exists = currentTags.any((ProductTag tag) => tag.key == key);
    if (exists) {
      throw Exception('This tag already exists!');
    }

    final String operationKey = await _daoTransientFolksonomyOperation
        .getNewKey(_operationType, barcode);
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

    await _daoTransientFolksonomyOperation.put(
      operationKey,
      FolksonomyOperationValue(type: FolksonomyAction.add, tag: newProductTag),
    );

    unawaited(_syncAdd(currentTags, operationKey, newProductTag));
    _localDatabase.notifyListeners();
  }

  Future<void> editTag(String barcode, String key, String newValue) async {
    final List<ProductTag> currentTags =
        await _daoFolksonomy.get(barcode) ?? <ProductTag>[];
    final ProductTag? oldTag = currentTags.firstWhereOrNull(
      (ProductTag tag) => tag.key == key,
    );
    if (oldTag == null) {
      throw Exception('Tag not found');
    }

    final String operationKey = await _daoTransientFolksonomyOperation
        .getNewKey(_operationType, barcode);
    final ProductTag editedProductTag = ProductTag(
      barcode: barcode,
      key: key,
      value: newValue,
      owner: '',
      version: oldTag.version + 1,
      editor: '',
      lastEdit: DateTime.now(),
      comment: '',
    );

    await _daoTransientFolksonomyOperation.put(
      operationKey,
      FolksonomyOperationValue(
        type: FolksonomyAction.edit,
        tag: editedProductTag,
      ),
    );

    unawaited(_syncEdit(currentTags, operationKey, editedProductTag));
    _localDatabase.notifyListeners();
  }

  Future<void> deleteTag(String barcode, String key) async {
    final List<ProductTag> currentTags =
        await _daoFolksonomy.get(barcode) ?? <ProductTag>[];
    final ProductTag? tagToDelete = currentTags.firstWhereOrNull(
      (ProductTag tag) => tag.key == key,
    );
    if (tagToDelete == null) {
      throw Exception('Tag not found');
    }

    final String operationKey = await _daoTransientFolksonomyOperation
        .getNewKey(_operationType, barcode);
    await _daoTransientFolksonomyOperation.put(
      operationKey,
      FolksonomyOperationValue(type: FolksonomyAction.remove, tag: tagToDelete),
    );

    unawaited(_syncDelete(currentTags, operationKey, tagToDelete));
    _localDatabase.notifyListeners();
  }

  Future<void> syncProductTags(String barcode) async {
    final List<ProductTag> currentTags =
        await _daoFolksonomy.get(barcode) ?? <ProductTag>[];
    final Iterable<TransientFolksonomyOperation> pendingOperations =
        getSortedOperations(barcode);
    if (pendingOperations.isEmpty) {
      return;
    }

    for (final TransientFolksonomyOperation operation in pendingOperations) {
      final FolksonomyOperationValue value = operation.value;
      switch (value.type) {
        case FolksonomyAction.add:
          await _syncAdd(
            currentTags,
            operation.key,
            value.tag,
            notifyListeners: false,
          );
          break;
        case FolksonomyAction.edit:
          await _syncEdit(
            currentTags,
            operation.key,
            value.tag,
            notifyListeners: false,
          );
          break;
        case FolksonomyAction.remove:
          await _syncDelete(
            currentTags,
            operation.key,
            value.tag,
            notifyListeners: false,
          );
          break;
        case FolksonomyAction.visitUrl:
          break;
      }
    }

    _localDatabase.notifyListeners();
  }

  Future<void> _syncAdd(
    List<ProductTag> currentTags,
    String operationKey,
    ProductTag tag, {
    final bool notifyListeners = true,
  }) async {
    try {
      final String? bearerToken = await _getBearerToken();
      if (bearerToken == null) {
        return;
      }

      // FIXME: The addProduct tag method does not yet have a way to add a comment.
      await FolksonomyAPIClient.addProductTag(
        barcode: tag.barcode,
        key: tag.key,
        value: tag.value,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );
      await _daoTransientFolksonomyOperation.delete(operationKey);

      final List<ProductTag> updatedTags = <ProductTag>[...currentTags, tag];
      await _daoFolksonomy.put(tag.barcode, updatedTags);

      if (notifyListeners) {
        _localDatabase.notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to add tag $operationKey: $e');
    }
  }

  Future<void> _syncEdit(
    List<ProductTag> currentTags,
    String operationKey,
    ProductTag tag, {
    final bool notifyListeners = true,
  }) async {
    try {
      final String? bearerToken = await _getBearerToken();
      if (bearerToken == null) {
        return;
      }

      await FolksonomyAPIClient.updateProductTag(
        barcode: tag.barcode,
        key: tag.key,
        value: tag.value,
        version: tag.version,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );
      await _daoTransientFolksonomyOperation.delete(operationKey);

      final List<ProductTag> updatedTags = currentTags.map((ProductTag t) {
        if (t.key == tag.key) {
          return tag;
        }
        return t;
      }).toList();
      await _daoFolksonomy.put(tag.barcode, updatedTags);

      if (notifyListeners) {
        _localDatabase.notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to edit tag $operationKey: $e');
    }
  }

  Future<void> _syncDelete(
    List<ProductTag> currentTags,
    String operationKey,
    ProductTag tag, {
    final bool notifyListeners = true,
  }) async {
    try {
      final String? bearerToken = await _getBearerToken();
      if (bearerToken == null) {
        return;
      }

      await FolksonomyAPIClient.deleteProductTag(
        barcode: tag.barcode,
        key: tag.key,
        version: tag.version,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

      await _daoTransientFolksonomyOperation.delete(operationKey);

      final List<ProductTag> updatedTags = currentTags
          .where((ProductTag t) => t.key != tag.key)
          .toList();
      await _daoFolksonomy.put(tag.barcode, updatedTags);

      if (notifyListeners) {
        _localDatabase.notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to delete tag $operationKey: $e');
    }
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

  Iterable<TransientFolksonomyOperation> getSortedOperations(
    final String barcode,
  ) {
    final List<TransientFolksonomyOperation> result =
        <TransientFolksonomyOperation>[];
    result.addAll(_daoTransientFolksonomyOperation.getAll(barcode));
    result.sort(OperationType.sortFolksonomy);
    return result;
  }
}
