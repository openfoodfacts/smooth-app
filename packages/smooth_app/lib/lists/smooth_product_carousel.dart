import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/personalized_search/matched_product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_edit.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/smooth_it_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';

class SmoothProductCarousel extends StatefulWidget {
  const SmoothProductCarousel({
    required this.continuousScanModel,
    this.height = 120.0,
    Key? key,
  }) : super(key: key);

  final ContinuousScanModel continuousScanModel;
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
    final List<String> barcodes = widget.continuousScanModel.getBarcodes();
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
      itemBuilder: (BuildContext context, int itemIndex, int itemRealIndex) =>
          Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _getWidget(barcodes[itemIndex], productPreferences),
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

  Widget _getWidget(
    final String barcode,
    final ProductPreferences productPreferences,
  ) {
    switch (widget.continuousScanModel.getBarcodeState(barcode)!) {
      case ScannedProductState.FOUND:
      case ScannedProductState.CACHED:
        final Product product = widget.continuousScanModel.getProduct(barcode);
        if (widget.continuousScanModel.contributionMode) {
          return SmoothProductCardEdit(heroTag: barcode, product: product);
        }
        final MatchedProduct matchedProduct =
            MatchedProduct(product, productPreferences);
        return SmoothProductCardFound(
          heroTag: barcode,
          product: product,
          backgroundColor: PersonalizedRankingPage.getColor(
            colorScheme: Theme.of(context).colorScheme,
            matchIndex: SmoothItModel.getMatchIndex(matchedProduct),
            colorDestination: ColorDestination.SURFACE_BACKGROUND,
          ),
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
        return const SmoothProductCardThanks();
    }
  }
}
