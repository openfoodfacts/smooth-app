/// Contains constant widgets/colors etc that are shared across the entire app.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Widget EMPTY_WIDGET = SizedBox.shrink();
const Widget DIVIDER = Divider(
  color: Colors.black12,
);

double getIconSizeFromContext(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  return screenSize.width / 10;
}
