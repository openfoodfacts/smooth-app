import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
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
  final _InfiniteScrollUserManager _userManager = _InfiniteScrollUserManager();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

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
      body: InfiniteScrollList<PriceUser>(
        manager: _userManager,
      ),
    );
  }
}

/// A manager for handling user data with infinite scrolling
class _InfiniteScrollUserManager extends InfiniteScrollManager<PriceUser> {
  static const int _pageSize = 10;

  @override
  Future<void> fetchData(final int pageNumber) async {
    final GetUsersParameters parameters = GetUsersParameters()
      ..orderBy = <OrderBy<GetUsersOrderField>>[
        const OrderBy<GetUsersOrderField>(
          field: GetUsersOrderField.priceCount,
          ascending: false,
        ),
      ]
      ..pageSize = _pageSize
      ..pageNumber = pageNumber;

    final MaybeError<GetUsersResult> result =
        await OpenPricesAPIClient.getUsers(
      parameters,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    if (result.isError) {
      throw result.detailError;
    }

    final GetUsersResult value = result.value;
    updateItems(
      newItems: value.items,
      pageNumber: value.pageNumber,
      totalItems: value.total,
      totalPages: value.numberOfPages,
    );
  }

  @override
  Widget buildItem({
    required BuildContext context,
    required PriceUser item,
  }) {
    final int priceCount = item.priceCount ?? 0;
    return SmoothCard(
      child: Wrap(
        spacing: VERY_SMALL_SPACE,
        children: <Widget>[
          PriceUserButton(item.userId),
          PriceCountWidget(
            count: priceCount,
            onPressed: () async => PriceUserButton.showUserPrices(
              user: item.userId,
              context: context,
            ),
          ),
        ],
      ),
    );
  }
}
