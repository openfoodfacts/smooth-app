import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class KnowledgePanelWorldMapCard extends StatelessWidget {
  const KnowledgePanelWorldMapCard(this.mapElement);

  final KnowledgePanelWorldMapElement mapElement;

  @override
  Widget build(BuildContext context) {
    if (mapElement.pointers.isEmpty || mapElement.pointers.first.geo == null) {
      return EMPTY_WIDGET;
    }
    // TODO(monsieurtanuki): Zoom the map to show all [mapElement.pointers]
    // TODO(monsieurtanuki): Add a OSM copyright.
    return Padding(
      padding: const EdgeInsets.only(bottom: MEDIUM_SPACE),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            // The first pointer is used as the center of the map.
            center: LatLng(
              mapElement.pointers.first.geo!.lat,
              mapElement.pointers.first.geo!.lng,
            ),
            zoom: 6.0,
          ),
          layers: <LayerOptions>[
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: <String>['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: getMarkers(mapElement.pointers),
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
          builder: (BuildContext ctx) => const Icon(
            Icons.pin_drop,
            color: Colors.lightBlue,
          ),
        ),
      );
    }
    return markers;
  }
}
