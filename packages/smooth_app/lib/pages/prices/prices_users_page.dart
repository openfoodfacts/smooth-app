import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_controller.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the top prices users with infinite scrolling.
class PricesUsersPage extends StatefulWidget {
  const PricesUsersPage();

  @override
  State<PricesUsersPage> createState() => _PricesUsersPageState();
}

class _PricesUsersPageState extends State<PricesUsersPage>
    with TraceableClientMixin {
  static const int _pageSize = 10;
  late final InfiniteScrollController<PriceUser, GetUsersParameters,
      GetUsersResult> _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        InfiniteScrollController<PriceUser, GetUsersParameters, GetUsersResult>(
      fetchResult: _fetchUsers,
      extractItems: _extractItems,
      initialItems: const <PriceUser>[],
    );
  }

  Future<GetUsersResult> _fetchUsers(GetUsersParameters parameters, int page,
      {void Function(int? totalItems, int? totalPages)?
          onPageInfoUpdated}) async {
    final MaybeError<GetUsersResult> result =
        await OpenPricesAPIClient.getUsers(
      parameters..pageNumber = page,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    if (onPageInfoUpdated != null) {
      onPageInfoUpdated(result.value.total, result.value.numberOfPages);
    }

    return result.value;
  }

  List<PriceUser> _extractItems(GetUsersResult result) {
    return result.items ?? <PriceUser>[];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final GetUsersParameters parameters = GetUsersParameters()
      ..orderBy = <OrderBy<GetUsersOrderField>>[
        const OrderBy<GetUsersOrderField>(
          field: GetUsersOrderField.priceCount,
          ascending: false,
        ),
      ]
      ..pageSize = _pageSize;

    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          appLocalizations.all_search_prices_top_user_title,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'users',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
          ),
        ],
      ),
      body: InfiniteScrollList<PriceUser, GetUsersParameters, GetUsersResult>(
        controller: _scrollController,
        parameters: parameters,
        itemBuilder: (BuildContext context, PriceUser user) {
          final int priceCount = user.priceCount ?? 0;
          return SmoothCard(
            child: Wrap(
              spacing: VERY_SMALL_SPACE,
              children: <Widget>[
                PriceUserButton(user.userId),
                PriceCountWidget(
                  count: priceCount,
                  onPressed: () async => PriceUserButton.showUserPrices(
                    user: user.userId,
                    context: context,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
