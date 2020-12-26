import 'package:flutter/material.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:smooth_app/data_models/product_keywords_search_result_model.dart';

class ProductGroupQueryModel extends ProductKeywordsSearchResultModel {
  ProductGroupQueryModel(final PnnsGroup2 group, final BuildContext context)
      : super(group.id, context);
}
