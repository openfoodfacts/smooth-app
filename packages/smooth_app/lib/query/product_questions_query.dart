import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

class ProductQuestionsQuery {
  ProductQuestionsQuery(this._barcode);
  final String _barcode;

  Future<List<RobotoffQuestion>> getQuestions() async {
    final RobotoffQuestionResult result =
        await OpenFoodAPIClient.getRobotoffQuestionsForProduct(
      _barcode,
      ProductQuery.getLanguage().code,
      count: 3,
    );
    return result.questions ?? <RobotoffQuestion>[];
  }
}
