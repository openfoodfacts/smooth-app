import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/QueryType.dart';
import 'package:smooth_app/database/product_query.dart';

class RobotoffQuestionsQuery {
  RobotoffQuestionsQuery(this._barcode);
  final String _barcode;
  final QueryType _queryType = OpenFoodAPIConfiguration.globalQueryType;

  Future<List<RobotoffQuestion>> getRobotoffQuestionsForProduct() async {
    final RobotoffQuestionResult result =
        await OpenFoodAPIClient.getRobotoffQuestionsForProduct(
      _barcode,
      ProductQuery.getLanguage().code,
      count: 3,
      queryType: _queryType,
    );
    return result.questions ?? <RobotoffQuestion>[];
  }
}
