import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_count_widget.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/pages/prices/prices_list_scaffold.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// Page that displays the top prices locations with infinite scrolling.
class PricesLocationsPage extends StatefulWidget {
  const PricesLocationsPage({this.locationsResult});

  final GetLocationsResult? locationsResult;

  @override
  State<PricesLocationsPage> createState() => _PricesLocationsPageState();
}

class _PricesLocationsPageState extends State<PricesLocationsPage>
    with TraceableClientMixin {
  @override
  String get actionName => 'Opened prices_locations_page';

  late final _InfiniteScrollLocationManager _locationManager;

  @override
  void initState() {
    super.initState();
    _locationManager = _InfiniteScrollLocationManager(
      locationsResult: widget.locationsResult,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return PricesListScaffold<Location>(
      title: appLocalizations.all_search_prices_top_location_title,
      manager: _locationManager,
    );
  }
}

/// A manager for handling location data with infinite scrolling
class _InfiniteScrollLocationManager extends InfiniteScrollManager<Location> {
  _InfiniteScrollLocationManager({GetLocationsResult? locationsResult})
    : super(
        initialItems: locationsResult?.items,
        totalItems: locationsResult?.total,
        totalPages: locationsResult?.numberOfPages,
      );

  @override
  Future<void> fetchData(int pageNumber) async {
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
    final int priceCount = item.priceCount ?? 0;
    final String? title = PriceLocationWidget.getLocationTitle(item);

    Future<void> openLocationPrices() => PriceLocationWidget.showLocationPrices(
      locationId: item.locationId,
      context: context,
    );

    return PricesListCard(
      onTap: openLocationPrices,
      padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SMALL_SPACE,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SMALL_SPACE,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 2.0),
                child: icons.Location(
                  size: 20.0,
                  color: lightTheme
                      ? extension.primaryNormal
                      : extension.primaryMedium,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: VERY_SMALL_SPACE,
                  children: <Widget>[
                    if (title != null)
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    if (item.displayName != null)
                      Text(
                        item.displayName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: SMALL_SPACE,
            runSpacing: SMALL_SPACE,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              PriceCountWidget(
                count: priceCount,
                onPressed: openLocationPrices,
              ),
              if (item.userCount != null)
                _LocationStatChip(
                  iconData: PriceButton.userIconData,
                  count: item.userCount!,
                  tooltip: appLocalizations.prices_button_count_user(
                    item.userCount!,
                  ),
                ),
              if (item.productCount != null)
                _LocationStatChip(
                  iconData: PriceButton.productIconData,
                  count: item.productCount!,
                  tooltip: appLocalizations.prices_button_count_product(
                    item.productCount!,
                  ),
                ),
              if (item.proofCount != null)
                _LocationStatChip(
                  iconData: PriceButton.proofIconData,
                  count: item.proofCount!,
                  tooltip: appLocalizations.prices_button_count_proof(
                    item.proofCount!,
                  ),
                ),
            ],
          ),
        ],
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

class _LocationStatChip extends StatelessWidget {
  const _LocationStatChip({
    required this.iconData,
    required this.count,
    required this.tooltip,
  });

  final IconData iconData;
  final int count;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();
    final Color foregroundColor = lightTheme
        ? extension.primaryBlack
        : Colors.white;

    return Semantics(
      label: tooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lightTheme
                ? extension.primaryLight
                : extension.primarySemiDark,
            borderRadius: CIRCULAR_BORDER_RADIUS,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: MEDIUM_SPACE,
              vertical: SMALL_SPACE,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: VERY_SMALL_SPACE,
              children: <Widget>[
                Icon(iconData, size: 16.0, color: foregroundColor),
                Text(
                  '$count',
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
