// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:openfoodfacts/model/Product.dart';

// Project imports:
import 'package:smooth_app/cards/product_cards/smooth_product_card_edit.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';

class SmoothProductCarousel extends StatefulWidget {
  const SmoothProductCarousel({
    @required this.continuousScanModel,
    this.height = 120.0,
  });

  final ContinuousScanModel continuousScanModel;
  final double height;

  @override
  _SmoothProductCarouselState createState() => _SmoothProductCarouselState();
}

class _SmoothProductCarouselState extends State<SmoothProductCarousel> {
  final CarouselController _controller = CarouselController();
  int _length = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> barcodes = widget.continuousScanModel.getBarcodes();
    final int barcodesLength = barcodes.length;
    if (_length != barcodesLength) {
      _length = barcodesLength;
      if (_length > 1) {
        Future<void>.delayed(
          const Duration(seconds: 0),
          () => _controller.animateToPage(_length - 1),
        );
      }
    }
    return CarouselSlider.builder(
      itemCount: _length,
      itemBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _getWidget(barcodes[index]),
      ),
      carouselController: _controller,
      options: CarouselOptions(
        enlargeCenterPage: false,
        viewportFraction: 0.95,
        height: widget.height,
        enableInfiniteScroll: false,
      ),
    );
  }

  Widget _getWidget(final String barcode) {
    final Product product = widget.continuousScanModel.getProduct(barcode);
    switch (widget.continuousScanModel.getBarcodeState(barcode)) {
      case ScannedProductState.FOUND:
      case ScannedProductState.CACHED:
        if (widget.continuousScanModel.contributionMode) {
          return SmoothProductCardEdit(heroTag: barcode, product: product);
        }
        return SmoothProductCardFound(
          heroTag: barcode,
          product: product,
        );
      case ScannedProductState.LOADING:
        return SmoothProductCardLoading(barcode: barcode);
      case ScannedProductState.NOT_FOUND:
        return SmoothProductCardNotFound(
          product: Product(
            barcode: barcode,
          ),
          callback: () => widget.continuousScanModel
              .setBarcodeState(barcode, ScannedProductState.THANKS),
        );
      case ScannedProductState.THANKS:
        return SmoothProductCardThanks();
    }
    throw Exception('scanned barcode without state');
  }
}
