import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_images_sliver_grid.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_images_sliver_list.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
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
    required this.product,
  });

  final Product product;

  @override
  State<ProductImageGalleryView> createState() =>
      _ProductImageGalleryViewState();
}

class _ProductImageGalleryViewState extends State<ProductImageGalleryView> {
  Map<ProductImageData, ImageProvider?> _selectedImages =
      <ProductImageData, ImageProvider<Object>?>{};

  final Map<ProductImageData, ImageProvider?> _unselectedImages =
      <ProductImageData, ImageProvider?>{};

  bool _isRefreshed = false;
  bool _isLoadingMore = true;

  ImageProvider? _provideImage(ProductImageData imageData) =>
      imageData.imageUrl == null ? null : NetworkImage(imageData.imageUrl!);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Consumer<UpToDateProductProvider>(
      builder: (
        BuildContext context,
        UpToDateProductProvider provider,
        Widget? child,
      ) {
        Product product = widget.product;

        final Product? refreshedProduct = provider.get(product);
        if (refreshedProduct != null) {
          product = refreshedProduct;
        }
        final List<ProductImageData> allProductImagesData =
            getProductMainImagesData(product, appLocalizations);
        _selectedImages = Map<ProductImageData, ImageProvider?>.fromIterables(
          allProductImagesData,
          allProductImagesData.map(_provideImage),
        );

        _getProductImages().then(
          (Iterable<ProductImageData>? loadedData) {
            if (loadedData == null) {
              return;
            }

            final Map<ProductImageData, ImageProvider<Object>?> newMap =
                Map<ProductImageData, ImageProvider?>.fromIterables(
              loadedData,
              loadedData.map(_provideImage),
            );
            if (mounted) {
              setState(
                () {
                  _unselectedImages.clear();
                  _unselectedImages.addAll(newMap);
                  _isLoadingMore = false;
                },
              );
            }
          },
        );
        if (_selectedImages.isEmpty) {
          return SmoothScaffold(
            body: Center(
              child: Text(appLocalizations.error),
            ),
          );
        }
        return SmoothScaffold(
          appBar: AppBar(
            title: Text(appLocalizations.edit_product_form_item_photos_title),
            leading: SmoothBackButton(
              onPressed: () => Navigator.maybePop(context, _isRefreshed),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              _refreshProduct(context);
            },
            child: Scrollbar(
              child: CustomScrollView(
                slivers: <Widget>[
                  _buildTitle(appLocalizations.selected_images, theme: theme),
                  SmoothImagesSliverList(
                    imagesData: _selectedImages,
                    onTap: (ProductImageData data, _) => data.imageUrl != null
                        ? _openImage(data)
                        : _newImage(data),
                  ),
                  _buildTitle(appLocalizations.all_images, theme: theme),
                  SmoothImagesSliverGrid(
                    imagesData: _unselectedImages,
                    loading: _isLoadingMore,
                    onTap: (ProductImageData data, _) => _openImage(data),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverPadding _buildTitle(String title, {required ThemeData theme}) =>
      SliverPadding(
        padding: const EdgeInsets.all(LARGE_SPACE),
        sliver: SliverToBoxAdapter(
          child: Text(
            title,
            style: theme.textTheme.headline2,
          ),
        ),
      );

  Future<bool> _refreshProduct(BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final bool success = await ProductRefresher().fetchAndRefresh(
      context: context,
      localDatabase: localDatabase,
      barcode: widget.product.barcode!,
    );
    if (mounted && success) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.product_refreshed),
          duration: SnackBarDuration.short,
        ),
      );
    }
    return success;
  }

  Future<void> _openImage(ProductImageData imageData) async =>
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductImageViewer(
            barcode: widget.product.barcode!,
            imageData: imageData,
          ),
        ),
      );

  Future<void> _newImage(ProductImageData data) async {
    final File? croppedImageFile = await startImageCropping(context);
    if (croppedImageFile == null) {
      return;
    }
    if (mounted) {
      setState(() {
        final FileImage fileImage = FileImage(croppedImageFile);
        if (_selectedImages.containsKey(data)) {
          _selectedImages[data] = fileImage;
        } else if (_unselectedImages.containsKey(data)) {
          _unselectedImages[data] = fileImage;
        } else {
          throw ArgumentError('Could not find the type of $data');
        }
      });
    }
    if (!mounted) {
      return;
    }
    final bool isUploaded = await uploadCapturedPicture(
      context,
      barcode: widget.product.barcode!,
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
          duration: SnackBarDuration.medium,
        ),
      );
    }
  }

  Future<Iterable<ProductImageData>?> _getProductImages() async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      widget.product.barcode!,
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

    final Product? resultProduct = result.product;
    if (resultProduct == null || resultProduct.images == null) {
      return null;
    }

    return _deduplicateImages(resultProduct.images!).map(_getProductImageData);
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
        title: image.imgid ?? '',
        buttonText: image.imgid ?? '',
        imageUrl: ImageHelper.buildUrl(widget.product.barcode, image),
      );
}
