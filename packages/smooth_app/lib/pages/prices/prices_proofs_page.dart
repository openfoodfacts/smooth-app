import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/price_proof_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the latest proofs of the current user.
class PricesProofsPage extends StatefulWidget {
  const PricesProofsPage({
    required this.selectProof,
  });

  /// Do we want to select a proof (true), or just to see its details (false)?
  final bool selectProof;

  @override
  State<PricesProofsPage> createState() => _PricesProofsPageState();
}

class _PricesProofsPageState extends State<PricesProofsPage>
    with TraceableClientMixin {
  late final Future<MaybeError<GetProofsResult>> _results = _download();

  static const int _columns = 3;
  static const int _rows = 5;
  static const int _pageSize = _columns * _rows;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          appLocalizations.user_search_proofs_title,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'dashboard/proofs',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<MaybeError<GetProofsResult>>(
        future: _results,
        builder: (
          final BuildContext context,
          final AsyncSnapshot<MaybeError<GetProofsResult>> snapshot,
        ) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error!.toString());
          }
          // highly improbable
          if (!snapshot.hasData) {
            return const Text('no data');
          }
          if (snapshot.data!.isError) {
            return Text(snapshot.data!.error!);
          }
          final GetProofsResult result = snapshot.data!.value;
          // highly improbable
          if (result.items == null) {
            return const Text('empty list');
          }
          final double squareSize = MediaQuery.sizeOf(context).width / _columns;

          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          final String title = result.numberOfPages == 1
              ? appLocalizations.prices_proofs_list_length_one_page(
                  result.items!.length,
                )
              : appLocalizations.prices_proofs_list_length_many_pages(
                  _pageSize,
                  result.total!,
                );
          return Column(
            children: <Widget>[
              SmoothCard(
                child: ListTile(
                  title: Text(title),
                ),
              ),
              if (result.items!.isNotEmpty)
                Expanded(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _columns,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (
                            final BuildContext context,
                            final int index,
                          ) {
                            final Proof proof = result.items![index];
                            if (proof.filePath == null) {
                              // highly improbable
                              return SizedBox(
                                width: squareSize,
                                height: squareSize,
                              );
                            }
                            return InkWell(
                              onTap: () async {
                                if (widget.selectProof) {
                                  Navigator.of(context).pop(proof);
                                  return;
                                }
                                return Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        PriceProofPage(
                                      proof,
                                    ),
                                  ),
                                );
                              },
                              child: _PriceProofImage(
                                proof: proof,
                                onTap: () async {
                                  if (widget.selectProof) {
                                    Navigator.of(context).pop(proof);
                                    return;
                                  }
                                  return Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          PriceProofPage(
                                        proof,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          addAutomaticKeepAlives: false,
                          childCount: result.items!.length,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static Future<MaybeError<GetProofsResult>> _download() async {
    final User user = ProductQuery.getWriteUser();
    final MaybeError<String> token =
        await OpenPricesAPIClient.getAuthenticationToken(
      username: user.userId,
      password: user.password,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    final String bearerToken = token.value;

    final MaybeError<GetProofsResult> result =
        await OpenPricesAPIClient.getProofs(
      GetProofsParameters()
        ..orderBy = <OrderBy<GetProofsOrderField>>[
          const OrderBy<GetProofsOrderField>(
            field: GetProofsOrderField.created,
            ascending: false,
          ),
        ]
        ..owner = user.userId
        ..pageSize = _pageSize
        ..pageNumber = 1,
      uriHelper: ProductQuery.uriPricesHelper,
      bearerToken: bearerToken,
    );

    await OpenPricesAPIClient.deleteUserSession(
      uriHelper: ProductQuery.uriPricesHelper,
      bearerToken: bearerToken,
    );

    return result;
  }
}

/// Enhanced version of PriceProofImage with price badge
class _PriceProofImage extends StatefulWidget {
  const _PriceProofImage({
    required this.proof,
    required this.onTap,
  });

  final Proof proof;
  final VoidCallback onTap;

  @override
  State<_PriceProofImage> createState() => _PriceProofImageState();
}

class _PriceProofImageState extends State<_PriceProofImage> {
  List<Price>? _prices;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPrices());
  }

  Future<void> _loadPrices() async {
    if (PriceModel.isProofNotGoodEnough(widget.proof)) {
      return;
    }
    final MaybeError<GetPricesResult> prices =
        await OpenPricesAPIClient.getPrices(
      GetPricesParameters()..proofId = widget.proof.id,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    if (!mounted) {
      return;
    }

    if (prices.isError) {
      return;
    }

    _prices = prices.value.items ?? <Price>[];
    if (mounted) {
      setState(() {});
    }
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
          if (_prices != null)
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
