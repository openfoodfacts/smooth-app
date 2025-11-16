import 'dart:async';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_folksonomy.dart';
import 'package:smooth_app/database/dao_transient_folksonomy.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_operation.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/query/product_query.dart';

/// Writer class around Folksonomy, temporary until we implement BackgroundTasks
class FolksonomyManager {
  FolksonomyManager(this._localDatabase)
    : _daoFolksonomy = DaoFolksonomy(_localDatabase),
      _daoTransientFolksonomy = DaoTransientFolksonomy(_localDatabase);

  final LocalDatabase _localDatabase;
  final DaoFolksonomy _daoFolksonomy;
  final DaoTransientFolksonomy _daoTransientFolksonomy;

  String? _bearerToken;

  Future<void> addTag(String barcode, String key, String value) async {
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
      ...getPendingOperations(barcode) ?? <FolksonomyOperation>[],
      FolksonomyOperation(type: FolksonomyAction.add, tag: newProductTag),
    ]);
    unawaited(serverPerformActions(barcode));
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
      ...getPendingOperations(barcode) ?? <FolksonomyOperation>[],
      FolksonomyOperation(type: FolksonomyAction.edit, tag: editedProductTag),
    ]);
    unawaited(serverPerformActions(barcode));
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
      ...getPendingOperations(barcode) ?? <FolksonomyOperation>[],
      FolksonomyOperation(type: FolksonomyAction.remove, tag: tagToDelete),
    ]);
    unawaited(serverPerformActions(barcode));
  }

  Future<void> serverPerformAllActions() async {
    final List<String> barcodes = _daoTransientFolksonomy.getAllBarcodes();
    for (final String barcode in barcodes) {
      await serverPerformActions(barcode);
    }
  }

  Future<void> serverPerformActions(String barcode) async {
    while (true) {
      final FolksonomyOperation? operation = getPendingOperations(
        barcode,
      )?.firstOrNull;
      if (operation == null) {
        return;
      }

      try {
        if (operation.type == FolksonomyAction.add) {
          await _serverAdd(operation.tag);
        } else if (operation.type == FolksonomyAction.edit) {
          await _serverEdit(operation.tag);
        } else if (operation.type == FolksonomyAction.remove) {
          await _serverDelete(operation.tag);
        }

        await serverRefresh(barcode);

        final List<FolksonomyOperation> pendingOperations =
            getPendingOperations(barcode) ?? <FolksonomyOperation>[];
        if (pendingOperations.isNotEmpty) {
          pendingOperations.removeAt(0);
          if (pendingOperations.isEmpty) {
            await _daoTransientFolksonomy.delete(barcode);
          } else {
            await _daoTransientFolksonomy.put(barcode, pendingOperations);
          }
        }
      } catch (e) {
        return;
      }
    }
  }

  Future<void> _serverAdd(ProductTag tag) async {
    final String bearerToken = await _getBearerToken();

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

  Future<void> _serverEdit(ProductTag tag) async {
    final String bearerToken = await _getBearerToken();

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

  Future<void> _serverDelete(ProductTag tag) async {
    final String bearerToken = await _getBearerToken();

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

  Future<void> serverRefresh(String barcode) async {
    final Map<String, ProductTag> tags =
        await FolksonomyAPIClient.getProductTags(
          barcode: barcode,
          uriHelper: ProductQuery.uriFolksonomyHelper,
        );
    await _daoFolksonomy.put(barcode, tags.values.toList());

    _localDatabase.notifyListeners();
  }

  Future<String> _getBearerToken() async {
    if (_bearerToken != null) {
      return _bearerToken!;
    }

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

    _bearerToken = token.value;
    return token.value;
  }

  List<FolksonomyOperation>? getPendingOperations(final String barcode) =>
      _daoTransientFolksonomy.get(barcode);
}
