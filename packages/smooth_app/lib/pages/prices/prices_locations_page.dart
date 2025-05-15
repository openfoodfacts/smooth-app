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
  final _InfiniteScrollLocationManager _locationManager =
      _InfiniteScrollLocationManager();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

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
      body: InfiniteScrollList<Location>(
        manager: _locationManager,
      ),
    );
  }
}

/// A manager for handling location data with infinite scrolling
class _InfiniteScrollLocationManager extends InfiniteScrollManager<Location> {
  @override
  Future<void> fetchData(final int pageNumber) async {
    final MaybeError<GetLocationsResult> result =
        await OpenPricesAPIClient.getLocations(
      GetLocationsParameters()
        ..pageNumber = pageNumber
        ..pageSize = 10,
    );
    if (result.isError) {
      throw result.detailError;
    }
    final GetLocationsResult value = result.value;
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
    required Location item,
  }) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final int priceCount = item.priceCount ?? 0;

    return SmoothCard(
      child: Wrap(
        spacing: VERY_SMALL_SPACE,
        children: <Widget>[
          PriceLocationWidget(item),
          PriceCountWidget(
            count: priceCount,
            onPressed: () async => PriceLocationWidget.showLocationPrices(
              locationId: item.locationId,
              context: context,
            ),
          ),
          PriceButton(
            onPressed: () {},
            title: '${item.userCount}',
            iconData: PriceButton.userIconData,
            tooltip: item.userCount == null
                ? null
                : appLocalizations.prices_button_count_user(
                    item.userCount!,
                  ),
          ),
          PriceButton(
            onPressed: () {},
            title: '${item.productCount}',
            iconData: PriceButton.productIconData,
            tooltip: item.productCount == null
                ? null
                : appLocalizations.prices_button_count_product(
                    item.productCount!,
                  ),
          ),
          PriceButton(
            onPressed: () {},
            title: '${item.proofCount}',
            iconData: PriceButton.proofIconData,
            tooltip: item.proofCount == null
                ? null
                : appLocalizations.prices_button_count_proof(
                    item.proofCount!,
                  ),
          ),
        ],
      ),
    );
  }
}
