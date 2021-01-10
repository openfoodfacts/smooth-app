import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/model/Attribute.dart';

class AttributeCard extends StatelessWidget {
  const AttributeCard(
    this.attribute, {
    this.width,
    this.height,
  });

  final Attribute attribute;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String iconUrl = attribute?.iconUrl;
    if (iconUrl == null) {
      return Icon(
        CupertinoIcons.question,
        size: width ?? height,
        color: Colors.red,
      );
    }
    return Container(
      width: width,
      height: height,
      child: SvgPicture.network(
        iconUrl,
        fit: BoxFit.contain,
        width: width,
        height: height,
        placeholderBuilder: (BuildContext context) =>
            const CircularProgressIndicator(),
      ),
    );
  }
}
