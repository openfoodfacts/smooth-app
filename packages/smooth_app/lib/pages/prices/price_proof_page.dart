import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/helpers/pinch_to_zoom_indicator.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_interactive_viewer.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Full page display of a proof.
class PriceProofPage extends StatefulWidget {
  const PriceProofPage(this.proof);

  final Proof proof;

  @override
  State<PriceProofPage> createState() => _PriceProofPageState();
}

class _PriceProofPageState extends State<PriceProofPage> {
  List<Price>? _existingPrices;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadExistingPrices());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final String title;
    if (ProductQuery.getWriteUser().userId == widget.proof.owner) {
      title = appLocalizations.user_search_proof_title;
    } else {
      title = appLocalizations.search_proof_title(widget.proof.owner);
    }

    final String url = _getUrl(false);

    final DateFormat dateFormat = DateFormat.yMd(
      ProductQuery.getLocaleString(),
    ).add_Hms();
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(title),
        subTitle: Row(
          spacing: SMALL_SPACE,
          children: <Widget>[
            const icons.Calendar(size: 12.0),
            Expanded(child: Text(dateFormat.format(widget.proof.created))),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_website_button,
            icon: const icons.ExternalLink(size: 20.0),
            onPressed: () async => LaunchUrlHelper.launchURL(url),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: SmoothInteractiveViewer(
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null ||
                            loadingProgress.cumulativeBytesLoaded ==
                                loadingProgress.expectedTotalBytes) {
                          if (!_imageLoaded) {
                            onNextFrame(
                              () => setState(() => _imageLoaded = true),
                            );
                          }

                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      },
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => Center(
                        child: PictureNotFound(
                          backgroundColor: Colors.grey[800],
                          style: PictureNotFoundStyle.sad,
                        ),
                      ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: SMALL_SPACE + MediaQuery.viewPaddingOf(context).bottom,
            start: SMALL_SPACE,
            end: SMALL_SPACE,
            child: IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  _PriceProofChildContainer(
                    backgroundColor: PriceCountWidget.getForegroundColor(
                      widget.proof.priceCount,
                    ),
                    child: _PriceProofCounter(count: widget.proof.priceCount),
                  ),
                  const Spacer(),
                  Offstage(
                    offstage: !_imageLoaded,
                    child: const _PriceProofChildContainer(
                      child: PinchToZoomExplainer(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _existingPrices == null
          ? null
          : FloatingActionButton.extended(
              label: Text(appLocalizations.prices_add_a_price),
              icon: const Icon(Icons.add),
              onPressed: () async {
                if (!await ProductRefresher().checkIfLoggedIn(
                  context,
                  isLoggedInMandatory: true,
                )) {
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ProductPriceAddPage(
                      PriceModel.proof(
                        proof: widget.proof,
                        existingPrices: _existingPrices,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getUrl(final bool isThumbnail) => widget.proof
      .getFileUrl(
        uriProductHelper: ProductQuery.uriPricesHelper,
        isThumbnail: isThumbnail,
      )
      .toString();

  Future<void> _loadExistingPrices() async {
    if (PriceModel.isProofNotGoodEnough(widget.proof)) {
      return;
    }
    final MaybeError<GetPricesResult> prices =
        await OpenPricesAPIClient.getPrices(
          GetPricesParameters()..proofId = widget.proof.id,
          uriHelper: ProductQuery.uriPricesHelper,
        );
    if (prices.isError) {
      return;
    }
    _existingPrices = prices.value.items ?? <Price>[];
    if (mounted) {
      setState(() {});
    }
  }
}

class _PriceProofCounter extends StatelessWidget {
  const _PriceProofCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: MEDIUM_SPACE,
        top: SMALL_SPACE,
        bottom: SMALL_SPACE,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10.0,
        children: <Widget>[
          const icons.PriceTag(color: Colors.white),
          Text(
            appLocalizations.prices_button_count_price(count),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// A Widget with a shared background and shape
class _PriceProofChildContainer extends StatelessWidget {
  const _PriceProofChildContainer({required this.child, this.backgroundColor});

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          (backgroundColor ??
                  context.extension<SmoothColorsThemeExtension>().primaryBlack)
              .withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(12.0),
      child: child,
    );
  }
}
