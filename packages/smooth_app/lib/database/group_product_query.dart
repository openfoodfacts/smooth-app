import 'dart:async';

import 'package:openfoodfacts/model/SearchResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/PnnsGroupQueryConfiguration.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';

class GroupProductQuery extends ProductQuery {
  GroupProductQuery(this.group) : super();

  final PnnsGroup2 group;
  final int page = 1;

  @override
  Future<SearchResult> runInnerQuery() async =>
      await OpenFoodAPIClient.queryPnnsGroup(
          ProductQuery.SMOOTH_USER,
          PnnsGroupQueryConfiguration(
            group,
            fields: ProductQuery.fields,
            page: page,
            language: OpenFoodFactsLanguage.ENGLISH,
          ));
}
