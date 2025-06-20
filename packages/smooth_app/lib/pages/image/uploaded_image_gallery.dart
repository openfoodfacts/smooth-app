import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_page.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image/product_image_widget.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product_crop_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Gallery of all images already uploaded, about a given product.
class UploadedImageGallery extends StatelessWidget {
  const UploadedImageGallery({
    required this.barcode,
    required this.rawImages,
    required this.imageField,
    required this.language,
    required this.isLoggedInMandatory,
    required this.productType,
  });

  final String barcode;
  final List<ProductImage> rawImages;
  final ImageField imageField;
  final bool isLoggedInMandatory;
  final ProductType? productType;

  /// Language for which we'll save the cropped image.
  final OpenFoodFactsLanguage language;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final double columnWidth = MediaQuery.sizeOf(context).width / 2;

    return SmoothScaffold(
      backgroundColor: Colors.black,
      brightness: Brightness.light,
      appBar: SmoothAppBar(
        title: Text(appLocalizations.edit_photo_select_existing_all_label),
        subTitle:
            Text(appLocalizations.edit_photo_select_existing_all_subtitle),
        backgroundColor: Colors.black,
        foregroundColor: WHITE_COLOR,
        elevation: 0,
        leading: const SmoothBackButton(
          iconColor: Colors.white,
        ),
      ),
      body: GridView.builder(
        itemCount: rawImages.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: columnWidth,
          childAspectRatio: 1,
        ),
        itemBuilder: (final BuildContext context, int index) {
          // order by descending ids
          index = rawImages.length - 1 - index;
          final ProductImage rawImage = rawImages[index];

          return Padding(
            padding: EdgeInsetsDirectional.only(
              start: VERY_SMALL_SPACE,
              end: index.isEven ? VERY_SMALL_SPACE : 0.0,
              bottom: VERY_SMALL_SPACE,
            ),
            child: InkWell(
              borderRadius: ANGULAR_BORDER_RADIUS,
              onTap: () async {},
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: ProductImageWidget(
                      productImage: rawImage,
                      barcode: barcode,
                      squareSize: columnWidth,
                      productType: productType,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: ANGULAR_BORDER_RADIUS,
                        onTap: () async =>
                            Navigator.of(context).pop<CropParameters?>(
                          await useExistingPhotoFor(
                            context: context,
                            rawImage: rawImage,
                            barcode: barcode,
                            imageField: imageField,
                            isLoggedInMandatory: isLoggedInMandatory,
                            productType: productType,
                            language: language,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Future<CropParameters?> useExistingPhotoFor({
    required final BuildContext context,
    required final ProductImage rawImage,
    required final String barcode,
    required final ImageField imageField,
    required final bool isLoggedInMandatory,
    required final ProductType? productType,
    required final OpenFoodFactsLanguage language,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final File? imageFile = await downloadImageUrl(
      context,
      rawImage.getUrl(
        barcode,
        imageSize: ImageSize.ORIGINAL,
        uriHelper: ProductQuery.getUriProductHelper(
          productType: productType,
        ),
      ),
      DaoInt(localDatabase),
    );
    if (imageFile == null || !context.mounted) {
      return null;
    }

    return Navigator.of(context).push<CropParameters>(
      MaterialPageRoute<CropParameters>(
        builder: (BuildContext context) => CropPage(
          inputFile: imageFile,
          initiallyDifferent: true,
          isLoggedInMandatory: isLoggedInMandatory,
          cropHelper: ProductCropAgainHelper(
            barcode: barcode,
            productType: productType,
            imageField: imageField,
            imageId: int.parse(rawImage.imgid!),
            language: language,
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
