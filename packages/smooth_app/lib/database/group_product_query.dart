import 'dart:async';

import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/PnnsGroupQueryConfiguration.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/data_models/product_list.dart';

class GroupProductQuery implements ProductQuery {
  GroupProductQuery(this.group, this.languageCode);

  final PnnsGroup2 group;
  final String languageCode;
  final int page = 1;

  @override
  Future<SearchResult> getSearchResult() async =>
      await OpenFoodAPIClient.queryPnnsGroup(
        ProductQuery.SMOOTH_USER,
        PnnsGroupQueryConfiguration(
          group,
          fields: ProductQuery.fields,
          page: page,
          language: LanguageHelper.fromJson(languageCode),
        ),
      );

  @override
  ProductList getProductList() => ProductList(
        listType: ProductList.LIST_TYPE_HTTP_SEARCH_GROUP,
        parameters: group.id,
      );
}
