import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the top prices locations.
class PricesLocationsPage extends StatefulWidget {
  const PricesLocationsPage();

  @override
  State<PricesLocationsPage> createState() => _PricesLocationsPageState();
}

class _PricesLocationsPageState extends State<PricesLocationsPage>
    with TraceableClientMixin {
  late final Future<MaybeError<GetLocationsResult>> _locations =
      _showTopLocations();

  // In this specific page, let's never try to go beyond the top 10.
  // cf. https://github.com/openfoodfacts/smooth-app/pull/5383#issuecomment-2171117141
  static const int _pageSize = 10;

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
      body: FutureBuilder<MaybeError<GetLocationsResult>>(
        future: _locations,
        builder: (
          final BuildContext context,
          final AsyncSnapshot<MaybeError<GetLocationsResult>> snapshot,
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
          final GetLocationsResult result = snapshot.data!.value;
          // highly improbable
          if (result.items == null) {
            return const Text('empty list');
          }
          final List<Widget> children = <Widget>[];
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);

          for (final Location item in result.items!) {
            final int priceCount = item.priceCount ?? 0;
            children.add(
              SmoothCard(
                child: Wrap(
                  spacing: VERY_SMALL_SPACE,
                  children: <Widget>[
                    PriceLocationWidget(item),
                    PriceCountWidget(
                      count: priceCount,
                      onPressed: () async =>
                          PriceLocationWidget.showLocationPrices(
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
              ),
            );
          }
          final String title =
              appLocalizations.prices_locations_list_length_many_pages(
            _pageSize,
            result.total!,
          );
          children.insert(
            0,
            SmoothCard(child: ListTile(title: Text(title))),
          );
          // so that the last content gets not hidden by the FAB
          children.add(
            const SizedBox(height: 2 * MINIMUM_TOUCH_SIZE),
          );
          return ListView(
            children: children,
          );
        },
      ),
    );
  }

  static Future<MaybeError<GetLocationsResult>> _showTopLocations() async =>
      OpenPricesAPIClient.getLocations(
        GetLocationsParameters()
          ..orderBy = <OrderBy<GetLocationsOrderField>>[
            const OrderBy<GetLocationsOrderField>(
              field: GetLocationsOrderField.priceCount,
              ascending: false,
            ),
          ]
          ..pageSize = _pageSize
          ..pageNumber = 1,
        uriHelper: ProductQuery.uriPricesHelper,
      );
}
