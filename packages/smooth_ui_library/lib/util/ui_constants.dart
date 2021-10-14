/// Contains constant widgets/colors etc that are shared across the entire app.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Widget EMPTY_WIDGET = SizedBox.shrink();

const double VERY_SMALL_SPACE = 4.0;
const double SMALL_SPACE = 8.0;
const double MEDIUM_SPACE = 12.0;
const double LARGE_SPACE = 16.0;

double getIconSizeFromContext(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  return screenSize.width / 10;
}
