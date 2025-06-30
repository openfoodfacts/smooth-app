import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

class FolksonomyProvider extends ValueNotifier<FolksonomyState> {
  FolksonomyProvider(this.barcode) : super(const FolksonomyStateLoading()) {
    fetchProductTags();
  }

  final String barcode;
  String? _bearerToken;
  final List<ProductTag> _tags = <ProductTag>[];

  bool get isAuthorized => OpenFoodAPIConfiguration.globalUser != null;

  Future<String> getBearerToken() async {
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

  Future<void> fetchProductTags() async {
    try {
      value = const FolksonomyStateLoading();

      final Map<String, ProductTag> tags =
          await FolksonomyAPIClient.getProductTags(
            barcode: barcode,
            uriHelper: ProductQuery.uriFolksonomyHelper,
          );

      _tags.clear();
      _tags.addAll(tags.values);

      value = FolksonomyStateLoaded(tags: _tags);
    } catch (e) {
      value = FolksonomyStateError(error: e);
    }
  }

  Future<void> addTag(String key, String value) async {
    try {
      final String bearerToken = await getBearerToken();

      final ProductTag? tag = _getTag(key);
      if (tag != null) {
        throw Exception('This tag already exists!');
      }

      // to-do: The addProduct tag method does not yet have a way to add a comment.
      await FolksonomyAPIClient.addProductTag(
        barcode: barcode,
        key: key,
        value: value,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

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

      _tags.add(newProductTag);
      _sortTags();

      this.value = FolksonomyStateAddedItem(
        tags: _tags,
        addedPosition: _getPosition(key),
        item: newProductTag,
      );
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
      final String bearerToken = await getBearerToken();

      final ProductTag? tag = _getTag(key);
      if (tag == null) {
        throw Exception('Tag not found');
      }

      await FolksonomyAPIClient.updateProductTag(
        barcode: barcode,
        key: key,
        value: newValue,
        version: tag.version + 1,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

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

      final int position = _getPosition(key);
      _tags[position] = editedProductTag;
      value = FolksonomyStateEditedItem(
        tags: _tags,
        item: editedProductTag,
        position: position,
      );
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
      final String bearerToken = await getBearerToken();

      final ProductTag? tag = _getTag(key);
      if (tag == null) {
        throw Exception('Tag not found');
      }

      await FolksonomyAPIClient.deleteProductTag(
        barcode: barcode,
        key: key,
        version: tag.version,
        bearerToken: bearerToken,
        uriHelper: ProductQuery.uriFolksonomyHelper,
      );

      final int position = _getPosition(key);
      _tags.removeAt(position);

      value = FolksonomyStateRemovedItem(
        tags: _tags,
        removedPosition: position,
        item: tag,
      );
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

  int _getPosition(String key) =>
      _tags.indexWhere((ProductTag tag) => tag.key == key);

  ProductTag? _getTag(String key) =>
      _tags.firstWhereOrNull((ProductTag tag) => tag.key == key);

  void _sortTags() {
    _tags.sort((ProductTag a, ProductTag b) => a.key.compareTo(b.key));
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

class FolksonomyStateError extends FolksonomyState {
  FolksonomyStateError({required this.error, this.action, super.tags});

  final dynamic error;
  final FolksonomyAction? action;
}

enum FolksonomyAction { add, edit, remove }
