import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_folksonomy.dart';
import 'package:smooth_app/database/dao_transient_folksonomy_operation.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_manager.dart';
import 'package:smooth_app/query/product_query.dart';

class FolksonomyProvider extends ValueNotifier<FolksonomyState> {
  FolksonomyProvider(this.barcode, this.context)
    : super(const FolksonomyStateLoading()) {
    unawaited(_init(context));
  }

  final String barcode;
  final BuildContext context;
  late final LocalDatabase _localDatabase;
  late final DaoFolksonomy _daoFolksonomy;
  late final FolksonomyManager _folksonomyManager;
  final List<ProductTag> _tags = <ProductTag>[];

  Future<void> _init(BuildContext context) async {
    _localDatabase = context.read<LocalDatabase>();
    _daoFolksonomy = DaoFolksonomy(_localDatabase);
    _folksonomyManager = FolksonomyManager(_localDatabase);

    _localDatabase.addListener(_refreshFromDb);

    await fetchProductTags();
    unawaited(_folksonomyManager.syncProductTags(barcode));
  }

  @override
  void dispose() {
    _localDatabase.removeListener(_refreshFromDb);
    super.dispose();
  }

  Future<void> _refreshFromDb() async {
    final List<ProductTag> localTags =
        await _daoFolksonomy.get(barcode) ?? <ProductTag>[];
    final Iterable<TransientFolksonomyOperation> pendingOperations =
        _folksonomyManager.getSortedOperations(barcode);
    for (final TransientFolksonomyOperation operation in pendingOperations) {
      final FolksonomyAction type = operation.value.type;
      final ProductTag tag = operation.value.tag;
      final int index = localTags.indexWhere(
        (ProductTag t) => t.key == tag.key,
      );

      switch (type) {
        case FolksonomyAction.add:
          if (index == -1) {
            localTags.add(tag);
          }
          break;
        case FolksonomyAction.edit:
          if (index != -1) {
            localTags[index] = tag;
          }
          break;
        case FolksonomyAction.remove:
          if (index != -1) {
            localTags.removeAt(index);
          }
          break;
        case FolksonomyAction.visitUrl:
          break;
      }
    }

    _updateTags(localTags);
  }

  // Display tags from local database first (to see it offline), then update from API.
  Future<void> fetchProductTags() async {
    if (_tags.isEmpty) {
      value = const FolksonomyStateLoading();
    }

    _refreshFromDb();

    try {
      final Map<String, ProductTag> tags =
          await FolksonomyAPIClient.getProductTags(
            barcode: barcode,
            uriHelper: ProductQuery.uriFolksonomyHelper,
          );
      final List<ProductTag> remoteTags = tags.values.toList();

      await _daoFolksonomy.put(barcode, remoteTags);
      _localDatabase.notifyListeners();
    } catch (e) {
      if (_tags.isEmpty) {
        value = FolksonomyStateError(error: e);
      }
    }
  }

  Future<void> addTag(String key, String value) async {
    try {
      await _folksonomyManager.addTag(barcode, key, value);
    } catch (e) {
      this.value = FolksonomyStateError(
        error: e,
        action: FolksonomyAction.add,
        tags: _tags,
      );
    }
  }

  Future<void> editTag(String key, String newValue) async {
    try {
      await _folksonomyManager.editTag(barcode, key, newValue);
    } catch (e) {
      value = FolksonomyStateError(
        error: e,
        action: FolksonomyAction.edit,
        tags: _tags,
      );
    }
  }

  Future<void> deleteTag(String key) async {
    try {
      await _folksonomyManager.deleteTag(barcode, key);
    } catch (e) {
      value = FolksonomyStateError(
        error: e,
        action: FolksonomyAction.remove,
        tags: _tags,
      );
    }
  }

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

class FolksonomyStateError extends FolksonomyState {
  FolksonomyStateError({required this.error, this.action, super.tags});

  final dynamic error;
  final FolksonomyAction? action;
}

enum FolksonomyAction { add, edit, remove, visitUrl }
