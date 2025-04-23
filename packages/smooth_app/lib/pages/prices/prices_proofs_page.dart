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
import 'package:smooth_app/pages/prices/generic_infinite_scroll.dart';
import 'package:smooth_app/pages/prices/price_proof_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the latest proofs of the current user with infinite scrolling.
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
  static const int _columns = 3;
  static const int _rows = 5;
  static const int _pageSize = _columns * _rows;

  late final InfiniteScrollController<Proof, GetProofsParameters>
      _scrollController;
  String? _bearerToken;
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController = InfiniteScrollController<Proof, GetProofsParameters>(
      initialItems: const <Proof>[],
      fetchItems: _fetchProofs,
      onError: (dynamic error) {
        debugPrint('Error fetching proofs: $error');
      },
    );

    _gridScrollController.addListener(_scrollListener);

    _authenticate();
  }

  void _scrollListener() {
    if (_scrollController.isLoading || !_scrollController.hasMoreItems) {
      return;
    }

    final double maxScroll = _gridScrollController.position.maxScrollExtent;
    final double currentScroll = _gridScrollController.position.pixels;
    const double triggerOffset = 200.0;

    if (currentScroll > maxScroll - triggerOffset) {
      final GetProofsParameters parameters = _getProofsParameters();
      _scrollController.loadMore(parameters);
    }
  }

  GetProofsParameters _getProofsParameters() {
    return GetProofsParameters()
      ..orderBy = <OrderBy<GetProofsOrderField>>[
        const OrderBy<GetProofsOrderField>(
          field: GetProofsOrderField.created,
          ascending: false,
        ),
      ]
      ..pageSize = _pageSize;
  }

  @override
  void dispose() {
    _gridScrollController.removeListener(_scrollListener);
    _gridScrollController.dispose();
    _deleteSession();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final User user = ProductQuery.getWriteUser();
    final MaybeError<String> token =
        await OpenPricesAPIClient.getAuthenticationToken(
      username: user.userId,
      password: user.password,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    if (token.isError) {
      debugPrint('Authentication error: ${token.error}');
      return;
    }

    _bearerToken = token.value;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteSession() async {
    if (_bearerToken != null) {
      await OpenPricesAPIClient.deleteUserSession(
        uriHelper: ProductQuery.uriPricesHelper,
        bearerToken: _bearerToken!,
      );
      _bearerToken = null;
    }
  }

  Future<(List<Proof>, bool)> _fetchProofs(
      GetProofsParameters parameters, int page) async {
    try {
      if (_bearerToken == null) {
        throw 'Not authenticated yet';
      }

      final User user = ProductQuery.getWriteUser();

      final MaybeError<GetProofsResult> result =
          await OpenPricesAPIClient.getProofs(
        parameters
          ..owner = user.userId
          ..pageNumber = page,
        uriHelper: ProductQuery.uriPricesHelper,
        bearerToken: _bearerToken!,
      );

      if (result.isError) {
        throw result.error!;
      }

      final List<Proof> items = result.value.items ?? <Proof>[];
      final bool hasMore = page < (result.value.numberOfPages ?? 1);

      _scrollController.updatePaginationInfo(
        newTotalItems: result.value.total,
        newTotalPages: result.value.numberOfPages,
      );

      return (items, hasMore);
    } catch (e) {
      throw e.toString();
    }
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
      body: _bearerToken == null
          ? // Show loading while authenticating
          const Center(child: CircularProgressIndicator())
          : // Show content once authenticated
          _buildProofsContent(context, appLocalizations),
    );
  }

  Widget _buildProofsContent(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: <Widget>[
        Builder(
          builder: (BuildContext context) {
            final int totalItems = _scrollController.totalItems ?? 0;
            final int totalPages = _scrollController.totalPages ?? 1;
            final int itemCount = _scrollController.items.length;

            final String title = totalPages <= 1
                ? appLocalizations.prices_proofs_list_length_one_page(itemCount)
                : appLocalizations.prices_proofs_list_length_many_pages(
                    _pageSize,
                    totalItems,
                  );

            return SmoothCard(
              child: ListTile(
                title: Text(title),
              ),
            );
          },
        ),
        Expanded(
          child: _buildProofsGrid(context, appLocalizations),
        ),
      ],
    );
  }

  Widget _buildProofsGrid(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    if (_scrollController.items.isEmpty) {
      if (_scrollController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return Center(child: Text(appLocalizations.proofs_empty_list));
      }
    }

    return CustomScrollView(
      controller: _gridScrollController,
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final Proof proof = _scrollController.items[index];
              final double squareSize =
                  MediaQuery.of(context).size.width / _columns;

              if (proof.filePath == null) {
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
                      builder: (BuildContext context) => PriceProofPage(proof),
                    ),
                  );
                },
                child: _PriceProofImage(proof, squareSize: squareSize),
              );
            },
            childCount: _scrollController.items.length,
            addAutomaticKeepAlives: false,
          ),
        ),
        if (_scrollController.isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bearerToken != null &&
        _scrollController.items.isEmpty &&
        !_scrollController.isLoading) {
      _scrollController.loadMore(_getProofsParameters());
    }
  }
}

// Image widget for proof thumbnails
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
