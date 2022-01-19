import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/query_category_tree_supplier.dart';
import 'package:smooth_app/data_models/smooth_category.dart';
import 'package:smooth_app/database/category_query.dart';
import 'package:smooth_app/database/local_database.dart';

/// Asynchronously loads a [CategoryTreeNode] with categories
abstract class CategoryTreeSupplier {
  CategoryTreeSupplier(
    this.categoryQuery,
    this.localDatabase, {
    this.timestamp,
  });

  final CategoryQuery categoryQuery;
  final LocalDatabase localDatabase;
  final int? timestamp;

  @protected
  late CategoryTreeNode root;

  /// Returns null if OK, or the message error
  Future<String?> asyncLoad();

  CategoryTreeNode getCategoryTree() => root;

  /// Returns a helper supplier in order to refresh the data
  CategoryTreeSupplier? getRefreshSupplier() => null;

  /// Returns the fastest data supplier: database if possible, or server query
  static Future<CategoryTreeSupplier> getBestSupplier(
    final CategoryQuery categoryQuery,
    final LocalDatabase localDatabase,
  ) async {
    return QueryCategoryTreeSupplier(categoryQuery, localDatabase);
  }
}
