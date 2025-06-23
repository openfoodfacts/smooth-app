import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
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
      appBar: SmoothAppBar(
        title: Text(appLocalizations.user_search_proof_title),
        subTitle: Text(dateFormat.format(widget.proof.created)),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(_getUrl(true)),
          ),
        ],
      ),
      body: Center(
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
                    child: Image.network(_getUrl(true), fit: BoxFit.contain),
                  ),
                );
              },
        ),
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
