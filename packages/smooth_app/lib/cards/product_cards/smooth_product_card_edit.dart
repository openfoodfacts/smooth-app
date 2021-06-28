// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/ProductImage.dart';

// Project imports:
import 'package:smooth_app/pages/product/product_page.dart';

class SmoothProductCardEdit extends StatelessWidget {
  const SmoothProductCardEdit({
    required this.product,
    required this.heroTag,
  });

  final Product product;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //_openSneakPeek(context);
        Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => ProductPage(
              product: product,
            ),
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      product.productName ?? 'Unknown',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _generateImageView(ImageField.FRONT, context),
                  _generateImageView(ImageField.INGREDIENTS, context),
                  _generateImageView(ImageField.NUTRITION, context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generateImageView(ImageField field, BuildContext context) {
    late final Iterable<ProductImage> candidates;
    if (product.selectedImages != null) {
      candidates = product.selectedImages!
          .where((ProductImage image) => image.field == field)
          .where((ProductImage image) => image.size == ImageSize.SMALL);
    }

    final String? url = candidates.isNotEmpty ? candidates.first.url : null;
    return url != null
        ? ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 105.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    url,
                    scale: 1.0,
                  ),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (BuildContext context, Widget? child,
                      ImageChunkEvent? progress) {
                    if (progress == null) {
                      return child!;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        value: progress.expectedTotalBytes == null
                            ? null
                            : progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!,
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        : Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: 105.0,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
            child: Center(
              child: Text(
                '${AppLocalizations.of(context)!.missing_picture}: ${field.value}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          );
  }

  /*void _openSneakPeek(BuildContext context) {
    Navigator.push<Widget>(
        context,
        SmoothSneakPeekRoute<dynamic>(
            builder: (BuildContext context) {
              return Material(
                color: Colors.transparent,
                child: Center(
                  child: SmoothProductSneakPeekView(
                    product: product,
                    context: context,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
            duration: 250));
  }*/
}
