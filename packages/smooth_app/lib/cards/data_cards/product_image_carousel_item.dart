import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';
import 'package:smooth_app/query/product_query.dart';

/// Displays a product image in the carousel: access to gallery, or new image.
///
/// If the image exists, it's displayed and a tap gives access to the gallery.
/// If not, a "add image" button is displayed.
class ProductImageCarouselItem extends StatefulWidget {
  const ProductImageCarouselItem({
    required this.product,
    required this.productImageData,
  });

  final Product product;
  final ProductImageData productImageData;

  @override
  State<ProductImageCarouselItem> createState() =>
      _ProductImageCarouselItemState();
}

class _ProductImageCarouselItemState extends State<ProductImageCarouselItem> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    final ImageProvider? imageProvider = TransientFile.fromProductImageData(
      widget.productImageData,
      widget.product.barcode!,
      ProductQuery.getLanguage(),
    ).getImageProvider();

    if (imageProvider == null) {
      return ElevatedButton.icon(
        onPressed: () async => confirmAndUploadNewPicture(
          context,
          barcode: widget.product.barcode!,
          productType: widget.product.productType,
          imageField: widget.productImageData.imageField,
          language: ProductQuery.getLanguage(),
          isLoggedInMandatory: true,
        ),
        icon: const Icon(Icons.add_a_photo),
        label: Text(
          widget.productImageData.imageField.getProductImageButtonText(
            appLocalizations,
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
