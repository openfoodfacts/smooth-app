import 'package:smooth_app/data_models/category_tree_supplier.dart';
import 'package:smooth_app/database/category_query.dart';
import 'package:smooth_app/database/local_database.dart';

/// [CategoryTreeSupplier] with a server query flavor
class QueryCategoryTreeSupplier extends CategoryTreeSupplier {
  QueryCategoryTreeSupplier(
    final CategoryQuery categoryQuery,
    final LocalDatabase localDatabase,
  ) : super(categoryQuery, localDatabase);

  @override
  Future<String?> asyncLoad() async {
    try {
      root = (await categoryQuery.getCategoryTreeRoot())!;
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  CategoryTreeSupplier? getRefreshSupplier() => null;
}
