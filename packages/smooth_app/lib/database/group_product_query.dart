// Dart imports:
import 'dart:async';

// Package imports:
import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:openfoodfacts/model/parameter/PnnsGroup2Filter.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';

// Project imports:
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/product_query.dart';

class GroupProductQuery implements ProductQuery {
  GroupProductQuery(this.group, this.languageCode);

  final PnnsGroup2 group;
  final String languageCode;
  final int page = 1;

  @override
  Future<SearchResult> getSearchResult() async =>
      await OpenFoodAPIClient.searchProducts(
        ProductQuery.SMOOTH_USER,
        ProductSearchQueryConfiguration(
          fields: ProductQuery.fields,
          language: LanguageHelper.fromJson(languageCode),
          parametersList: <Parameter>[
            PnnsGroup2Filter(pnnsGroup2: group),
            Page(page: page),
          ],
        ),
      );

  @override
  ProductList getProductList() => ProductList(
        listType: ProductList.LIST_TYPE_HTTP_SEARCH_GROUP,
        parameters: group.id,
      );
}
