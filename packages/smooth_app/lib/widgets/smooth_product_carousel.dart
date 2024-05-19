import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart' hide EMPTY_WIDGET;
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_error.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_loading.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_not_found.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_thanks.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/tagline.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_feedback_helper.dart';
import 'package:smooth_app/pages/carousel_manager.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/scan/scan_product_card_loader.dart';
import 'package:smooth_app/pages/scan/search_page.dart';
import 'package:smooth_app/services/smooth_services.dart';

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
                    ? SearchCard(height: constraints.maxHeight)
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
    final double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth -
            (SmoothBarcodeScannerVisor.CORNER_PADDING * 2) -
            (SmoothBarcodeScannerVisor.STROKE_WIDTH * 2) +
            (HORIZONTAL_SPACE_BETWEEN_CARDS * 4)) /
        screenWidth;
  }
}

class SearchCard extends StatelessWidget {
  const SearchCard({required this.height});

  final double height;

  static const double OPACITY = 0.85;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return SmoothProductBaseCard(
      backgroundColorOpacity: OPACITY,
      margin: const EdgeInsets.symmetric(
        vertical: VERY_SMALL_SPACE,
      ),
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
          const Expanded(child: _SearchCardContent()),
        ],
      ),
    );
  }
}

class _SearchCardContent extends StatefulWidget {
  const _SearchCardContent({
    Key? key,
  }) : super(key: key);

  @override
  State<_SearchCardContent> createState() => _SearchCardContentState();
}

class _SearchCardContentState extends State<_SearchCardContent>
    with AutomaticKeepAliveClientMixin {
  late _SearchCardContentType _content;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final UserPreferences preferences = context.read<UserPreferences>();
    final int scans = preferences.numberOfScans;
    if (CameraHelper.hasACamera && scans < 1) {
      _content = _SearchCardContentType.DEFAULT;
    } else if (!preferences.inAppReviewAlreadyAsked &&
        Random().nextInt(10) == 0) {
      _content = _SearchCardContentType.REVIEW_APP;
    } else {
      _content = _SearchCardContentType.TAG_LINE;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData themeData = Theme.of(context);
    final bool darkMode = themeData.brightness == Brightness.dark;

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
        child: Column(
          children: <Widget>[
            Expanded(
              child: switch (_content) {
                _SearchCardContentType.DEFAULT =>
                  const _SearchCardContentDefault(),
                _SearchCardContentType.TAG_LINE =>
                  const _SearchCardContentTagLine(),
                _SearchCardContentType.REVIEW_APP =>
                  _SearchCardContentAppReview(
                    onHideReview: () {
                      setState(() => _content = _SearchCardContentType.DEFAULT);
                    },
                  ),
              },
            ),
            if (_content != _SearchCardContentType.REVIEW_APP)
              SearchField(
                onFocus: () => _openSearchPage(context),
                readOnly: true,
                showClearButton: false,
                backgroundColor: darkMode
                    ? Colors.white10
                    : const Color.fromARGB(255, 240, 240, 240)
                        .withOpacity(SearchCard.OPACITY),
                foregroundColor: themeData.colorScheme.onSurface
                    .withOpacity(SearchCard.OPACITY),
              ),
          ],
        ),
      ),
    );
  }

  void _openSearchPage(BuildContext context) {
    AppNavigator.of(context).push(AppRoutes.SEARCH);
  }

  @override
  bool get wantKeepAlive => true;
}

enum _SearchCardContentType {
  TAG_LINE,
  REVIEW_APP,
  DEFAULT,
}

class _SearchCardContentDefault extends StatelessWidget {
  const _SearchCardContentDefault({Key? key}) : super(key: key);

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

class _SearchCardContentTagLine extends StatelessWidget {
  const _SearchCardContentTagLine();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TagLineItem?>(
      future: fetchTagLine(),
      builder: (BuildContext context, AsyncSnapshot<TagLineItem?> data) {
        if (data.data != null) {
          final TagLineItem tagLine = data.data!;
          return InkWell(
            borderRadius: ANGULAR_BORDER_RADIUS,
            onTap: tagLine.hasLink
                ? () async => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => GuideNutriscoreV2(),
                      ),
                    )
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
        } else {
          return const _SearchCardContentDefault();
        }
      },
    );
  }
}

class _SearchCardContentAppReview extends StatelessWidget {
  const _SearchCardContentAppReview({
    required this.onHideReview,
  });

  final VoidCallback onHideReview;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final UserPreferences preferences = context.read<UserPreferences>();

    return Center(
      child: OutlinedButtonTheme(
        data: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Spacer(),
            const UserPreferencesListItemDivider(
              margin: EdgeInsetsDirectional.only(
                top: MEDIUM_SPACE,
                bottom: SMALL_SPACE,
              ),
            ),
            AutoSizeText(
              localizations.tagline_app_review,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: SMALL_SPACE),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  if (await ApplicationStore.openAppReview()) {
                    await preferences.markInAppReviewAsShown();
                    onHideReview.call();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: SMALL_SPACE,
                  ),
                ),
                child: Text(
                  localizations.tagline_app_review_button_positive,
                  style: const TextStyle(fontSize: 17.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: VERY_SMALL_SPACE),
            IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        preferences.markInAppReviewAsShown();
                        await _showNegativeDialog(context, localizations);
                        onHideReview();
                      },
                      child: Text(
                        localizations.tagline_app_review_button_negative,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: VERY_SMALL_SPACE),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onHideReview(),
                      child: Text(
                        localizations.tagline_app_review_button_later,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _showNegativeDialog(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: localizations.app_review_negative_modal_title,
          body: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: SMALL_SPACE,
              end: SMALL_SPACE,
              bottom: MEDIUM_SPACE,
            ),
            child: Text(
              localizations.app_review_negative_modal_text,
              textAlign: TextAlign.center,
            ),
          ),
          positiveAction: SmoothActionButton(
            text: localizations.app_review_negative_modal_positive_button,
            onPressed: () {
              final String formLink = UserFeedbackHelper.getFeedbackFormLink();
              LaunchUrlHelper.launchURL(formLink);
              Navigator.of(context).pop();
            },
          ),
          negativeAction: SmoothActionButton(
            text: localizations.app_review_negative_modal_negative_button,
            onPressed: () => Navigator.of(context).pop(),
          ),
          actionsAxis: Axis.vertical,
        );
      },
    );
  }
}
