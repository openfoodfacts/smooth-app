// ignore_for_file: cast_nullable_to_non_nullable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/ProductImage.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/product_image_viewer.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ProductImageGalleryView extends StatefulWidget {
  const ProductImageGalleryView({
    this.barcode,
    required this.productImageData,
    required this.allProductImagesData,
  });

  final String? barcode;
  final ProductImageData productImageData;
  final List<ProductImageData> allProductImagesData;

  @override
  State<ProductImageGalleryView> createState() =>
      _ProductImageGalleryViewState();
}

class _ProductImageGalleryViewState extends State<ProductImageGalleryView> {
  final List<ProductImageData> imagesData = <ProductImageData>[];
  final List<ImageProvider?> imageProviders = <ImageProvider?>[];
  bool _isRefreshed = false;

  @override
  void initState() {
    imagesData.addAll(widget.allProductImagesData);
    imageProviders.addAll(
      imagesData.map((ProductImageData imageData) => imageData.imageUrl != null
          ? NetworkImage(imageData.imageUrl!)
          : null),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    //When all are empty there shouldn't be a way to access this page
    if (imagesData.isEmpty) {
      return SmoothScaffold(
        body: Center(
          child: Text(appLocalizations.error),
        ),
      );
    }

    return SmoothScaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            title: Text(appLocalizations.edit_product_form_item_photos_title),
            leading: IconButton(
              icon: Icon(ConstantIcons.instance.getBackIcon()),
              onPressed: () => Navigator.maybePop(context, _isRefreshed),
            )),
        body: ListView.builder(
          itemCount: imagesData.length,
          itemBuilder: _buildCard,
        ));
  }

  Widget _buildCard(BuildContext context, int index) {
    final ThemeData themeData = Theme.of(context);
    return SmoothCard(
        child: ListTile(
      onTap: () => imagesData[index].imageUrl != null
          ? _openImage(imagesData[index])
          : _newImage(
              field: imagesData[index].imageField,
              index: index,
            ),
      leading: imageProviders[index] != null
          ? Image(
              image: imageProviders[index]!,
              fit: BoxFit.cover,
              width: 100,
            )
          : SvgPicture.asset(
              'assets/product/product_not_found.svg',
              fit: BoxFit.cover,
              width: 100,
            ),
      title: Text(
        imagesData[index].title,
        style: themeData.textTheme.headline4,
      ),
      trailing: Icon(ConstantIcons.instance.getForwardIcon()),
    ));
  }

  void _openImage(ProductImageData imageData) => Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ProductImageViewer(
          barcode: widget.barcode!,
          productImageData: imageData,
        ),
      ));

  Future<void> _newImage({
    required ImageField field,
    required int index,
  }) async {
    final File? croppedImageFile = await startImageCropping(context);
    if (croppedImageFile == null) {
      return;
    }
    setState(() {
      imageProviders[index] = FileImage(croppedImageFile);
    });
    if (!mounted) {
      return;
    }
    final bool isUploaded = await uploadCapturedPicture(
      context,
      barcode: widget.barcode!,
      imageField: field,
      imageUri: croppedImageFile.uri,
    );

    if (isUploaded) {
      _isRefreshed = true;
      if (!mounted) {
        return;
      }
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      final String message = getImageUploadedMessage(
        field,
        appLocalizations,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
