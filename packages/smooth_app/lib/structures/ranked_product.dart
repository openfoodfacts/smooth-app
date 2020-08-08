
import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';

class RankedProduct {

  RankedProduct({@required this.product, @required this.type, @required this.score, this.isHeader = false});

  Product product;
  RankingType type;
  int score;
  bool isHeader;

}