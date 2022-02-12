import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_gauge.dart';

class ProductImageGalleryView extends StatefulWidget {
  const ProductImageGalleryView({
    required this.title,
    required this.productImageData,
    required this.allProductImagesData,
  });

  final String title;
  final ProductImageData productImageData;
  final List<ProductImageData> allProductImagesData;

  @override
  State<ProductImageGalleryView> createState() =>
      _ProductImageGalleryViewState();
}

class _ProductImageGalleryViewState extends State<ProductImageGalleryView> {
  late final PageController _controller;
  late final List<ProductImageData> images = <ProductImageData>[];
  late String title;

  @override
  void initState() {
    title = widget.title;

    for (final ProductImageData element in widget.allProductImagesData) {
      if (element.imageUrl != null) {
        images.add(element);
      }
    }

    _controller = PageController(
      initialPage: widget.allProductImagesData.indexOf(
        images.firstWhere((ProductImageData element) =>
            element.imageUrl == widget.productImageData.imageUrl),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    //When all are empty there shouldn't be a way to access this page
    if (images.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(appLocalizations.error),
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      ),
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        pageController: _controller,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index].imageUrl!),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.1,
            heroAttributes:
                PhotoViewHeroAttributes(tag: images[index].imageUrl!),
          );
        },
        itemCount: images.length,
        loadingBuilder:
            (final BuildContext context, final ImageChunkEvent? event) {
          return Center(
            child: SmoothGauge(
              color: Theme.of(context).colorScheme.onBackground,
              value: event == null ||
                      event.expectedTotalBytes == null ||
                      event.expectedTotalBytes == 0
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          );
        },
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        onPageChanged: (int index) {
          setState(() {
            title = images[index].title;
          });
        },
      ),
    );
  }
}
