

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/product/attribute_first_row_helper.dart';

class RawDataUnitHelper {
  List<StringPair> addNutritionUnit(List<StringPair> initialList){
    return initialList.map(
        (StringPair element) => StringPair(first: element.first,
        second: '${element.second} ${getUnit(element.first)}'
        )
      )
      .toList();
  }

  String getUnit(String element){
    return UnitHelper.unitToString(Nutrient.fromOffTag(removeUnecessaryWords(element))?.typicalUnit) ?? '';
  }

  String removeUnecessaryWords(String element){
    return element.replaceAll('_serving','');
  }

}