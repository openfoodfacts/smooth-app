import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/model/Product.dart';

class RankedProduct {
  RankedProduct({@required this.product, @required this.score});

  final Product product;
  final double score;
}
