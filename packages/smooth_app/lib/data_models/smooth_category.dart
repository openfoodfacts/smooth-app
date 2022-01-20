import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/category_query.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';

class Category
    with Diagnosticable
    implements Comparable<Category>, LabeledObject {
  Category(this.tag, this.data);

  final String tag;
  TaxonomyCategory data;

  Iterable<String> get children => data.children ?? <String>[];
  Iterable<String> get parents => data.parents ?? <String>[];

  @override
  int compareTo(Category other) {
    return tag.compareTo(other.tag);
  }

  @override
  String getLabel(OpenFoodFactsLanguage language) => data.name?[language] ?? '';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('tag', tag));
    properties.add(StringProperty(
        'name', data.name?[OpenFoodFactsLanguage.ENGLISH] ?? ''));
    properties.add(DiagnosticsProperty<int>('numChildren', children.length));
    properties.add(DiagnosticsProperty<int>('numParents', parents.length));
  }
}

class CategoryTreeNode extends SmoothCategory<Category>
    implements LabeledObject {
  CategoryTreeNode(Category value) : super(value);

  @override
  String getLabel(OpenFoodFactsLanguage language) => value.getLabel(language);

  /// Whether or not this node has children.
  @override
  Future<bool> get hasChildren async {
    return value.children.isNotEmpty;
  }

  // These overrides are just to provide more type convenience when working with the
  // categories, so we don't have to use SmoothCategory<Category>" instead of
  // "CategoryTreeNode".
  @override
  Stream<CategoryTreeNode> getDescendants() {
    return super.getDescendants() as Stream<CategoryTreeNode>;
  }

  @override
  Future<CategoryTreeNode?> getChild(Category childValue) async {
    return super.getChild(childValue) as Future<CategoryTreeNode?>;
  }

  @override
  void addChild(covariant SmoothCategory<Category> newChild) {
    throw UnimplementedError();
  }

  List<CategoryTreeNode>? _children;
  List<CategoryTreeNode>? _parents;

  @override
  Stream<CategoryTreeNode> getChildren() async* {
    if (_children == null) {
      final CategoryQuery categoryQuery = CategoryQuery();
      final Iterable<CategoryTreeNode>? childCategories =
          await categoryQuery.getCategories(value.children);
      if (childCategories == null) {
        return;
      }
      _children = childCategories.toList();
    }
    for (final CategoryTreeNode child in _children!) {
      yield child;
    }
  }

  @override
  Stream<SmoothCategory<Category>> getParents() async* {
    if (_parents == null) {
      final CategoryQuery categoryQuery = CategoryQuery();
      final Iterable<CategoryTreeNode>? parentCategories =
          await categoryQuery.getCategories(value.parents);
      if (parentCategories == null) {
        return;
      }
      _parents = parentCategories.toList();
    }
    for (final CategoryTreeNode parent in _parents!) {
      yield parent;
    }
  }
}
