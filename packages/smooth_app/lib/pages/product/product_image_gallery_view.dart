import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_gauge.dart';

class ProductImageGalleryView extends StatelessWidget {
  const ProductImageGalleryView({
    required this.product,
    required this.currenImageUrl,
    required this.title,
  });

  final Product product;
  final String currenImageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final List<String> imageUrls = <String>[
      if (product.imageFrontUrl != null) product.imageFrontUrl!,
      if (product.imageIngredientsUrl != null) product.imageIngredientsUrl!,
      if (product.imageNutritionUrl != null) product.imageNutritionUrl!,
      if (product.imagePackagingUrl != null) product.imagePackagingUrl!,
    ];

    //When all are empty there shouldn't be a way to access this page
    if (imageUrls.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(appLocalizations.error),
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      ),
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        pageController: PageController(
          initialPage: imageUrls.indexOf(
            imageUrls.firstWhere((String element) => element == currenImageUrl),
          ),
        ),
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.1,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
          );
        },
        itemCount: imageUrls.length,
        loadingBuilder:
            (final BuildContext context, final ImageChunkEvent? event) {
          return Center(
            child: SmoothGauge(
              color: Theme.of(context).colorScheme.onBackground,
              value: event == null ||
                      event.expectedTotalBytes == null ||
                      event.expectedTotalBytes == 0
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          );
        },
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }
}
