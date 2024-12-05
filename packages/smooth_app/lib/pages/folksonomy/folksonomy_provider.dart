import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class FolksonomyProvider extends ChangeNotifier {
  FolksonomyProvider(this.barcode) {
    fetchProductTags();
  }

  final String barcode;
  Map<String, ProductTag>? _productTags;
  bool _isLoading = true;
  String? _error;

  Map<String, ProductTag>? get productTags => _productTags;
  bool get isLoading => _isLoading;
  bool get isAuthorized => OpenFoodAPIConfiguration.globalUser != null;
  bool get tagsExist =>
      _productTags != null && _productTags!.isNotEmpty && !_isLoading;
  String? get error => _error;

  Future<String> getBearerToken() async {
    final User? user = OpenFoodAPIConfiguration.globalUser;

    if (user == null) {
      throw Exception('No user found');
    }

    try {
      final MaybeError<String> token =
          await FolksonomyAPIClient.getAuthenticationToken(
        username: user.userId,
        password: user.password,
      );

      if (token.isError) {
        throw Exception('Could not get token: ${token.error}');
      }

      if (token.value.isEmpty) {
        throw Exception('Unexpected empty token');
      }

      return token.value;
    } catch (err) {
      throw Exception('Could not get token');
    }
  }

  Future<void> fetchProductTags() async {
    try {
      _productTags = await FolksonomyAPIClient.getProductTags(barcode: barcode);
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> addTag(String key, String value) async {
    try {
      final String bearerToken = await getBearerToken();
      // to-do: The addProduct tag method does not yet have a way to add a comment.
      await FolksonomyAPIClient.addProductTag(
          barcode: barcode, key: key, value: value, bearerToken: bearerToken);
      _productTags?[key] = ProductTag(
        barcode: barcode,
        key: key,
        value: value,
        owner: '',
        version: 1,
        editor: '',
        lastEdit: DateTime.now(),
        comment: '',
      );
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> editTag(String key, String newValue) async {
    try {
      final String bearerToken = await getBearerToken();

      final int newVersion = (_productTags?[key]?.version ?? 0) + 1;
      await FolksonomyAPIClient.updateProductTag(
          barcode: barcode,
          key: key,
          value: newValue,
          version: newVersion,
          bearerToken: bearerToken);
      _productTags?[key] = ProductTag(
        barcode: barcode,
        key: key,
        value: newValue,
        owner: '',
        version: newVersion,
        editor: '',
        lastEdit: DateTime.now(),
        comment: '',
      );
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> deleteTag(String key) async {
    try {
      final String bearerToken = await getBearerToken();
      final int tagVersion = _productTags?[key]?.version ?? 0;
      await FolksonomyAPIClient.deleteProductTag(
          barcode: barcode,
          key: key,
          version: tagVersion,
          bearerToken: bearerToken);
      _productTags?.remove(key);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
