import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart' hide EMPTY_WIDGET;
import 'package:smooth_app/cards/product_cards/smooth_product_card_error.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_supported.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/scan_main_card.dart';
import 'package:smooth_app/pages/scan/carousel/scan_carousel_manager.dart';
import 'package:smooth_app/pages/scan/scan_product_card_loader.dart';

class ScanPageCarousel extends StatefulWidget {
  const ScanPageCarousel({
    this.onPageChangedTo,
  });

  final Function(int page, String? productBarcode)? onPageChangedTo;

  @override
  State<ScanPageCarousel> createState() => _ScanPageCarouselState();
}

class _ScanPageCarouselState extends State<ScanPageCarousel> {
  static const double HORIZONTAL_SPACE_BETWEEN_CARDS = 5.0;

  List<String> barcodes = <String>[];
  String? _lastConsultedBarcode;
  int? _carrouselMovingTo;
  int _lastIndex = 0;

  late ContinuousScanModel _model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _model = context.watch<ContinuousScanModel>();

    if (!ExternalScanCarouselManager.read(context).controller.ready) {
      return;
    }

    barcodes = _model.getBarcodes();

    if (barcodes.isEmpty) {
      // Ensure to reset all variables
      _lastConsultedBarcode = null;
      _carrouselMovingTo = null;
      _lastIndex = 0;
      return;
    } else if (_lastConsultedBarcode == _model.latestConsultedBarcode) {
      // Prevent multiple irrelevant movements
      return;
    }

    _lastConsultedBarcode = _model.latestConsultedBarcode;
    final int cardsCount = barcodes.length + 1;

    if (_model.latestConsultedBarcode != null &&
        _model.latestConsultedBarcode!.isNotEmpty) {
      final int indexBarcode = barcodes.indexOf(_model.latestConsultedBarcode!);
      if (indexBarcode >= 0) {
        final int indexCarousel = indexBarcode + 1;
        _moveControllerTo(indexCarousel);
      } else {
        if (_lastIndex > cardsCount) {
          _moveControllerTo(cardsCount);
        } else {
          _moveControllerTo(_lastIndex);
        }
      }
    } else {
      _moveControllerTo(0);
    }
  }

  Future<void> _moveControllerTo(int page) async {
    if (_carrouselMovingTo == null && _lastIndex != page) {
      widget.onPageChangedTo?.call(
        page,
        page >= 1 ? barcodes[page - 1] : null,
      );

      _carrouselMovingTo = page;
      ExternalScanCarouselManager.read(context).animatePageTo(page);
      _carrouselMovingTo = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    barcodes = _model.getBarcodes();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CarouselSlider.builder(
          itemCount: barcodes.length + 1,
          itemBuilder:
              (BuildContext context, int itemIndex, int itemRealIndex) {
            return SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_SPACE_BETWEEN_CARDS,
                ),
                child: itemIndex == 0
                    ? const ScanMainCard()
                    : _getWidget(itemIndex - 1),
              ),
            );
          },
          carouselController:
              ExternalScanCarouselManager.watch(context).controller,
          options: CarouselOptions(
            enlargeCenterPage: false,
            viewportFraction: _computeViewPortFraction(),
            height: constraints.maxHeight,
            enableInfiniteScroll: false,
            onPageChanged: (int index, CarouselPageChangedReason reason) {
              _lastIndex = index;

              if (index > 0) {
                if (reason == CarouselPageChangedReason.manual) {
                  _model.lastConsultedBarcode = barcodes[index - 1];
                  _lastConsultedBarcode = _model.latestConsultedBarcode;
                }
              } else if (index == 0) {
                _model.lastConsultedBarcode = null;
                _lastConsultedBarcode = null;
              }
            },
          ),
        );
      },
    );
  }

  /// Displays the card for this [index] of a list of [barcodes]
  ///
  /// There are special cases when the item display is refreshed
  /// after the product disappeared and before the whole carousel is refreshed.
  /// In those cases, we don't want the app to crash and display a Container
  /// instead in the meanwhile.
  Widget _getWidget(final int index) {
    if (index >= barcodes.length) {
      return EMPTY_WIDGET;
    }

    final String barcode = barcodes[index];
    switch (_model.getBarcodeState(barcode)!) {
      case ScannedProductState.FOUND:
      case ScannedProductState.CACHED:
        return ScanProductCardLoader(
          barcode: barcode,
          onRemoveProduct: (_) => _model.removeBarcode(barcode),
        );
      case ScannedProductState.LOADING:
        return ScanProductCardLoading(
          barcode: barcode,
          onRemoveProduct: (_) => _model.removeBarcode(barcode),
        );
      case ScannedProductState.NOT_FOUND:
        return ScanProductCardNotFound(
          barcode: barcode,
          onAddProduct: () async {
            await _model.refresh();
            setState(() {});
          },
          onRemoveProduct: (_) => _model.removeBarcode(barcode),
        );
      case ScannedProductState.ERROR_INTERNET:
        return ScanProductCardError(
          barcode: barcode,
          errorType: ScannedProductState.ERROR_INTERNET,
        );
      case ScannedProductState.ERROR_INVALID_CODE:
        return ScanProductCardNotSupported(
          barcode: barcode,
          onRemoveProduct: (_) => _model.removeBarcode(barcode),
        );
    }
  }

  double _computeViewPortFraction() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    if (barcodes.isEmpty) {
      return 0.95;
    }

    return (screenWidth -
            (SmoothBarcodeScannerVisor.CORNER_PADDING * 2) -
            (SmoothBarcodeScannerVisor.STROKE_WIDTH * 2) +
            (HORIZONTAL_SPACE_BETWEEN_CARDS * 4)) /
        screenWidth;
  }
}
