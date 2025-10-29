import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/dao_folksonomy.dart';
import 'package:smooth_app/database/dao_transient_folksonomy_operation.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';

class FolksonomyProvider extends ValueNotifier<FolksonomyState> {
  FolksonomyProvider(
    this.barcode,
    this._daoFolksonomy,
    this._daoTransientFolksonomyOperation,
    this._productRefresher,
  ) : super(const FolksonomyStateLoading());

  final String barcode;
  final DaoTransientFolksonomyOperation _daoTransientFolksonomyOperation;
  final DaoFolksonomy _daoFolksonomy;
  String? _bearerToken;
  final List<ProductTag> _tags = <ProductTag>[];
  final ProductRefresher _productRefresher;
  final OperationType _operationType = OperationType.folksonomy;

  Future<void> init(BuildContext context) async {
    await fetchProductTags();
    if (!context.mounted) {
      return;
    }
    unawaited(_syncProductTags(context));
  }

  Future<String?> _getBearerToken(BuildContext context) async {
    if (_bearerToken != null) {
      return _bearerToken!;
    }

    final bool isLoggedIn = await _productRefresher.checkIfLoggedIn(
      context,
      isLoggedInMandatory: true,
    );

    if (!isLoggedIn) {
      return null;
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

  // Display tags from local database first (to see it offline), then update from API.
  Future<void> fetchProductTags() async {
    if (_tags.isEmpty) {
      value = const FolksonomyStateLoading();
    }

    final List<ProductTag>? localTags = await _daoFolksonomy.get(barcode);
    if (localTags != null) {
      _updateTags(localTags);
    }

    try {
      final Map<String, ProductTag> tags =
          await FolksonomyAPIClient.getProductTags(
            barcode: barcode,
            uriHelper: ProductQuery.uriFolksonomyHelper,
          );
      final List<ProductTag> remoteTags = tags.values.toList();

      await _daoFolksonomy.put(barcode, remoteTags);
      _updateTags(remoteTags);
    } catch (e) {
      if (_tags.isEmpty) {
        value = FolksonomyStateError(error: e);
      }
    }
  }

  Future<void> addTag(BuildContext context, String key, String value) async {
    try {
      final ProductTag? tag = _getTag(key);
      if (tag != null) {
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
        FolksonomyOperationValue(
          type: FolksonomyAction.add,
          tag: newProductTag,
        ),
      );

      _tags.add(newProductTag);
      _sortTags();

      this.value = FolksonomyStateAddedItem(
        tags: _tags,
        addedPosition: _getPosition(key),
        item: newProductTag,
      );

      if (!context.mounted) {
        return;
      }
      unawaited(_syncAdd(context, operationKey, newProductTag));
    } catch (e) {
      this.value = FolksonomyStateError(
        error: e,
        action: FolksonomyAction.add,
        tags: _tags,
      );
    }
  }

  Future<void> editTag(
    BuildContext context,
    String key,
    String newValue,
  ) async {
    try {
      final ProductTag? tag = _getTag(key);
      if (tag == null) {
        throw Exception('Tag not found');
      }

      final String operationKey = await _daoTransientFolksonomyOperation
          .getNewKey(_operationType, barcode);
      final ProductTag editedProductTag = ProductTag(
        barcode: barcode,
        key: key,
        value: newValue,
        owner: '',
        version: tag.version + 1,
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

      final int position = _getPosition(key);
      _tags[position] = editedProductTag;
      value = FolksonomyStateEditedItem(
        tags: _tags,
        item: editedProductTag,
        position: position,
      );

      if (!context.mounted) {
        return;
      }
      unawaited(_syncEdit(context, operationKey, editedProductTag));
    } catch (e) {
      value = FolksonomyStateError(
        error: e,
        action: FolksonomyAction.edit,
        tags: _tags,
      );
    }
  }

  Future<void> deleteTag(BuildContext context, String key) async {
    try {
      final ProductTag? tag = _getTag(key);
      if (tag == null) {
        throw Exception('Tag not found');
      }

      final String operationKey = await _daoTransientFolksonomyOperation
          .getNewKey(_operationType, barcode);
      final ProductTag deletedProductTag = tag;

      await _daoTransientFolksonomyOperation.put(
        operationKey,
        FolksonomyOperationValue(
          type: FolksonomyAction.remove,
          tag: deletedProductTag,
        ),
      );

      final int position = _getPosition(key);
      _tags.removeAt(position);

      value = FolksonomyStateRemovedItem(
        tags: _tags,
        removedPosition: position,
        item: tag,
      );

      if (!context.mounted) {
        return;
      }
      unawaited(_syncDelete(context, operationKey, deletedProductTag));
    } catch (e) {
      value = FolksonomyStateError(
        error: e,
        action: FolksonomyAction.remove,
        tags: _tags,
      );
    }
  }

  void markAsConsumed() {
    value = FolksonomyStateLoaded(tags: _tags);
  }

  Future<void> fetchKeys({String? query}) async {
    try {
      value = const FolksonomyStateLoading();

      final Map<String, KeyStats> keyStats = await FolksonomyAPIClient.getKeys(
        query: query,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

      value = FolksonomyStateKeysLoaded(keys: keyStats, tags: _tags);
    } catch (e) {
      value = FolksonomyStateError(error: e);
    }
  }

  int _getPosition(String key) =>
      _tags.indexWhere((ProductTag tag) => tag.key == key);

  ProductTag? _getTag(String key) =>
      _tags.firstWhereOrNull((ProductTag tag) => tag.key == key);

  void _updateTags(final List<ProductTag> tags) {
    if (_equals(tags)) {
      if (value is! FolksonomyStateLoaded) {
        value = FolksonomyStateLoaded(tags: _tags);
      }
      return;
    }
    _tags.clear();
    _tags.addAll(tags);
    _sortTags();
    value = FolksonomyStateLoaded(tags: _tags);
  }

  bool _equals(final List<ProductTag> tags) {
    final List<ProductTag> sortedTags = List<ProductTag>.from(tags);
    _sortTags(sortedTags);
    return const DeepCollectionEquality().equals(_tags, sortedTags);
  }

  void _sortTags([List<ProductTag>? tags]) {
    final List<ProductTag> toSort = tags ?? _tags;
    toSort.sort((ProductTag a, ProductTag b) => a.key.compareTo(b.key));
  }

  Future<void> _syncProductTags(BuildContext context) async {
    final Iterable<TransientFolksonomyOperation> pendingOperations =
        _getSortedOperations(barcode);
    if (pendingOperations.isEmpty) {
      return;
    }

    for (final TransientFolksonomyOperation operation in pendingOperations) {
      if (!context.mounted) {
        return;
      }
      final FolksonomyOperationValue value = operation.value;
      switch (value.type) {
        case FolksonomyAction.add:
          await _syncAdd(context, operation.key, value.tag);
          break;
        case FolksonomyAction.edit:
          await _syncEdit(context, operation.key, value.tag);
          break;
        case FolksonomyAction.remove:
          await _syncDelete(context, operation.key, value.tag);
          break;
      }
    }
  }

  Future<void> _syncAdd(
    BuildContext context,
    String operationKey,
    ProductTag tag,
  ) async {
    try {
      final String? bearerToken = await _getBearerToken(context);
      if (bearerToken == null) {
        return;
      }

      // to-do: The addProduct tag method does not yet have a way to add a comment.
      await FolksonomyAPIClient.addProductTag(
        barcode: barcode,
        key: tag.key,
        value: tag.value,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

      await _daoTransientFolksonomyOperation.delete(operationKey);
      await _daoFolksonomy.put(barcode, _tags);
    } catch (e) {
      throw Exception('Failed to add tag $operationKey: $e');
    }
  }

  Future<void> _syncEdit(
    BuildContext context,
    String operationKey,
    ProductTag tag,
  ) async {
    try {
      final String? bearerToken = await _getBearerToken(context);
      if (bearerToken == null) {
        return;
      }

      await FolksonomyAPIClient.updateProductTag(
        barcode: barcode,
        key: tag.key,
        value: tag.value,
        version: tag.version,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

      await _daoTransientFolksonomyOperation.delete(operationKey);
      await _daoFolksonomy.put(barcode, _tags);
    } catch (e) {
      throw Exception('Failed to edit tag $operationKey: $e');
    }
  }

  Future<void> _syncDelete(
    BuildContext context,
    String operationKey,
    ProductTag tag,
  ) async {
    try {
      final String? bearerToken = await _getBearerToken(context);
      if (bearerToken == null) {
        return;
      }

      await FolksonomyAPIClient.deleteProductTag(
        barcode: barcode,
        key: tag.key,
        version: tag.version,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

      await _daoTransientFolksonomyOperation.delete(operationKey);
      await _daoFolksonomy.put(barcode, _tags);
    } catch (e) {
      throw Exception('Failed to delete tag $operationKey: $e');
    }
  }

  Iterable<TransientFolksonomyOperation> _getSortedOperations(
    final String barcode,
  ) {
    final List<TransientFolksonomyOperation> result =
        <TransientFolksonomyOperation>[];
    result.addAll(_daoTransientFolksonomyOperation.getAll(barcode));
    result.sort(OperationType.sortFolksonomy);
    return result;
  }
}

sealed class FolksonomyState {
  const FolksonomyState({required this.tags});

  final List<ProductTag>? tags;
}

class FolksonomyStateLoading extends FolksonomyState {
  const FolksonomyStateLoading() : super(tags: null);
}

class FolksonomyStateLoaded extends FolksonomyState {
  FolksonomyStateLoaded({required List<ProductTag> tags}) : super(tags: tags);

  @override
  List<ProductTag>? get tags => super.tags!;
}

class FolksonomyStateAddedItem extends FolksonomyState {
  FolksonomyStateAddedItem({
    required List<ProductTag> tags,
    required this.addedPosition,
    required this.item,
  }) : super(tags: tags);

  final int addedPosition;
  final ProductTag item;

  @override
  List<ProductTag>? get tags => super.tags!;
}

class FolksonomyStateRemovedItem extends FolksonomyState {
  FolksonomyStateRemovedItem({
    required List<ProductTag> tags,
    required this.removedPosition,
    required this.item,
  }) : super(tags: tags);

  final int removedPosition;
  final ProductTag item;

  @override
  List<ProductTag>? get tags => super.tags!;
}

class FolksonomyStateEditedItem extends FolksonomyState {
  FolksonomyStateEditedItem({
    required List<ProductTag> tags,
    required this.position,
    required this.item,
  }) : super(tags: tags);

  final int position;
  final ProductTag item;

  @override
  List<ProductTag>? get tags => super.tags!;
}

class FolksonomyStateKeysLoaded extends FolksonomyState {
  FolksonomyStateKeysLoaded({
    required this.keys,
    required List<ProductTag> tags,
  }) : super(tags: tags);

  final Map<String, KeyStats> keys;
}

class FolksonomyStateError extends FolksonomyState {
  FolksonomyStateError({required this.error, this.action, super.tags});

  final dynamic error;
  final FolksonomyAction? action;
}

enum FolksonomyAction { add, edit, remove }
