import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_int.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/crop_page.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product_crop_helper.dart';
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
  });

  final String barcode;
  final List<ProductImage> rawImages;
  final ImageField imageField;
  final bool isLoggedInMandatory;

  /// Language for which we'll save the cropped image.
  final OpenFoodFactsLanguage language;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double columnWidth = mediaQueryData.size.width * .45;
    return SmoothScaffold(
      backgroundColor: Colors.black,
      appBar: SmoothAppBar(
        title: Text(appLocalizations.edit_photo_select_existing_all_label),
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
          maxCrossAxisExtent: mediaQueryData.size.width / 2,
          childAspectRatio: 1,
          mainAxisSpacing: MEDIUM_SPACE,
          crossAxisSpacing: MEDIUM_SPACE,
        ),
        itemBuilder: (final BuildContext context, int index) {
          // order by descending ids
          index = rawImages.length - 1 - index;
          final ProductImage rawImage = rawImages[index];
          final String url = rawImage.getUrl(
            barcode,
            imageSize: ImageSize.DISPLAY,
          );
          return GestureDetector(
            onTap: () async {
              final LocalDatabase localDatabase = context.read<LocalDatabase>();
              final NavigatorState navigatorState = Navigator.of(context);
              final File? imageFile = await downloadImageUrl(
                context,
                rawImage.getUrl(
                  barcode,
                  imageSize: ImageSize.ORIGINAL,
                ),
                DaoInt(localDatabase),
              );
              if (imageFile == null) {
                return;
              }
              final CropParameters? parameters =
                  await navigatorState.push<CropParameters>(
                MaterialPageRoute<CropParameters>(
                  builder: (BuildContext context) => CropPage(
                    inputFile: imageFile,
                    initiallyDifferent: true,
                    isLoggedInMandatory: isLoggedInMandatory,
                    cropHelper: ProductCropAgainHelper(
                      barcode: barcode,
                      imageField: imageField,
                      imageId: int.parse(rawImage.imgid!),
                      language: language,
                    ),
                  ),
                  fullscreenDialog: true,
                ),
              );
              if (parameters != null) {
                navigatorState.pop();
              }
            },
            child: ClipRRect(
              borderRadius: ROUNDED_BORDER_RADIUS,
              child: Container(
                width: columnWidth,
                height: columnWidth,
                color: Colors.grey[900],
                child: SmoothImage(
                  width: columnWidth,
                  height: columnWidth,
                  imageProvider: NetworkImage(url),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
