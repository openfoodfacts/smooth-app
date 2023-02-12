import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_unselect.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/uploaded_image_gallery.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/tmp_crop_image/new_crop_page.dart';
import 'package:smooth_app/tmp_crop_image/rotation.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Displays a full-screen image with an "edit" floating button.
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.product,
    required this.imageField,
  });

  final Product product;
  final ImageField imageField;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;
  late ProductImageData _imageData;

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
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    _imageData = getProductImageData(_product, widget.imageField);
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      _imageData,
      _barcode,
    );
    return SmoothScaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(MINIMUM_TOUCH_SIZE / 2),
              child: imageProvider == null
                  ? const SizedBox.expand(child: PictureNotFound())
                  : PhotoView(
                      minScale: 0.2,
                      imageProvider: imageProvider,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: imageProvider,
                      ),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: _getGalleryButton(appLocalizations),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: _getCameraImageButton(
                    appLocalizations,
                    imageProvider == null,
                  ),
                ),
              ),
            ],
          ),
          if (imageProvider != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                    child: _getUnselectImageButton(appLocalizations),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                    child: _getEditImageButton(appLocalizations),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _getEditImageButton(final AppLocalizations appLocalizations) =>
      EditImageButton(
        iconData: Icons.edit,
        label: appLocalizations.edit_photo_button_label,
        onPressed: _actionEditImage,
      );

  Widget _getCameraImageButton(
    final AppLocalizations appLocalizations,
    final bool firstPhoto,
  ) =>
      EditImageButton(
        iconData: firstPhoto ? Icons.add : Icons.add_a_photo,
        label: firstPhoto ? appLocalizations.add : appLocalizations.capture,
        onPressed: _actionNewImage,
      );

  Widget _getUnselectImageButton(final AppLocalizations appLocalizations) =>
      EditImageButton(
        iconData: Icons.do_disturb_on,
        label: appLocalizations.edit_photo_unselect_button_label,
        onPressed: _actionUnselect,
      );

  Widget _getGalleryButton(final AppLocalizations appLocalizations) =>
      EditImageButton(
        iconData: Icons.image_search,
        label: appLocalizations.edit_photo_select_existing_button_label,
        onPressed: _actionGallery,
      );

  // TODO(monsieurtanuki): we should also suggest the existing image gallery
  Future<File?> _actionNewImage() async {
    // ignore: use_build_context_synchronously
    if (!await ProductRefresher().checkIfLoggedIn(context)) {
      return null;
    }
    return confirmAndUploadNewPicture(
      this,
      imageField: _imageData.imageField,
      barcode: _barcode,
    );
  }

  Future<void> _actionGallery() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    // ignore: use_build_context_synchronously
    if (!await ProductRefresher().checkIfLoggedIn(context)) {
      return;
    }
    // ignore: use_build_context_synchronously
    final List<int>? result = await LoadingDialog.run<List<int>>(
      future: OpenFoodAPIClient.getProductImageIds(
        _barcode,
        user: ProductQuery.getUser(),
      ),
      context: context,
      title: appLocalizations.edit_photo_select_existing_download_label,
    );
    if (result == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    if (result.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body:
              Text(appLocalizations.edit_photo_select_existing_downloaded_none),
          actionsAxis: Axis.vertical,
          positiveAction: SmoothActionButton(
            text: appLocalizations.okay,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => UploadedImageGallery(
          barcode: _barcode,
          imageIds: result,
          imageField: widget.imageField,
        ),
      ),
    );
  }

  Future<File?> _actionEditImage() async {
    final NavigatorState navigatorState = Navigator.of(context);
    // ignore: use_build_context_synchronously
    if (!await ProductRefresher().checkIfLoggedIn(context)) {
      return null;
    }
    // best possibility: with the crop parameters
    // TODO(monsieurtanuki): maybe we should keep the big image locally, in order to avoid the server call?
    final ProductImage? productImage = _getBestProductImage();
    if (productImage != null) {
      final int? imageId = int.tryParse(productImage.imgid!);
      if (imageId != null) {
        return _openEditCroppedImage(imageId, productImage);
      }
    }

    // alternate option: use the transient file.
    File? imageFile = TransientFile.getImage(
      _imageData.imageField,
      _barcode,
    );
    if (imageFile != null) {
      return _openCropPage(navigatorState, imageFile);
    }

    // but if not possible, get the best picture from the server.
    final String? imageUrl = _imageData.getImageUrl(ImageSize.ORIGINAL);
    // ignore: use_build_context_synchronously
    imageFile = await downloadImageUrl(
      context,
      imageUrl,
      DaoInt(_localDatabase),
    );
    if (imageFile != null) {
      return _openCropPage(navigatorState, imageFile);
    }

    return null;
  }

  Future<void> _actionUnselect() async {
    final NavigatorState navigatorState = Navigator.of(context);
    // ignore: use_build_context_synchronously
    if (!await ProductRefresher().checkIfLoggedIn(context)) {
      return;
    }
    await BackgroundTaskUnselect.addTask(
      _barcode,
      imageField: widget.imageField,
      widget: this,
    );
    _localDatabase.notifyListeners();
    navigatorState.pop();
  }

  Future<File?> _openCropPage(
    final NavigatorState navigatorState,
    final File imageFile, {
    final int? imageId,
    final Rect? initialCropRect,
    final Rotation? initialRotation,
  }) async =>
      navigatorState.push<File>(
        MaterialPageRoute<File>(
          builder: (BuildContext context) => CropPage(
            barcode: _product.barcode!,
            imageField: _imageData.imageField,
            inputFile: imageFile,
            imageId: imageId,
            initiallyDifferent: false,
            initialCropRect: initialCropRect,
            initialRotation: initialRotation,
          ),
          fullscreenDialog: true,
        ),
      );

  Future<File?> _openEditCroppedImage(
    final int imageId,
    final ProductImage productImage,
  ) async {
    final NavigatorState navigatorState = Navigator.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final File? imageFile = await downloadImageUrl(
      context,
      ImageHelper.getUploadedImageUrl(
        _product.barcode!,
        imageId,
        ImageSize.ORIGINAL,
      ),
      DaoInt(localDatabase),
    );
    if (imageFile == null) {
      return null;
    }
    return _openCropPage(
      navigatorState,
      imageFile,
      imageId: imageId,
      initialCropRect: _getCropRect(productImage),
      initialRotation: RotationExtension.fromDegrees(
        productImage.angle?.degree ?? 0,
      ),
    );
  }

  ProductImage? _getBestProductImage() {
    if (_product.images == null) {
      return null;
    }
    for (final ProductImage productImage in _product.images!) {
      if (productImage.field != _imageData.imageField) {
        continue;
      }
      if (productImage.language != ProductQuery.getLanguage()) {
        continue;
      }
      if (productImage.size == ImageSize.ORIGINAL) {
        if (productImage.imgid != null) {
          return productImage;
        }
      }
    }
    return null;
  }

  /// Returns a crop rect, to be compared with the full image dimensions.
  Rect? _getCropRect(final ProductImage productImage) =>
      productImage.x1 == null ||
              productImage.y1 == null ||
              productImage.x2 == null ||
              productImage.y2 == null
          ? null
          : Rect.fromLTRB(
              productImage.x1!.toDouble(),
              productImage.y1!.toDouble(),
              productImage.x2!.toDouble(),
              productImage.y2!.toDouble(),
            );
}
