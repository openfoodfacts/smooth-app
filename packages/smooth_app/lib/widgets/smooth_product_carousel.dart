import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_error.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/scan/inherited_data_manager.dart';
import 'package:smooth_app/pages/scan/scan_product_card.dart';
import 'package:smooth_app/pages/scan/search_page.dart';

class SmoothProductCarousel extends StatefulWidget {
  const SmoothProductCarousel({
    this.containSearchCard = false,
    required this.height,
  });

  final bool containSearchCard;
  final double height;

  static const EdgeInsets carouselItemHorizontalPadding =
      EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets carouselItemInternalPadding =
      EdgeInsets.symmetric(horizontal: 2.0);
  static const double carouselViewPortFraction = 0.91;

  @override
  State<SmoothProductCarousel> createState() => _SmoothProductCarouselState();
}

class _SmoothProductCarouselState extends State<SmoothProductCarousel> {
  final CarouselController _controller = CarouselController();
  List<String> barcodes = <String>[];
  bool _returnToSearchCard = false;
  int _lastIndex = 0;

  int get _searchCardAdjustment => widget.containSearchCard ? 1 : 0;
  late ContinuousScanModel _model;

  @override
  void initState() {
    super.initState();
    _lastIndex = _searchCardAdjustment;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _model = context.watch<ContinuousScanModel>();
    barcodes = _model.getBarcodes();
    _returnToSearchCard = InheritedDataManager.of(context).showSearchCard;
    if (_controller.ready) {
      if (_returnToSearchCard && widget.containSearchCard && _lastIndex > 0) {
        _controller.animateToPage(0);
      } else if (_model.latestConsultedBarcode != null &&
          _model.latestConsultedBarcode!.isNotEmpty) {
        final int indexBarcode =
            barcodes.indexOf(_model.latestConsultedBarcode!);
        final int indexCarousel = indexBarcode + _searchCardAdjustment;
        _controller.animateToPage(indexCarousel);
      } else {
        _controller.animateToPage(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    barcodes = _model.getBarcodes();
    return CarouselSlider.builder(
      itemCount: barcodes.length + _searchCardAdjustment,
      itemBuilder: (BuildContext context, int itemIndex, int itemRealIndex) {
        return Padding(
          padding: SmoothProductCarousel.carouselItemInternalPadding,
          child: widget.containSearchCard && itemIndex == 0
              ? SearchCard(height: widget.height)
              : _getWidget(itemIndex - _searchCardAdjustment),
        );
      },
      carouselController: _controller,
      options: CarouselOptions(
        enlargeCenterPage: false,
        viewportFraction: SmoothProductCarousel.carouselViewPortFraction,
        height: widget.height,
        enableInfiniteScroll: false,
        onPageChanged: (int index, CarouselPageChangedReason reason) {
          _lastIndex = index;
          final InheritedDataManagerState inheritedDataManager =
              InheritedDataManager.of(context);
          if (inheritedDataManager.showSearchCard) {
            inheritedDataManager.resetShowSearchCard(false);
          }
          if (index > 0) {
            if (reason == CarouselPageChangedReason.manual) {
              _model.lastConsultedBarcode =
                  barcodes[index - _searchCardAdjustment];
            }
          } else if (index == 0) {
            _model.lastConsultedBarcode = null;
          }
        },
      ),
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
      return Container();
    }
    final String barcode = barcodes[index];
    switch (_model.getBarcodeState(barcode)!) {
      case ScannedProductState.FOUND:
      case ScannedProductState.CACHED:
        final Product product = _model.getProduct(barcode);
        return ScanProductCard(product);
      case ScannedProductState.LOADING:
        return SmoothProductCardLoading(barcode: barcode);
      case ScannedProductState.NOT_FOUND:
        return SmoothProductCardNotFound(
          barcode: barcode,
          callback: (String? barcodeLoaded) async {
            // Remove the "Add New Product" card. The user may have added it
            // already.
            if (barcodeLoaded == null) {
              _model.getBarcodes().remove(barcode);
            } else {
              await _model.refresh();
            }
            setState(() {});
          },
        );
      case ScannedProductState.THANKS:
        return const SmoothProductCardThanks();
      case ScannedProductState.ERROR:
        return SmoothProductCardError(barcode: barcode);
    }
  }
}

class SearchCard extends StatelessWidget {
  const SearchCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SmoothCard(
      color: Theme.of(context).colorScheme.background.withOpacity(0.85),
      elevation: 0,
      padding: SmoothProductCarousel.carouselItemHorizontalPadding,
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AutoSizeText(
              localizations.welcomeToOpenFoodFacts,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
            Text(
              localizations.searchPanelHeader,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18.0),
            ),
            SearchField(
              onFocus: () => _openSearchPage(context),
              showClearButton: false,
            ),
          ],
        ),
      ),
    );
  }

  void _openSearchPage(BuildContext context) {
    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (_) => SearchPage(),
      ),
    );
  }
}
