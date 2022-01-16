import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/model/parameter/SearchTerms.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/product_query.dart';

class RobotoffQuestionsQuery {
  RobotoffQuestionsQuery({
    required this.barcode,
  });
  final String barcode;

  // TODO(jasmeet): Parse the answers here and return questions directly.
  Future<RobotoffQuestionResult> getRobotoffQuestionsForProduct(
    String languageCode,
  ) async =>
      OpenFoodAPIClient.getRobotoffQuestionsForProduct(
        barcode,
        languageCode,
        count: 3,
        queryType: QueryType.PROD,
      );
}
