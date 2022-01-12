import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';

class RobotoffQuestionsQuery {
  RobotoffQuestionsQuery(this.barcode);
  final String barcode;

  Future<List<RobotoffQuestion>> getRobotoffQuestionsForProduct() async {
    final RobotoffQuestionResult result =
        await OpenFoodAPIClient.getRobotoffQuestionsForProduct(
      barcode,
      ProductQuery.getLanguage().code,
      count: 3,
    );
    return result.questions ?? <RobotoffQuestion>[];
  }
}
