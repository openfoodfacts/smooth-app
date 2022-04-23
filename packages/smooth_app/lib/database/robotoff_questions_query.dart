import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';

class RobotoffQuestionsQuery {
  RobotoffQuestionsQuery(this._barcode);
  final String _barcode;

  Future<List<RobotoffQuestion>> getRobotoffQuestionsForProduct() async {
    final RobotoffQuestionResult result =
        await OpenFoodAPIClient.getRobotoffQuestionsForProduct(
      _barcode,
      ProductQuery.getLanguage().code,
      count: 3,
    );
    return result.questions ?? <RobotoffQuestion>[];
  }
}
