import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/location_map_page.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/locations/search_location_helper.dart';
import 'package:smooth_app/pages/locations/search_location_preloaded_item.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Card that displays the location for price adding.
class PriceLocationCard extends StatelessWidget {
  const PriceLocationCard({required this.onLocationChanged});

  final Function(OsmLocation location) onLocationChanged;

  @override
  Widget build(BuildContext context) {
    final PriceModel model = context.watch<PriceModel>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OsmLocation? location = model.location;

    return SmoothCardWithRoundedHeader(
      title: appLocalizations.prices_location_subtitle,
      titlePadding: const EdgeInsetsDirectional.symmetric(
        vertical: BALANCED_SPACE,
        horizontal: LARGE_SPACE,
      ),
      leading: const icons.Shopping.cart(),
      trailing: location != null
          ? Row(
              spacing: SMALL_SPACE,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SmoothCardHeaderButton(
                  tooltip: appLocalizations.owner_field_info_title,
                  circled: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<OsmLocation>(
                      builder: (BuildContext context) =>
                          LocationMapPage(location, popFirst: false),
                    ),
                  ),
                  child: const icons.Map(size: 12.0),
                ),
                SmoothCardHeaderButton(
                  tooltip: appLocalizations.owner_field_info_title,
                  circled: true,
                  onTap: () => _onTap(context),
                  child: const icons.Edit(size: 12.0),
                ),
              ],
            )
          : null,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: SMALL_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: SizedBox(
        width: double.infinity,
        child: location == null
            ? _PriceLocationCardEmptyLocation(onTap: () => _onTap(context))
            : _PriceLocationCardWithLocation(
                location: location,
                onTap: () => _onTap(context),
              ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final List<SearchLocationPreloadedItem> preloadedList =
        <SearchLocationPreloadedItem>[];
    final List<OsmLocation> locations = await DaoOsmLocation(
      localDatabase,
    ).getAll();
    if (!context.mounted) {
      return;
    }
    for (final OsmLocation osmLocation in locations) {
      preloadedList.add(
        SearchLocationPreloadedItem(osmLocation, popFirst: false),
      );
    }
    final OsmLocation? osmLocation = await Navigator.push<OsmLocation>(
      context,
      MaterialPageRoute<OsmLocation>(
        builder: (BuildContext context) => SearchPage(
          SearchLocationHelper(),
          preloadedList: preloadedList,
          autofocus: false,
          backButtonType: BackButtonType.close,
        ),
      ),
    );
    if (osmLocation == null) {
      return;
    }
    final DaoOsmLocation daoOsmLocation = DaoOsmLocation(localDatabase);
    await daoOsmLocation.put(osmLocation);

    onLocationChanged.call(osmLocation);
  }
}

class _PriceLocationCardEmptyLocation extends StatelessWidget {
  const _PriceLocationCardEmptyLocation({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothLargeButtonWithIcon(
      text: appLocalizations.prices_location_find,
      leadingIcon: const icons.Location(),
      trailingIcon: const icons.Chevron.right(size: 10.0),
      onPressed: onTap,
    );
  }
}

class _PriceLocationCardWithLocation extends StatelessWidget {
  const _PriceLocationCardWithLocation({
    required this.location,
    required this.onTap,
  });

  final OsmLocation location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: SMALL_SPACE,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  if (location.name != null)
                    TextSpan(
                      text: '${location.name}\n',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  if (location.street != null)
                    TextSpan(text: '${location.street}\n'),
                  if (location.city != null)
                    TextSpan(
                      text:
                          '${location.postcode != null ? '${location.postcode} ' : ''}${location.city ?? ''}\n',
                    ),
                  if (location.country != null)
                    TextSpan(text: location.country),
                ],
                style: DefaultTextStyle.of(context).style,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: ANGULAR_BORDER_RADIUS,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
              child: icons.Shop(color: colorScheme.onSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
