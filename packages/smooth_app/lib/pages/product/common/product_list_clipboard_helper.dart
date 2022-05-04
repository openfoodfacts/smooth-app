import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';

/// Helper class around [ProductList] and clipboard operations (copy/paste).
class ProductListClipboardHelper {
  ProductListClipboardHelper(this.productList);

  final ProductList productList;

  Future<bool> copy(final Iterable<String> selectedBarcodes) async {
    try {
      final String copied = _getCopyString(selectedBarcodes);
      await FlutterClipboard.copy(copied);
      return true;
    } catch (e) {
      debugPrint('error copying: $e');
      return false;
    }
  }

  /// Returns the number of barcodes actually added, or null if exception.
  Future<int?> paste(final LocalDatabase localDatabase) async {
    try {
      final String pasted = await FlutterClipboard.paste();
      final List<String>? barcodes = _getPastedBarcodes(pasted);
      if (barcodes == null) {
        return null;
      }
      final DaoProductList daoProductList = DaoProductList(localDatabase);
      final int result =
          await daoProductList.setAll(productList, barcodes, true);
      if (result > 0) {
        await daoProductList.get(productList);
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  String _getCopyString(final Iterable<String> barcodes) {
    final List<String> list = <String>[];
    list.addAll(barcodes);
    return jsonEncode(list);
  }

  List<String>? _getPastedBarcodes(final String paste) {
    try {
      final List<dynamic> pasted = jsonDecode(paste) as List<dynamic>;
      final List<String> list = <String>[];
      for (final dynamic item in pasted) {
        list.add(item.toString());
      }
      return list;
    } catch (e) {
      debugPrint('error pasting: $e');
      return null;
    }
  }
}
