import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_image_list.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/product_image_viewer.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// ProductImageGalleryView is a page that displays a list of product images.
///
/// It allows the user to add a new image and edit an existing image
/// by clicking on it.
///
class ProductImageGalleryView extends StatefulWidget {
  const ProductImageGalleryView({
    required this.imagesData,
    this.barcode,
  });

  final String? barcode;
  final List<ProductImageData> imagesData;

  @override
  State<ProductImageGalleryView> createState() =>
      _ProductImageGalleryViewState();
}

class _ProductImageGalleryViewState extends State<ProductImageGalleryView> {
  late final Map<ProductImageData, ImageProvider?> imagesData;

  bool _isRefreshed = false;
  bool _isLoadingMore = true;

  @override
  void initState() {
    imagesData = Map<ProductImageData, ImageProvider?>.fromIterables(
      widget.imagesData,
      widget.imagesData.map(_provideImage),
    );

    _getProductImages(widget.barcode!)
        .then((Iterable<ProductImageData>? loadedData) {
      if (loadedData == null) {
        return;
      }

      final Map<ProductImageData, ImageProvider<Object>?> newMap =
          Map<ProductImageData, ImageProvider?>.fromIterables(
        loadedData,
        loadedData.map(_provideImage),
      );

      setState(() {
        imagesData.addAll(newMap);
        _isLoadingMore = false;
      });
    });

    super.initState();
  }

  ImageProvider? _provideImage(ProductImageData imageData) =>
      imageData.imageUrl == null ? null : NetworkImage(imageData.imageUrl!);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // When there is no data there should be no way to get to this page.
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
        leading: SmoothBackButton(
          onPressed: () => Navigator.maybePop(context, _isRefreshed),
        ),
      ),
      body: SmoothImageList(
        imagesData: imagesData,
        onTap: (ProductImageData data, ImageProvider<Object>? provider) =>
            data.imageUrl != null ? _openImage(data) : _newImage(data),
        loading: _isLoadingMore,
      ),
    );
  }

  Future<void> _openImage(ProductImageData imageData) async =>
      Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ProductImageViewer(
              barcode: widget.barcode!,
              imageData: imageData,
            ),
          ));

  Future<void> _newImage(ProductImageData data) async {
    final File? croppedImageFile = await startImageCropping(context);
    if (croppedImageFile == null) {
      return;
    }
    setState(() {
      imagesData[data] = FileImage(croppedImageFile);
    });
    if (!mounted) {
      return;
    }
    final bool isUploaded = await uploadCapturedPicture(
      context,
      barcode: widget.barcode!,
      imageField: data.imageField,
      imageUri: croppedImageFile.uri,
    );

    if (isUploaded) {
      _isRefreshed = true;
      if (!mounted) {
        return;
      }
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      final String message = getImageUploadedMessage(
        data.imageField,
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

  Future<Iterable<ProductImageData>?> _getProductImages(String barcode) async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: <ProductField>[ProductField.IMAGES],
      language: ProductQuery.getLanguage(),
      country: ProductQuery.getCountry(),
    );

    final ProductResult result;
    try {
      result = await OpenFoodAPIClient.getProduct(configuration);
    } catch (e) {
      return null;
    }

    if (result.status != 1) {
      return null;
    }

    final Product? product = result.product;
    if (product == null || product.images == null) {
      return null;
    }

    return _deduplicateImages(product.images!).map(_getProductImageData);
  }

  /// Groups the list of [ProductImage] by [ProductImage.imgid]
  /// and returns the first of every group
  Iterable<ProductImage> _deduplicateImages(Iterable<ProductImage> images) =>
      images
          .groupListsBy((ProductImage element) => element.imgid)
          .values
          .map((List<ProductImage> sameIdImages) => sameIdImages.firstOrNull)
          .whereNotNull();

  /// Created a [ProductImageData] from a [ProductImage]
  ProductImageData _getProductImageData(ProductImage image) => ProductImageData(
        imageField: image.field,
        // TODO(VaiTon): i18n
        title: 'Image #${image.imgid}',
        buttonText: 'Image #${image.imgid}',
        imageUrl: ImageHelper.buildUrl(widget.barcode, image),
      );
}
