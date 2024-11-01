import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays a map centered on a location.
class LocationMapPage extends StatelessWidget {
  const LocationMapPage(
    this.osmLocation, {
    required this.popFirst,
  });

  final OsmLocation osmLocation;
  final bool popFirst;

  @override
  Widget build(BuildContext context) {
    const double markerSize = 50;
    final LatLng latLng = osmLocation.getLatLng();
    final String? title = osmLocation.getTitle();
    final String? subtitle = osmLocation.getSubtitle();
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: title == null ? null : Text(title),
        subTitle: subtitle == null
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => showCupertinoModalPopup<void>(
              context: context,
              builder: (final BuildContext context) => CupertinoActionSheet(
                actions: <Widget>[
                  if (osmLocation.name != null)
                    _getItem(context, osmLocation.name!, 'Name'),
                  if (osmLocation.street != null)
                    _getItem(context, osmLocation.street!, 'Street'),
                  if (osmLocation.city != null)
                    _getItem(context, osmLocation.city!, 'City'),
                  if (osmLocation.postcode != null)
                    _getItem(context, osmLocation.postcode!, 'Postcode'),
                  if (osmLocation.country != null)
                    _getItem(context, osmLocation.country!, 'Country'),
                  _getItem(
                    context,
                    '${osmLocation.latitude}, ${osmLocation.longitude}',
                    'Coordinates',
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // pops that map page
              Navigator.of(context).pop();
              if (popFirst) {
                // pops the result page
                Navigator.of(context).pop();
              }
              // returns the result
              Navigator.of(context).pop(osmLocation);
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: latLng,
          initialZoom: 17,
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'org.openfoodfacts.app',
          ),
          MarkerLayer(
            markers: <Marker>[
              Marker(
                point: latLng,
                child: const Icon(
                  Icons.pin_drop,
                  color: Colors.lightBlue,
                  size: markerSize,
                ),
                alignment: Alignment.topCenter,
                width: markerSize,
                height: markerSize,
              ),
            ],
          ),
          RichAttributionWidget(
            popupInitialDisplayDuration: const Duration(seconds: 5),
            animationConfig: const ScaleRAWA(),
            attributions: <SourceAttribution>[
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => LaunchUrlHelper.launchURL(
                  'https://www.openstreetmap.org/copyright',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getItem(
    final BuildContext context,
    final String value,
    final String label,
  ) =>
      CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('$label: $value'),
      );
}
