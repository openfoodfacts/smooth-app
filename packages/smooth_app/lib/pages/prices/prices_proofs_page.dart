import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
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
                              }, // PriceProofPage
                              child: _PriceProofImage(proof,
                                  squareSize: squareSize),
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

    if (token.isError) {
      return MaybeError<GetProofsResult>.error(
        error: token.error ?? 'Could not authenticate with the server',
        statusCode: token.statusCode ?? 500,
      );
    }

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

// TODO(monsieurtanuki): reuse whatever will be coded in https://github.com/openfoodfacts/smooth-app/pull/5366
class _PriceProofImage extends StatelessWidget {
  const _PriceProofImage(
    this.proof, {
    required this.squareSize,
  });

  final Proof proof;
  final double squareSize;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLocaleString());
    final String date = dateFormat.format(proof.created);
    return Stack(
      children: <Widget>[
        SmoothImage(
          width: squareSize,
          height: squareSize,
          imageProvider: NetworkImage(
            proof
                .getFileUrl(
                  uriProductHelper: ProductQuery.uriPricesHelper,
                  isThumbnail: true,
                )
                .toString(),
          ),
          rounded: false,
        ),
        SizedBox(
          width: squareSize,
          height: squareSize,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: Container(
                height: VERY_LARGE_SPACE,
                color: Colors.white.withAlpha(128),
                child: Center(
                  child: AutoSizeText(
                    date,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
