// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_unselect.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/crop_page.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_image_button.dart';
import 'package:smooth_app/pages/product/product_image_local_button.dart';
import 'package:smooth_app/pages/product/product_image_server_button.dart';

/// Displays a full-screen image with an "edit" floating button.
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.product,
    required this.imageField,
    required this.language,
    required this.setLanguage,
    required this.isLoggedInMandatory,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final Future<void> Function(OpenFoodFactsLanguage? newLanguage) setLanguage;
  final bool isLoggedInMandatory;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer>
    with UpToDateMixin {
  late ProductImageData _imageData;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    _imageData = getProductImageData(
      upToDateProduct,
      widget.imageField,
      widget.language,
      forceLanguage: true,
    );
    final ImageProvider? imageProvider = _getTransientFile().getImageProvider();
    final Iterable<OpenFoodFactsLanguage> selectedLanguages =
        getProductImageLanguages(
      upToDateProduct,
      widget.imageField,
    );

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(MINIMUM_TOUCH_SIZE / 2),
              child: imageProvider == null
                  ? Stack(
                      children: <Widget>[
                        const SizedBox.expand(child: PictureNotFound()),
                        Center(
                          child: Text(
                            selectedLanguages.isEmpty
                                ? appLocalizations.edit_photo_language_none
                                : appLocalizations
                                    .edit_photo_language_not_this_one,
                            style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.black) ??
                                const TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : PhotoView(
                      minScale: 0.2,
                      imageProvider: imageProvider,
                      heroAttributes: PhotoViewHeroAttributes(
                          tag: 'photo_${widget.imageField.offTag}',
                          flightShuttleBuilder: (
                            _,
                            Animation<double> animation,
                            HeroFlightDirection flightDirection,
                            BuildContext fromHeroContext,
                            BuildContext toHeroContext,
                          ) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (_, __) {
                                Widget widget;
                                if (flightDirection ==
                                    HeroFlightDirection.push) {
                                  widget = fromHeroContext.widget;
                                } else {
                                  widget = toHeroContext.widget;
                                }

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                          1 - animation.value) *
                                      ROUNDED_RADIUS.x,
                                  child: widget,
                                );
                              },
                            );
                          }),
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
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(LARGE_SPACE),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: LanguageSelector(
                      setLanguage: widget.setLanguage,
                      displayedLanguage: widget.language,
                      selectedLanguages: selectedLanguages,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 13.0,
                        vertical: SMALL_SPACE,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: ProductImageServerButton(
                    product: upToDateProduct,
                    imageField: widget.imageField,
                    language: widget.language,
                    isLoggedInMandatory: widget.isLoggedInMandatory,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                  child: ProductImageLocalButton(
                    firstPhoto: imageProvider == null,
                    barcode: barcode,
                    imageField: widget.imageField,
                    language: widget.language,
                    isLoggedInMandatory: widget.isLoggedInMandatory,
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

  // TODO(monsieurtanuki): refactor as ProductImageCropButton
  Widget _getEditImageButton(final AppLocalizations appLocalizations) =>
      EditImageButton(
        iconData: Icons.edit,
        label: appLocalizations.edit_photo_button_label,
        onPressed: _actionEditImage,
      );

  // TODO(monsieurtanuki): refactor as ProductImageUnselectButton
  Widget _getUnselectImageButton(final AppLocalizations appLocalizations) =>
      EditImageButton(
        iconData: Icons.do_disturb_on,
        label: appLocalizations.edit_photo_unselect_button_label,
        onPressed: () => _actionUnselect(appLocalizations),
      );

  Future<File?> _actionEditImage() async {
    final NavigatorState navigatorState = Navigator.of(context);
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    )) {
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
    File? imageFile = _getTransientFile().getImage();
    if (imageFile != null) {
      return _openCropPage(navigatorState, imageFile);
    }

    // but if not possible, get the best picture from the server.
    final String? imageUrl = _imageData.getImageUrl(ImageSize.ORIGINAL);
    imageFile = await downloadImageUrl(
      context,
      imageUrl,
      DaoInt(context.read<LocalDatabase>()),
    );
    if (imageFile != null) {
      return _openCropPage(navigatorState, imageFile);
    }

    return null;
  }

  TransientFile _getTransientFile() => TransientFile.fromProductImageData(
        _imageData,
        barcode,
        widget.language,
      );

  Future<void> _actionUnselect(final AppLocalizations appLocalizations) async {
    final NavigatorState navigatorState = Navigator.of(context);

    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    )) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: appLocalizations.confirm_button_label,
          body: Text(
            appLocalizations.are_you_sure,
          ),
          close: true,
          positiveAction: SmoothActionButton(
            text: appLocalizations.yes,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.no,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        );
      },
    );
    if (confirmed == true) {
      await BackgroundTaskUnselect.addTask(
        barcode,
        imageField: widget.imageField,
        widget: this,
        language: widget.language,
      );
      context.read<LocalDatabase>().notifyListeners();
      navigatorState.pop();
    }
  }

  Future<File?> _openCropPage(
    final NavigatorState navigatorState,
    final File imageFile, {
    final int? imageId,
    final Rect? initialCropRect,
    final CropRotation? initialRotation,
  }) async =>
      navigatorState.push<File>(
        MaterialPageRoute<File>(
          builder: (BuildContext context) => CropPage(
            language: widget.language,
            barcode: barcode,
            imageField: _imageData.imageField,
            inputFile: imageFile,
            imageId: imageId,
            initiallyDifferent: false,
            initialCropRect: initialCropRect,
            initialRotation: initialRotation,
            isLoggedInMandatory: widget.isLoggedInMandatory,
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
        barcode,
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
      initialRotation: CropRotationExtension.fromDegrees(
        productImage.angle?.degree ?? 0,
      ),
    );
  }

  ProductImage? _getBestProductImage() {
    if (upToDateProduct.images == null) {
      return null;
    }
    for (final ProductImage productImage in upToDateProduct.images!) {
      if (productImage.field != _imageData.imageField) {
        continue;
      }
      if (productImage.language != widget.language) {
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
