import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart' hide EMPTY_WIDGET;
import 'package:smooth_app/cards/product_cards/smooth_product_card_error.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/tagline/tagline_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/helpers/strings_helper.dart';
import 'package:smooth_app/pages/carousel_manager.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/scan/scan_product_card_loader.dart';
import 'package:smooth_app/pages/scan/scan_tagline.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothProductCarousel extends StatefulWidget {
  const SmoothProductCarousel({
    this.containSearchCard = false,
    this.onPageChangedTo,
  });

  final bool containSearchCard;
  final Function(int page, String? productBarcode)? onPageChangedTo;

  @override
  State<SmoothProductCarousel> createState() => _SmoothProductCarouselState();
}

class _SmoothProductCarouselState extends State<SmoothProductCarousel> {
  static const double HORIZONTAL_SPACE_BETWEEN_CARDS = 5.0;

  List<String> barcodes = <String>[];
  String? _lastConsultedBarcode;
  int? _carrouselMovingTo;
  int _lastIndex = 0;

  int get _searchCardAdjustment => widget.containSearchCard ? 1 : 0;
  late ContinuousScanModel _model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _model = context.watch<ContinuousScanModel>();

    if (!ExternalCarouselManager.read(context).controller.ready) {
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
    final int cardsCount = barcodes.length + _searchCardAdjustment;

    if (_model.latestConsultedBarcode != null &&
        _model.latestConsultedBarcode!.isNotEmpty) {
      final int indexBarcode = barcodes.indexOf(_model.latestConsultedBarcode!);
      if (indexBarcode >= 0) {
        final int indexCarousel = indexBarcode + _searchCardAdjustment;
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
        page >= _searchCardAdjustment
            ? barcodes[page - _searchCardAdjustment]
            : null,
      );

      _carrouselMovingTo = page;
      ExternalCarouselManager.read(context).animatePageTo(page);
      _carrouselMovingTo = null;
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
            return SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HORIZONTAL_SPACE_BETWEEN_CARDS,
                ),
                child: widget.containSearchCard && itemIndex == 0
                    ? const _MainCard()
                    : _getWidget(itemIndex - _searchCardAdjustment),
              ),
            );
          },
          carouselController: ExternalCarouselManager.watch(context).controller,
          options: CarouselOptions(
            enlargeCenterPage: false,
            viewportFraction: _computeViewPortFraction(),
            height: constraints.maxHeight,
            enableInfiniteScroll: false,
            onPageChanged: (int index, CarouselPageChangedReason reason) {
              _lastIndex = index;

              if (index > 0) {
                if (reason == CarouselPageChangedReason.manual) {
                  _model.lastConsultedBarcode =
                      barcodes[index - _searchCardAdjustment];
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
        return ScanProductCardLoader(barcode);
      case ScannedProductState.LOADING:
        return SmoothProductCardLoading(
          barcode: barcode,
          onRemoveProduct: (_) => _model.removeBarcode(barcode),
        );
      case ScannedProductState.NOT_FOUND:
        return SmoothProductCardNotFound(
          barcode: barcode,
          onAddProduct: () async {
            await _model.refresh();
            setState(() {});
          },
          onRemoveProduct: (_) => _model.removeBarcode(barcode),
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

class _MainCard extends StatelessWidget {
  const _MainCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ConsumerFilter<TagLineProvider>(
            buildWhen:
                (TagLineProvider? previousValue, TagLineProvider currentValue) {
              return previousValue?.hasContent != currentValue.hasContent;
            },
            builder: (BuildContext context, TagLineProvider tagLineManager, _) {
              if (!tagLineManager.hasContent) {
                return const _SearchCard(
                  expandedMode: true,
                );
              } else {
                return const Column(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: _SearchCard(
                        expandedMode: false,
                      ),
                    ),
                    SizedBox(height: MEDIUM_SPACE),
                    Expanded(
                      flex: 4,
                      child: ScanTagLine(),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.expandedMode,
  });

  /// Expanded is when this card is the only one (no tagline, no app review…)
  final bool expandedMode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();

    final Widget widget = SmoothCard(
      color: themeProvider.isLightTheme
          ? Colors.grey.withOpacity(0.1)
          : Colors.black,
      padding: const EdgeInsets.symmetric(
        vertical: MEDIUM_SPACE,
        horizontal: LARGE_SPACE,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 0.0,
        vertical: VERY_SMALL_SPACE,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SvgPicture.asset(
            Theme.of(context).brightness == Brightness.light
                ? 'assets/app/logo_text_black.svg'
                : 'assets/app/logo_text_white.svg',
            semanticsLabel: localizations.homepage_main_card_logo_description,
          ),
          FormattedText(
            text: localizations.homepage_main_card_subheading,
            textAlign: TextAlign.center,
            textStyle: const TextStyle(height: 1.3),
          ),
          const _SearchBar(),
        ],
      ),
    );

    if (expandedMode) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.4,
        ),
        child: widget,
      );
    } else {
      return widget;
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  static const double SEARCH_BAR_HEIGHT = 47.0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return SizedBox(
      height: SEARCH_BAR_HEIGHT,
      child: InkWell(
        onTap: () => AppNavigator.of(context).push(AppRoutes.SEARCH),
        borderRadius: BorderRadius.circular(30.0),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: themeProvider.isLightTheme ? Colors.white : theme.greyDark,
            border: Border.all(color: theme.primaryBlack),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 20.0,
                    end: 10.0,
                    bottom: 3.0,
                  ),
                  child: Text(
                    localizations.homepage_main_card_search_field_hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: themeProvider.isLightTheme
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Search(
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
