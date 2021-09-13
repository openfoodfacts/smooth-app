import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/pages/scan/product_card.dart';

class SmoothProductCarousel extends StatefulWidget {
  const SmoothProductCarousel({
    this.height = 140.0,
  });

  final double height;

  @override
  State<SmoothProductCarousel> createState() => _SmoothProductCarouselState();
}

class _SmoothProductCarouselState extends State<SmoothProductCarousel> {
  final CarouselController _controller = CarouselController();
  int _length = 0;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();
    final List<String> barcodes = model.getBarcodes();
    final int barcodesLength = barcodes.length;
    if (_length != barcodesLength) {
      _length = barcodesLength;
      if (_length > 1) {
        Future<void>.delayed(
          Duration.zero,
          () => _controller.animateToPage(_length - 1),
        );
      }
    }
    return CarouselSlider.builder(
      itemCount: _length,
      itemBuilder: (BuildContext context, int itemIndex, int itemRealIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: _buildCard(barcodes, itemIndex, productPreferences),
        );
      },
      carouselController: _controller,
      options: CarouselOptions(
        viewportFraction: 0.8,
        height: widget.height,
        enableInfiniteScroll: false,
      ),
    );
  }

  /// Displays the card for this [index] of a list of [barcodes]
  ///
  /// There are special cases when the item display is refreshed
  /// after the product disappeared and before the whole carousel is refreshed.
  /// In those cases, we don't want the app to crash and display a Container
  /// instead in the meanwhile.
  Widget _buildCard(
    final List<String> barcodes,
    final int index,
    final ProductPreferences productPreferences,
  ) {
    if (index >= barcodes.length) {
      return Container();
    }
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();
    final String barcode = barcodes[index];
    switch (model.getBarcodeState(barcode)!) {
      case ScannedProductState.FOUND:
      case ScannedProductState.CACHED:
        final Product product = model.getProduct(barcode);
        return ProductCard(product);
      case ScannedProductState.LOADING:
        return SmoothProductCardLoading(barcode: barcode);
      case ScannedProductState.NOT_FOUND:
        return SmoothProductCardNotFound(
          product: Product(barcode: barcode),
          callback: () =>
              model.setBarcodeState(barcode, ScannedProductState.THANKS),
        );
      case ScannedProductState.THANKS:
        return const SmoothProductCardThanks();
    }
  }
}
