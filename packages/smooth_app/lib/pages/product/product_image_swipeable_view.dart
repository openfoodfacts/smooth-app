import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/product/product_image_viewer.dart';

///Widget to display swipeable product images,
///Opens product image with [initialProductImageDataIndex] from list of images Typecasted from [selectedImages]
///
///Field [selectedImages],[initialProductImageDataIndex],[barcode] cannot be null
class ProductImageSwipeableView extends StatelessWidget {
  ProductImageSwipeableView({
    Key? key,
    required this.selectedImages,
    required this.initialProductImageDataIndex,
    required this.barcode,
  }) : super(key: key);

  final Map<ProductImageData, ImageProvider?> selectedImages;
  final int initialProductImageDataIndex;
  final String barcode;
  final ValueNotifier<int> currentImageDataIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentImageDataIndex.value = initialProductImageDataIndex;
    });
    final List<MapEntry<ProductImageData, ImageProvider?>> imageList =
        selectedImages.entries.toList();
    final PageController controller = PageController(
      initialPage: initialProductImageDataIndex,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: WHITE_COLOR,
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: currentImageDataIndex,
          builder: (_, int index, __) {
            return Text(
              imageList[index].key.title,
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
          currentImageDataIndex.value = index;
        },
        controller: controller,
        itemCount: selectedImages.keys.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductImageViewer(
            barcode: barcode,
            imageData: imageList[index].key,
          );
        },
      ),
    );
  }
}
