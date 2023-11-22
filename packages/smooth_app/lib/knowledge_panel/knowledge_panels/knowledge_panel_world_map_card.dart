import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class KnowledgePanelWorldMapCard extends StatelessWidget {
  const KnowledgePanelWorldMapCard(this.mapElement);

  final KnowledgePanelWorldMapElement mapElement;

  @override
  Widget build(BuildContext context) {
    if (mapElement.pointers.isEmpty || mapElement.pointers.first.geo == null) {
      return EMPTY_WIDGET;
    }
    // TODO(monsieurtanuki): Zoom the map to show all [mapElement.pointers]
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: MEDIUM_SPACE),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            // The first pointer is used as the center of the map.
            initialCenter: LatLng(
              mapElement.pointers.first.geo!.lat,
              mapElement.pointers.first.geo!.lng,
            ),
            initialZoom: 6.0,
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'org.openfoodfacts.app',
            ),
            MarkerLayer(markers: getMarkers(mapElement.pointers)),
            RichAttributionWidget(
              popupInitialDisplayDuration: const Duration(seconds: 5),
              animationConfig: const ScaleRAWA(),
              attributions: <SourceAttribution>[
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => LaunchUrlHelper.launchURL(
                    'https://www.openstreetmap.org/copyright',
                    false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> getMarkers(List<KnowledgePanelGeoPointer> pointers) {
    final List<Marker> markers = <Marker>[];
    for (final KnowledgePanelGeoPointer pointer in pointers) {
      if (pointer.geo == null) {
        continue;
      }
      markers.add(
        Marker(
          point: LatLng(pointer.geo!.lat, pointer.geo!.lng),
          child: const Icon(
            Icons.pin_drop,
            color: Colors.lightBlue,
          ),
        ),
      );
    }
    return markers;
  }
}
