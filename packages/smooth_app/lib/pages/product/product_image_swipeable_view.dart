import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/product/product_image_viewer.dart';

///Widget to display swipeable product images,
///Opens product image with [initialProductImageDataIndex] from list of images Typecasted from [selectedImages]
class ProductImageSwipeableView extends StatefulWidget {
  const ProductImageSwipeableView({
    super.key,
    required this.selectedImages,
    required this.initialProductImageDataIndex,
    required this.barcode,
  });

  final Map<ProductImageData, ImageProvider?> selectedImages;
  final int initialProductImageDataIndex;
  final String barcode;

  @override
  State<ProductImageSwipeableView> createState() =>
      _ProductImageSwipeableViewState();
}

class _ProductImageSwipeableViewState extends State<ProductImageSwipeableView> {
  final ValueNotifier<int> _currentImageDataIndex = ValueNotifier<int>(0);
  late List<ProductImageData> _imageDataList;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _currentImageDataIndex.value = widget.initialProductImageDataIndex;
    _imageDataList = List<ProductImageData>.from(widget.selectedImages.keys);
    _controller = PageController(
      initialPage: widget.initialProductImageDataIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: WHITE_COLOR,
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: _currentImageDataIndex,
          builder: (_, int index, __) {
            return Text(
              _imageDataList[index].title,
            );
          },
        ),
        leading: SmoothBackButton(
          iconColor: Colors.white,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: PageView.builder(
        onPageChanged: (int index) {
          _currentImageDataIndex.value = index;
        },
        controller: _controller,
        itemCount: widget.selectedImages.keys.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductImageViewer(
            barcode: widget.barcode,
            imageData: _imageDataList[index],
          );
        },
      ),
    );
  }
}
