import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductImagePage extends StatefulWidget {
  const ProductImagePage({
    this.product,
    this.imageField,
    this.imageUrl,
    this.title,
    this.buttonText,
  });

  final Product product;
  final ImageField imageField;
  final String imageUrl;
  final String title;
  final String buttonText;

  @override
  _ProductImagePageState createState() => _ProductImagePageState();
}

class _ProductImagePageState extends State<ProductImagePage> {
  @override
  Widget build(BuildContext context) {
    final String _imageFullUrl = widget.imageUrl.replaceAll('.400.', '.full.');

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: PhotoView(
          imageProvider: NetworkImage(_imageFullUrl),
          minScale: PhotoViewComputedScale
              .contained, // Makes it easy to dezoom until the photo is contained in the screen
        ));
  }
}
