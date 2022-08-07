import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_error.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/tagline.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/scan/scan_product_card_loader.dart';
import 'package:smooth_app/pages/scan/search_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SmoothProductCarousel extends StatefulWidget {
  const SmoothProductCarousel({
    this.containSearchCard = false,
  });

  final bool containSearchCard;

  static const EdgeInsetsGeometry carouselItemHorizontalPadding =
      EdgeInsetsDirectional.only(
    top: LARGE_SPACE,
    start: VERY_LARGE_SPACE,
    end: VERY_LARGE_SPACE,
    bottom: VERY_LARGE_SPACE,
  );
  static const EdgeInsetsGeometry carouselItemInternalPadding =
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
    final int cardsCount = barcodes.length + _searchCardAdjustment;
    if (_controller.ready) {
      if (_returnToSearchCard && widget.containSearchCard && _lastIndex > 0) {
        _controller.animateToPage(0);
      } else if (_model.latestConsultedBarcode != null &&
          _model.latestConsultedBarcode!.isNotEmpty) {
        final int indexBarcode =
            barcodes.indexOf(_model.latestConsultedBarcode!);
        if (indexBarcode >= 0) {
          final int indexCarousel = indexBarcode + _searchCardAdjustment;
          _controller.animateToPage(indexCarousel);
        } else {
          if (_lastIndex > cardsCount) {
            _controller.animateToPage(cardsCount);
          } else {
            _controller.animateToPage(_lastIndex);
          }
        }
      } else {
        _controller.animateToPage(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    barcodes = _model.getBarcodes();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CarouselSlider.builder(
          itemCount: barcodes.length + _searchCardAdjustment,
          itemBuilder:
              (BuildContext context, int itemIndex, int itemRealIndex) {
            return Padding(
              padding: SmoothProductCarousel.carouselItemInternalPadding,
              child: widget.containSearchCard && itemIndex == 0
                  ? SearchCard(height: constraints.maxHeight)
                  : _getWidget(itemIndex - _searchCardAdjustment),
            );
          },
          carouselController: _controller,
          options: CarouselOptions(
            enlargeCenterPage: false,
            viewportFraction: SmoothProductCarousel.carouselViewPortFraction,
            height: constraints.maxHeight,
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
      return Container();
    }
    final String barcode = barcodes[index];
    switch (_model.getBarcodeState(barcode)!) {
      case ScannedProductState.FOUND:
      case ScannedProductState.CACHED:
        return ScanProductCardLoader(barcode);
      case ScannedProductState.LOADING:
        return SmoothProductCardLoading(barcode: barcode);
      case ScannedProductState.NOT_FOUND:
        return SmoothProductCardNotFound(
          barcode: barcode,
          callback: (String? barcodeLoaded) async {
            if (barcodeLoaded != null) {
              await _model.refresh();
            }
            setState(() {});
          },
        );
      case ScannedProductState.THANKS:
        return const SmoothProductCardThanks();
      case ScannedProductState.ERROR_INTERNET:
        return SmoothProductCardError(
          barcode: barcode,
          errorType: ScannedProductState.ERROR_INTERNET,
        );
      case ScannedProductState.ERROR_INVALID_CODE:
        return SmoothProductCardError(
          barcode: barcode,
          errorType: ScannedProductState.ERROR_INVALID_CODE,
        );
    }
  }
}

class SearchCard extends StatelessWidget {
  const SearchCard({required this.height});

  final double height;

  static const double OPACITY = 0.85;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final bool isDarkmode = themeData.brightness == Brightness.dark;
    return SmoothCard(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white.withOpacity(OPACITY)
          : Colors.black.withOpacity(OPACITY),
      elevation: 0,
      padding: SmoothProductCarousel.carouselItemHorizontalPadding,
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SvgPicture.asset(
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/app/release_icon_light_transparent_no_border.svg'
                  : 'assets/app/release_icon_dark_transparent_no_border.svg',
              width: height * 0.2,
              height: height * 0.2,
            ),
            AutoSizeText(
              localizations.welcomeToOpenFoodFacts,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
              maxLines: 2,
            ),
            SizedBox(
              height: height * 0.05,
            ),
            const Expanded(
              child: _SearchCardTagLine(),
            ),
            SearchField(
              onFocus: () => _openSearchPage(context),
              readOnly: true,
              showClearButton: false,
              backgroundColor: isDarkmode
                  ? Colors.white10
                  : const Color.fromARGB(255, 240, 240, 240)
                      .withOpacity(OPACITY),
              foregroundColor:
                  themeData.colorScheme.onSurface.withOpacity(OPACITY),
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

/// Text between "Welcome on OFF" and the search button
/// Until the first scan, a generic message is displayed via
/// [_SearchCardTagLineDefaultText]
///
/// After that initial scan, the tagline will displayed if possible,
/// or [_SearchCardTagLineDefaultText] in all cases (loading, error…)
class _SearchCardTagLine extends StatelessWidget {
  const _SearchCardTagLine({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VERY_SMALL_SPACE),
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: LARGE_SPACE,
          height: 1.22,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 5,
        child: Consumer<UserPreferences>(
          builder: (BuildContext context, UserPreferences preferences, _) {
            if (preferences.isFirstScan) {
              return const _SearchCardTagLineDefaultText();
            }

            return FutureBuilder<TagLineItem?>(
              future: fetchTagLine(Platform.localeName),
              builder:
                  (BuildContext context, AsyncSnapshot<TagLineItem?> data) {
                if (data.data == null) {
                  return const _SearchCardTagLineDefaultText();
                } else {
                  return InkWell(
                    borderRadius: ANGULAR_BORDER_RADIUS,
                    onTap: data.data!.hasLink
                        ? () async {
                            if (await canLaunchUrlString(data.data!.url)) {
                              await launchUrl(
                                Uri.parse(data.data!.url),
                                // forms.gle links are not handled by the WebView
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }
                        : null,
                    child: AutoSizeText(
                      data.data!.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _SearchCardTagLineDefaultText extends StatelessWidget {
  const _SearchCardTagLineDefaultText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: AutoSizeText(
        localizations.searchPanelHeader,
      ),
    );
  }
}
