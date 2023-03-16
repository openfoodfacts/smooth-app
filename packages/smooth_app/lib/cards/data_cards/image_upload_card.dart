import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';

// TODO(monsieurtanuki): rename that class, like `ProductImageCarouselItem`
/// Displays a product image in the carousel: access to gallery, or new image.
///
/// If the image exists, it's displayed and a tap gives access to the gallery.
/// If not, a "add image" button is displayed.
class ImageUploadCard extends StatefulWidget {
  const ImageUploadCard({
    required this.product,
    required this.productImageData,
  });

  final Product product;
  final ProductImageData productImageData;

  @override
  State<ImageUploadCard> createState() => _ImageUploadCardState();
}

class _ImageUploadCardState extends State<ImageUploadCard> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      widget.productImageData,
      widget.product.barcode!,
    );

    if (imageProvider == null) {
      return ElevatedButton.icon(
        onPressed: () async => confirmAndUploadNewPicture(
          this,
          barcode: widget.product.barcode!,
          imageField: widget.productImageData.imageField,
        ),
        icon: const Icon(Icons.add_a_photo),
        label: Text(
          getProductImageButtonText(
            appLocalizations,
            widget.productImageData.imageField,
          ),
        ),
      );
    }
    return GestureDetector(
      child: Center(
        child: Image(
          image: imageProvider,
          fit: BoxFit.cover,
          height: 1000,
          errorBuilder: (
            BuildContext context,
            Object exception,
            StackTrace? stackTrace,
          ) =>
              Column(
            children: <Widget>[
              Icon(
                Icons.cloud_off_sharp,
                size: screenSize.width / 4,
              ),
              Text(appLocalizations.no_internet_connection),
            ],
          ),
        ),
      ),
      onTap: () async => Navigator.push<void>(
        context,
        MaterialPageRoute<bool>(
          builder: (BuildContext context) => ProductImageGalleryView(
            product: widget.product,
          ),
        ),
      ),
    );
  }
}
