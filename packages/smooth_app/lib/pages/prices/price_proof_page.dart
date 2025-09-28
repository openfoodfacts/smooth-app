import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
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

  @override
  void initState() {
    super.initState();
    unawaited(_loadExistingPrices());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat = DateFormat.yMd(
      ProductQuery.getLocaleString(),
    ).add_Hms();
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(appLocalizations.user_search_proof_title),
        subTitle: Text(dateFormat.format(widget.proof.created)),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_website_button,
            icon: const icons.ExternalLink(size: 20.0),
            onPressed: () async => LaunchUrlHelper.launchURL(_getUrl(true)),
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
                  _getUrl(false),
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: SizedBox(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            child: Image.network(
                              _getUrl(true),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: _PriceProofCounter(count: widget.proof.priceCount),
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
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: extension.primaryBlack.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12.0),
        ),
      ),
      child: Padding(
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
      ),
    );
  }
}
