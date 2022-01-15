import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';

class Category implements Comparable<Category> {
  Category(this.tag, this.data);

  final String tag;
  String getName(OpenFoodFactsLanguage language) => data.name![language] ?? '';
  TaxonomyCategory data;

  @override
  int compareTo(Category other) {
    return tag.compareTo(other.tag);
  }
}

class CategoryTreeNode extends SmoothCategory<Category> {
  CategoryTreeNode(Category value) : super(value);

  @override
  String getLabel(OpenFoodFactsLanguage language) => value.getName(language);

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

  @override
  Stream<SmoothCategory<Category>> getChildren() async* {

  }

  @override
  Stream<SmoothCategory<Category>> getParents() async* {
  }
}
