import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductImagePage extends StatelessWidget {
  const ProductImagePage({
    this.product,
    this.imageField,
    this.imageProvider,
    this.title,
    this.buttonText,
  });

  final Product product;
  final ImageField imageField;
  final ImageProvider imageProvider;
  final String title;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale
              .contained, // Makes it easy to dezoom until the photo is contained in the screen
        ));
  }
}
