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
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the top prices locations with infinite scrolling.
class PricesLocationsPage extends StatefulWidget {
  const PricesLocationsPage();

  @override
  State<PricesLocationsPage> createState() => _PricesLocationsPageState();
}

class _PricesLocationsPageState extends State<PricesLocationsPage>
    with TraceableClientMixin {
  static const int _pageSize = 10;
  late final InfiniteScrollController<Location, GetLocationsParameters>
      _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        InfiniteScrollController<Location, GetLocationsParameters>(
      initialItems: const <Location>[],
      fetchItems: _fetchLocations,
    );
  }

  Future<List<Location>> _fetchLocations(
      GetLocationsParameters parameters, int page) async {
    final MaybeError<GetLocationsResult> result =
        await OpenPricesAPIClient.getLocations(
      parameters..pageNumber = page,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    final List<Location> items = result.value.items ?? <Location>[];

    _scrollController.updatePaginationInfo(
      newTotalItems: result.value.total,
      newTotalPages: result.value.numberOfPages,
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final GetLocationsParameters parameters = GetLocationsParameters()
      ..orderBy = <OrderBy<GetLocationsOrderField>>[
        const OrderBy<GetLocationsOrderField>(
          field: GetLocationsOrderField.priceCount,
          ascending: false,
        ),
      ]
      ..pageSize = _pageSize;

    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          appLocalizations.all_search_prices_top_location_title,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'locations',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
          ),
        ],
      ),
      body: InfiniteScrollList<Location, GetLocationsParameters>(
        controller: _scrollController,
        parameters: parameters,
        headerBuilder: (BuildContext context) {
          final int totalItems = _scrollController.totalItems ?? 0;

          final String title =
              appLocalizations.prices_locations_list_length_many_pages(
            _pageSize,
            totalItems,
          );

          return SmoothCard(child: ListTile(title: Text(title)));
        },
        itemBuilder: (BuildContext context, Location location) {
          final int priceCount = location.priceCount ?? 0;

          return SmoothCard(
            child: Wrap(
              spacing: VERY_SMALL_SPACE,
              children: <Widget>[
                PriceLocationWidget(location),
                PriceCountWidget(
                  count: priceCount,
                  onPressed: () async => PriceLocationWidget.showLocationPrices(
                    locationId: location.locationId,
                    context: context,
                  ),
                ),
                PriceButton(
                  onPressed: () {},
                  title: '${location.userCount}',
                  iconData: PriceButton.userIconData,
                  tooltip: location.userCount == null
                      ? null
                      : appLocalizations.prices_button_count_user(
                          location.userCount!,
                        ),
                ),
                PriceButton(
                  onPressed: () {},
                  title: '${location.productCount}',
                  iconData: PriceButton.productIconData,
                  tooltip: location.productCount == null
                      ? null
                      : appLocalizations.prices_button_count_product(
                          location.productCount!,
                        ),
                ),
                PriceButton(
                  onPressed: () {},
                  title: '${location.proofCount}',
                  iconData: PriceButton.proofIconData,
                  tooltip: location.proofCount == null
                      ? null
                      : appLocalizations.prices_button_count_proof(
                          location.proofCount!,
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
