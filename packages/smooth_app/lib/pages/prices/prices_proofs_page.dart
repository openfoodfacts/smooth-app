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
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
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
  late final _InfiniteScrollProofManager _proofManager =
      _InfiniteScrollProofManager(
    selectProof: widget.selectProof,
  );

  @override
  void dispose() {
    _proofManager.dispose();
    super.dispose();
  }

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
      body: InfiniteScrollList<Proof>(
        manager: _proofManager,
      ),
    );
  }
}

/// A manager for handling proof data with infinite scrolling
class _InfiniteScrollProofManager extends InfiniteScrollManager<Proof> {
  _InfiniteScrollProofManager({
    required this.selectProof,
  });

  static const int _pageSize = 10;
  final bool selectProof;
  String? _bearerToken;

  @override
  Future<void> fetchInit() async {
    final User user = ProductQuery.getWriteUser();
    final MaybeError<String> token =
        await OpenPricesAPIClient.getAuthenticationToken(
      username: user.userId,
      password: user.password,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    if (token.isError) {
      throw Exception(token.error ?? 'Could not authenticate with the server');
    }

    _bearerToken = token.value;
  }

  @override
  Future<void> fetchData(final int pageNumber) async {
    if (_bearerToken == null) {
      await fetchInit();
    }

    final User user = ProductQuery.getWriteUser();
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
        ..pageNumber = pageNumber,
      uriHelper: ProductQuery.uriPricesHelper,
      bearerToken: _bearerToken!,
    );

    if (result.isError) {
      throw Exception(result.error ?? 'Failed to fetch proofs');
    }

    final GetProofsResult value = result.value;
    updateItems(
      newItems: value.items,
      pageNumber: value.pageNumber,
      totalItems: value.total,
      totalPages: value.numberOfPages,
    );
  }

  /// Properly dispose of the session when the manager is no longer needed
  void dispose() {
    if (_bearerToken != null) {
      OpenPricesAPIClient.deleteUserSession(
        uriHelper: ProductQuery.uriPricesHelper,
        bearerToken: _bearerToken!,
      );
    }
  }

  @override
  Widget buildItem({
    required BuildContext context,
    required Proof item,
  }) {
    if (item.filePath == null) {
      return const SizedBox.shrink();
    }

    return SmoothCard(
      child: InkWell(
        onTap: () async {
          if (selectProof) {
            Navigator.of(context).pop(item);
            return;
          }
          return Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => PriceProofPage(item),
            ),
          );
        },
        child: _PriceProofListItem(item),
      ),
    );
  }
}

class _PriceProofListItem extends StatelessWidget {
  const _PriceProofListItem(this.proof);

  final Proof proof;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat =
        DateFormat.yMd(ProductQuery.getLocaleString());
    final String date = dateFormat.format(proof.date ?? proof.created);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageSize = screenWidth * 0.3;

    return Padding(
      padding: const EdgeInsets.all(SMALL_SPACE),
      child: Row(
        children: <Widget>[
          SmoothImage(
            width: imageSize,
            height: imageSize,
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
          const SizedBox(width: MEDIUM_SPACE),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  date,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
