import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_folksonomy.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_manager.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_operation.dart';

class FolksonomyProvider extends ValueNotifier<FolksonomyState> {
  FolksonomyProvider(this.barcode, LocalDatabase localDatabase)
    : _daoFolksonomy = DaoFolksonomy(localDatabase),
      _folksonomyManager = FolksonomyManager(localDatabase),
      super(const FolksonomyStateLoading()) {
    unawaited(_init());
  }

  final String barcode;
  final DaoFolksonomy _daoFolksonomy;
  final FolksonomyManager _folksonomyManager;
  final List<ProductTag> _tags = <ProductTag>[];

  // Display tags from local database first (to see it offline), then update from API.
  Future<void> fetchProductTags() async {
    if (_tags.isEmpty) {
      value = const FolksonomyStateLoading();
    }

    unawaited(_refreshDisplayableTags());

    try {
      await _folksonomyManager.serverRefresh(barcode);
    } catch (e) {
      if (_tags.isEmpty) {
        value = FolksonomyStateError(error: e);
      }
    }
  }

  Future<void> addTag(String key, String value) async {
    try {
      await _folksonomyManager.addTag(barcode, key, value);
      unawaited(_refreshDisplayableTags());
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
      await _folksonomyManager.editTag(
        barcode,
        key,
        newValue,
        _getCurrentTagVersion(key) + 1,
      );
      unawaited(_refreshDisplayableTags());
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
      await _folksonomyManager.deleteTag(
        barcode,
        key,
        _getCurrentTagVersion(key),
      );
      unawaited(_refreshDisplayableTags());
    } catch (e) {
      value = FolksonomyStateError(
        error: e,
        action: FolksonomyAction.remove,
        tags: _tags,
      );
    }
  }

  void _updateDisplayableTags(final List<ProductTag> tags) {
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

  Future<void> _init() async {
    await fetchProductTags();
    unawaited(
      _folksonomyManager.serverPerformActions(barcode),
    ); // TODO(darshanhtailor): Do we refresh for all barcodes here?
  }

  Future<void> _refreshDisplayableTags() async {
    final List<ProductTag> localTags =
        await _daoFolksonomy.get(barcode) ?? <ProductTag>[];
    final List<FolksonomyOperation> pendingOperations =
        _folksonomyManager.getPendingOperations(barcode) ??
        <FolksonomyOperation>[];

    for (final FolksonomyOperation operation in pendingOperations) {
      final FolksonomyAction type = operation.type;
      final ProductTag tag = operation.tag;
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

    _updateDisplayableTags(localTags);
  }

  int _getCurrentTagVersion(String key) =>
      _tags.firstWhere((ProductTag tag) => tag.key == key).version;
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
