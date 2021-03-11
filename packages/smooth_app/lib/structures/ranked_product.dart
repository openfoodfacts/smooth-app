// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/data_models/match.dart';

class RankedProduct {
  RankedProduct({@required this.product, @required this.match});

  final Product product;
  final Match match;
}
