import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/prices/price_data_entry.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:vector_graphics/vector_graphics.dart';

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
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothScaffold(
      backgroundColor: lightTheme ? extension.primaryLight : null,
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(appLocalizations.all_search_prices_top_location_title),
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
      body: InfiniteScrollList<Location>(manager: _locationManager),
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
            ..orderBy = const <OrderBy<GetLocationsOrderField>>[
              OrderBy<GetLocationsOrderField>(
                field: GetLocationsOrderField.priceCount,
                ascending: false,
              ),
              OrderBy<GetLocationsOrderField>(
                field: GetLocationsOrderField.created,
                ascending: false,
              ),
            ]
            ..pageNumber = pageNumber
            ..pageSize = 10,
          uriHelper: ProductQuery.uriPricesHelper,
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
  Widget buildItem({required BuildContext context, required Location item}) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final bool hasMetadata =
        item.userCount != null ||
        item.productCount != null ||
        item.proofCount != null;

    return SmoothCard(
      elevation: 5.0,
      elevationColor: Colors.black26,
      margin: const EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        start: 8.0,
        end: 8.0,
      ),
      padding: EdgeInsetsDirectional.zero,
      color: lightTheme ? null : extension.primaryUltraBlack,
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: () async => PriceLocationWidget.showLocationPrices(
          locationId: item.locationId,
          context: context,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PriceLocationWidget(item),
              if (hasMetadata)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: lightTheme
                        ? extension.primaryBlack
                        : extension.primaryLight,
                    fontSize: 15.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: SMALL_SPACE,
                      end: SMALL_SPACE,
                      top: SMALL_SPACE,
                      bottom: VERY_SMALL_SPACE,
                    ),
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: lightTheme
                            ? extension.primaryNormal
                            : extension.primaryMedium,
                      ),
                      child: Column(
                        spacing: SMALL_SPACE,
                        children: <Widget>[
                          if (item.userCount != null)
                            PriceDataEntry(
                              icon: const icons.Profile(size: 19.0),
                              label: appLocalizations.prices_button_count_user(
                                item.userCount!,
                              ),
                            ),
                          if (item.productCount != null)
                            PriceDataEntry(
                              icon: const icons.Milk.happy(size: 19.0),
                              label: appLocalizations
                                  .prices_button_count_product(
                                    item.productCount!,
                                  ),
                            ),
                          if (item.proofCount != null)
                            PriceDataEntry(
                              icon: const icons.PriceReceipt(size: 19.0),
                              label: appLocalizations.prices_button_count_proof(
                                item.proofCount!,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  String formattedItemCount(
    BuildContext context,
    int loadedItems,
    int? totalItems,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return totalItems != null
        ? appLocalizations.prices_locations_count_with_total(
            loadedItems,
            totalItems,
          )
        : appLocalizations.prices_locations_count(loadedItems);
  }

  @override
  Widget get emptyListIcon =>
      const SvgPicture(AssetBytesLoader('assets/icons/location_empty.svg.vec'));

  @override
  String emptyListTitle(AppLocalizations appLocalizations) =>
      appLocalizations.prices_locations_empty_title;

  @override
  String emptyListExplanation(AppLocalizations appLocalizations) =>
      appLocalizations.prices_locations_empty_explanation;
}
