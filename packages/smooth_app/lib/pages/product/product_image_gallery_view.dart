import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_gauge.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';

class ProductImageGalleryView extends StatefulWidget {
  const ProductImageGalleryView({
    this.barcode,
    required this.title,
    required this.productImageData,
    required this.allProductImagesData,
  });

  final String? barcode;
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

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
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            final int? currentIndex = _controller.page?.toInt();
            if (currentIndex == null && currentIndex! >= images.length) {
              return;
            }

            final ProductImageData currentImage = images[currentIndex];
            if (currentImage.imageUrl == null) {
              return;
            }

            final File? imageFile = await LoadingDialog.run<File>(
                context: context,
                future: _getCurrentImageFile(currentImage.imageUrl!));

            if (imageFile == null) {
              return;
            }

            if (!mounted) {
              return;
            }
            // if there is no photo just open the crop page
            if (currentImage.imageUrl == null) {
              final File? newImage = await startImageCropping(context);
              if (newImage == null) {
                return;
              }
              // ignore: use_build_context_synchronously
              await Navigator.push<File?>(
                context,
                MaterialPageRoute<File?>(
                  builder: (BuildContext context) => ConfirmAndUploadPicture(
                    barcode: widget.barcode!,
                    imageType: currentImage.imageField,
                    initialPhoto: newImage,
                  ),
                ),
              );
              newImage.delete();
            } else {
              await Navigator.push<File?>(
                context,
                MaterialPageRoute<File?>(
                  builder: (BuildContext context) => ConfirmAndUploadPicture(
                    barcode: widget.barcode!,
                    imageType: currentImage.imageField,
                    initialPhoto: imageFile,
                  ),
                ),
              );
            }
          },
          label: Row(
            children: <Widget>[
              const Icon(Icons.edit),
              Text(appLocalizations.edit_photo_button_label)
            ],
          )),
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

  Future<File> _getCurrentImageFile(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final Directory tempDirectory = await getTemporaryDirectory();
    final File imageFile = await File('${tempDirectory.path}/editing_image')
        .writeAsBytes(response.bodyBytes);
    return imageFile;
  }
}
