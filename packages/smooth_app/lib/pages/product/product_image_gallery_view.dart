// ignore_for_file: cast_nullable_to_non_nullable

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
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';
import 'package:smooth_app/themes/constant_icons.dart';

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
  final List<ImageProvider?> allProductImageProviders = <ImageProvider?>[];
  late String title;
  bool _hasPhoto = true;
  bool _isRefreshed = false;
  late ProductImageData _productImageDataCurrent;

  @override
  void initState() {
    title = widget.title;

    for (final ProductImageData element in widget.allProductImagesData) {
      images.add(element);
      if (element.imageUrl != null) {
        allProductImageProviders.add(NetworkImage(element.imageUrl!));
      } else {
        allProductImageProviders.add(null);
      }
    }

    _controller = PageController(
      initialPage: widget.allProductImagesData.indexOf(
        images.firstWhere((ProductImageData element) =>
            element.imageUrl == widget.productImageData.imageUrl),
      ),
    );
    _productImageDataCurrent = widget.productImageData;
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
          leading: IconButton(
            icon: Icon(ConstantIcons.instance.getBackIcon()),
            onPressed: () {
              Navigator.maybePop(context, _isRefreshed);
            },
          )),
      backgroundColor: Colors.black,
      floatingActionButton: _hasPhoto
          ? _buildCropFloatingActionButton()
          : _buildAddFloatingActionButton(),
      body: PhotoViewGallery.builder(
        pageController: _controller,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          if (allProductImageProviders[index] == null) {
            if (images[index].imageUrl != null) {
              allProductImageProviders[index] =
                  NetworkImage(images[index].imageUrl!);
            } else {
              return PhotoViewGalleryPageOptions.customChild(
                  child: Container());
            }
          }
          return PhotoViewGalleryPageOptions(
            imageProvider: allProductImageProviders[index],
            initialScale: PhotoViewComputedScale.contained * 0.8,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.1,
            heroAttributes:
                PhotoViewHeroAttributes(tag: images[index].imageUrl ?? ''),
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
            _hasPhoto = images[index].imageUrl != null;
            _productImageDataCurrent = images[index];
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

  FloatingActionButton _buildAddFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () async {
        final int? currentIndex = _controller.page?.toInt();
        if (currentIndex != null) {
          final File? croppedImageFile = await startImageCropping(context);
          if (croppedImageFile != null) {
            setState(() {
              allProductImageProviders[currentIndex] =
                  FileImage(croppedImageFile);
            });
            if (!mounted) {
              return;
            }
            final bool isUploaded = await uploadCapturedPicture(
              context,
              barcode: widget.barcode!,
              imageField: _productImageDataCurrent.imageField,
              imageUri: croppedImageFile.uri,
            );

            if (isUploaded) {
              _isRefreshed = true;
              if (!mounted) {
                return;
              }
              final AppLocalizations appLocalizations =
                  AppLocalizations.of(context);
              final String message = getImageUploadedMessage(
                  _productImageDataCurrent.imageField, appLocalizations);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      },
      child: const Icon(Icons.add_a_photo),
    );
  }

  FloatingActionButton _buildCropFloatingActionButton() {
    return FloatingActionButton(
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

        final File? newImage =
            await startImageCropping(context, existingImage: imageFile);
        if (newImage == null) {
          return;
        }

        // ignore: use_build_context_synchronously
        final File? photoUploaded = await Navigator.push<File?>(
          context,
          MaterialPageRoute<File?>(
            builder: (BuildContext context) => ConfirmAndUploadPicture(
              barcode: widget.barcode!,
              imageType: currentImage.imageField,
              initialPhoto: newImage,
            ),
          ),
        );
        if (photoUploaded != null) {
          _isRefreshed = true;
          setState(() {
            allProductImageProviders[currentIndex] = FileImage(photoUploaded);
          });
        }
      },
      child: const Icon(Icons.crop),
    );
  }
}
