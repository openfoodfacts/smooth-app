import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Full page display of a proof.
class PriceProofPage extends StatefulWidget {
  const PriceProofPage(
    this.proof,
  );

  final Proof proof;

  @override
  State<PriceProofPage> createState() => _PriceProofPageState();
}

class _PriceProofPageState extends State<PriceProofPage> {
  List<Price>? _existingPrices;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadExistingPrices());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLocaleString()).add_Hms();
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
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.network(
              _getUrl(false),
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
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
          // Display price count badge on the detail screen
          if (!_isLoading && _existingPrices != null)
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.payments_outlined,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${_existingPrices!.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final MaybeError<GetPricesResult> prices =
        await OpenPricesAPIClient.getPrices(
      GetPricesParameters()..proofId = widget.proof.id,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    if (prices.isError) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _existingPrices = prices.value.items ?? <Price>[];
      _isLoading = false;
    });
  }
}

/// Widget to display a grid of proofs with price count badges
class ProofGridItem extends StatefulWidget {
  const ProofGridItem({
    super.key,
    required this.proof,
    required this.onTap,
  });

  final Proof proof;
  final VoidCallback onTap;

  @override
  State<ProofGridItem> createState() => _ProofGridItemState();
}

class _ProofGridItemState extends State<ProofGridItem> {
  List<Price>? _prices;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPrices());
  }

  Future<void> _loadPrices() async {
    if (PriceModel.isProofNotGoodEnough(widget.proof)) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final MaybeError<GetPricesResult> prices =
        await OpenPricesAPIClient.getPrices(
      GetPricesParameters()..proofId = widget.proof.id,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    if (prices.isError) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _prices = prices.value.items ?? <Price>[];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLocaleString());
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Image.network(
                  widget.proof
                      .getFileUrl(
                        uriProductHelper: ProductQuery.uriPricesHelper,
                        isThumbnail: true,
                      )
                      .toString(),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                width: double.infinity,
                child: Text(
                  dateFormat.format(widget.proof.created),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (!_isLoading && _prices != null)
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${_prices!.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
