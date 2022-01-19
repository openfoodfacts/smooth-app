import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/category_tree_supplier.dart';
import 'package:smooth_app/data_models/product_query_model.dart'
    show LoadingStatus;
import 'package:smooth_app/data_models/smooth_category.dart';

class CategoryQueryModel with ChangeNotifier {
  CategoryQueryModel(this.supplier) {
   _asyncLoad();
  }

  final CategoryTreeSupplier supplier;

  LoadingStatus _loadingStatus = LoadingStatus.LOADING;
  String? _loadingError;
  Map<String, CategoryTreeNode>? _categories;
  late CategoryTreeNode _categoryRoot;
  bool isNotEmpty() => _categories != null && _categories!.isNotEmpty;

  /// The currently selected filter categories.
  final Set<Category> selectedCategories = <Category>{};

  /// The currently selected category path.
  final List<Category> categoryPath = <Category>[];

  Future<CategoryTreeNode?> getCategory(Iterable<Category> categoryPath) async {
    if (categoryPath.isEmpty) {
      return null;
    }
    debugPrint('Getting category for path $categoryPath');
    if (categoryPath.length == 1 &&
        categoryPath.first.compareTo(_categoryRoot.value) == 0) {
      return _categoryRoot;
    }
    final String tag = categoryPath.last.tag;
    debugPrint('Getting category $tag');
    if (_categories != null && _categories![tag] != null) {
      return _categories![tag];
    }
    final CategoryTreeNode? category =
        await supplier.categoryQuery.getCategory(tag);
    if (category != null && _categories != null) {
      _categories![tag] = category;
    }
    return category;
  }

  void setCategoryPath(Iterable<Category> value) {
    categoryPath.clear();
    categoryPath.addAll(value);
    debugPrint('New category path: $categoryPath');
    notifyListeners();
  }

  void setCategories(Set<Category> value) {
    if (selectedCategories != value) {
      selectedCategories.clear();
      selectedCategories.addAll(value);
      notifyListeners();
    }
  }

  String? get loadingError => _loadingError;
  LoadingStatus get loadingStatus => _loadingStatus;

  Future<void> _asyncLoad() async {
    _loadingError = await supplier.asyncLoad();
    if (_loadingError != null) {
      _loadingStatus = LoadingStatus.ERROR;
    } else {
      _categoryRoot = supplier.getCategoryTree();
      _categories = <String, CategoryTreeNode>{
        _categoryRoot.value.tag: _categoryRoot
      };
      categoryPath.clear();
      categoryPath.add(_categoryRoot.value);
      _loadingStatus = LoadingStatus.LOADED;
    }
    notifyListeners();
  }
}
