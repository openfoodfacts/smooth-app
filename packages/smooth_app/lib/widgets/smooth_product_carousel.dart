import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_error.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/tagline.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/inherited_data_manager.dart';
import 'package:smooth_app/pages/scan/scan_product_card_loader.dart';
import 'package:smooth_app/pages/scan/search_page.dart';
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
      return EMPTY_WIDGET;
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
          callback: () async {
            await _model.refresh();
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

    return SmoothProductBaseCard(
      backgroundColorOpacity: OPACITY,
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
            package: AppHelper.APP_PACKAGE,
          ),
          Padding(
            padding: const EdgeInsets.only(top: MEDIUM_SPACE),
            child: AutoSizeText(
              localizations.welcomeToOpenFoodFacts,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                height: 1.00,
              ),
              maxLines: 1,
            ),
          ),
          const Expanded(child: _SearchCardTagLine()),
          SearchField(
            onFocus: () => _openSearchPage(context),
            readOnly: true,
            showClearButton: false,
            backgroundColor: isDarkmode
                ? Colors.white10
                : const Color.fromARGB(255, 240, 240, 240).withOpacity(OPACITY),
            foregroundColor:
                themeData.colorScheme.onSurface.withOpacity(OPACITY),
          ),
        ],
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
///
/// Shows a warning instead of the TagLine if the app identifier is not the one
/// from the official listing.
class _SearchCardTagLine extends StatefulWidget {
  const _SearchCardTagLine({
    Key? key,
  }) : super(key: key);

  static const String DEPRECATED_KEY = 'deprecated';
  static const String TAG_LINE_KEY = 'tagline';

  @override
  State<_SearchCardTagLine> createState() => _SearchCardTagLineState();
}

class _SearchCardTagLineState extends State<_SearchCardTagLine> {
  late Future<Map<String, dynamic>> _initTagLineData;
  @override
  void initState() {
    super.initState();
    _initTagLineData = _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final UserPreferences preferences = context.watch<UserPreferences>();
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
        child: preferences.isFirstScan
            ? const _SearchCardTagLineDefaultText()
            : FutureBuilder<Map<String, dynamic>>(
                future: _initTagLineData,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> data) {
                  if (data.connectionState != ConnectionState.done ||
                      data.data == null ||
                      !data.hasData) {
                    return const _SearchCardTagLineDefaultText();
                  }

                  if (data.data![_SearchCardTagLine.DEPRECATED_KEY] as bool) {
                    return const _SearchCardTagLineDeprecatedAppText();
                  }

                  if (data.data![_SearchCardTagLine.TAG_LINE_KEY] != null) {
                    return _SearchCardTagLineText(
                      tagLine: data.data![_SearchCardTagLine.TAG_LINE_KEY]
                          as TagLineItem,
                    );
                  }
                  return const _SearchCardTagLineDefaultText();
                },
              ),
      ),
    );
  }

  /// We fetch first if the app is deprecated, then try to get the tagline
  /// Return a map with keys: [_SearchCardTagLine.DEPRECATED_KEY]<bool> & [_SearchCardTagLine.TAG_LINE_KEY]<TagLineItem?>
  Future<Map<String, dynamic>> _fetchData() async {
    final bool deprecated = await _isApplicationDeprecated();
    final TagLineItem? item = await fetchTagLine();

    return <String, dynamic>{
      _SearchCardTagLine.DEPRECATED_KEY: deprecated,
      _SearchCardTagLine.TAG_LINE_KEY: item
    };
  }

  Future<bool> _isApplicationDeprecated() {
    return PackageInfo.fromPlatform().then(
      (PackageInfo value) => value.packageName != 'org.openfoodfacts.scanner',
    );
  }
}

class _SearchCardTagLineDefaultText extends StatelessWidget {
  const _SearchCardTagLineDefaultText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: AutoSizeText(
          localizations.searchPanelHeader,
        ),
      ),
    );
  }
}

class _SearchCardTagLineDeprecatedAppText extends StatelessWidget {
  const _SearchCardTagLineDeprecatedAppText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: SizedBox(
        height: 50,
        child: Column(
          children: <Widget>[
            Text(
              localizations.deprecated_header,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            Text(
              localizations.download_new_version,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            TextButton(
              onPressed: () {
                _openAppStore();
              },
              child: Text(
                localizations.click_here,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the App Store or Google Play of the production app
  Future<bool> _openAppStore() async {
    final String url;

    if (Platform.isIOS) {
      url = 'https://apps.apple.com/us/app/open-food-facts/id588797948';
    } else if (Platform.isAndroid) {
      url =
          'https://play.google.com/store/apps/details?id=org.openfoodfacts.scanner';
    } else {
      // Not supported
      return false;
    }

    return canLaunchUrlString(url).then((bool canLaunch) async {
      if (canLaunch) {
        return launchUrlString(
          url,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else {
        return false;
      }
    });
  }
}

class _SearchCardTagLineText extends StatelessWidget {
  const _SearchCardTagLineText({
    required this.tagLine,
    Key? key,
  }) : super(key: key);

  final TagLineItem tagLine;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: ANGULAR_BORDER_RADIUS,
      onTap: tagLine.hasLink
          ? () async {
              await launchUrlString(
                tagLine.url,
                // forms.gle links are not handled by the WebView
                mode: LaunchMode.externalApplication,
              );
            }
          : null,
      child: Center(
        child: AutoSizeText(
          tagLine.message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
