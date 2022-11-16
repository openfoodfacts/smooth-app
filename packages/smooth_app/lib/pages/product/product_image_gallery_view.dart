import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_images_sliver_list.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/confirm_and_upload_picture.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Display of the main 4 pictures of a product, with edit options.
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
  late final LocalDatabase _localDatabase;
  late final Product _initialProduct;
  late Product _product;

  late Map<ProductImageData, ImageProvider?> _selectedImages;

  bool _isRefreshed = false;

  ImageProvider? _provideImage(ProductImageData imageData) =>
      imageData.imageUrl == null ? null : NetworkImage(imageData.imageUrl!);

  String get _barcode => _initialProduct.barcode!;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_barcode);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_barcode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    final List<ProductImageData> allProductImagesData =
        getProductMainImagesData(
      _product,
      appLocalizations,
      includeOther: false,
    );
    _selectedImages = Map<ProductImageData, ImageProvider?>.fromIterables(
      allProductImagesData,
      allProductImagesData.map(_provideImage),
    );
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: _product.productName != null
            ? Text(
                _product.productName!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        leading: SmoothBackButton(
          onPressed: () => Navigator.maybePop(context, _isRefreshed),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ProductRefresher().fetchAndRefresh(
          barcode: _barcode,
          widget: this,
        ),
        child: Scrollbar(
          child: CustomScrollView(
            slivers: <Widget>[
              _buildTitle(
                appLocalizations.edit_product_form_item_photos_title,
                theme: theme,
              ),
              SmoothImagesSliverList(
                imagesData: _selectedImages,
                onTap: (
                  ProductImageData data,
                  _,
                  int? currentProductImageDataIndex,
                ) =>
                    data.imageUrl != null
                        ? _openImage(
                            selectedImages: _selectedImages,
                            index: currentProductImageDataIndex ?? 0,
                          )
                        : _newImage(data),
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _openImage({
    required int index,
    required Map<ProductImageData, ImageProvider?> selectedImages,
  }) async =>
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) {
            return ProductImageSwipeableView(
              barcode: _barcode,
              initialProductImageDataIndex: index,
              selectedImages: _selectedImages,
            );
          },
        ),
      );

  Future<void> _newImage(ProductImageData data) async {
    final File? croppedImageFile = await startImageCropping(this);
    if (croppedImageFile == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      final FileImage fileImage = FileImage(croppedImageFile);
      final ImageField imageField = data.imageField;
      for (final ProductImageData productImageData in _selectedImages.keys) {
        if (productImageData.imageField == imageField) {
          _selectedImages[productImageData] = fileImage;
          return;
        }
      }
    });
    final File? uploaded = await Navigator.push<File>(
      context,
      MaterialPageRoute<File>(
        builder: (BuildContext context) => ConfirmAndUploadPicture(
          barcode: _barcode,
          imageField: data.imageField,
          initialPhoto: croppedImageFile,
        ),
      ),
    );
    final bool isUploaded = uploaded != null;

    if (isUploaded) {
      _isRefreshed = true;
    }
  }
}
