import 'package:flutter/cupertino.dart';
import 'package:smooth_app/data_models/match.dart';
import 'package:openfoodfacts/model/Product.dart';

class RankedProduct {
  RankedProduct({@required this.product, @required this.match});

  final Product product;
  final Match match;
}
