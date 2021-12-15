import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

class KnowledgePanelMap extends StatelessWidget {
  const KnowledgePanelMap(this.mapElement);

  final KnowledgePanelWorldMapElement mapElement;

  @override
  Widget build(BuildContext context) {
    if (mapElement.pointers.isEmpty || mapElement.pointers.first.geo == null) {
      return EMPTY_WIDGET;
    }
    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(mapElement.pointers.first.geo!.lat,
              mapElement.pointers.first.geo!.lng),
          zoom: 13.0,
        ),
        layers: <LayerOptions>[
          TileLayerOptions(
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
            subdomains: <String>['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: getMarkers(mapElement.pointers),
          ),
        ],
      ),
    );
  }

  List<Marker> getMarkers(List<KnowledgePanelGeoPointer> pointers) {
    final List<Marker> markers = <Marker>[];
    for (final KnowledgePanelGeoPointer pointer in pointers) {
      if (pointer.geo == null) {
        continue;
      }
      markers.add(Marker(
        point: LatLng(pointer.geo!.lat, pointer.geo!.lng),
        builder: (BuildContext ctx) => const Icon(
          Icons.pin_drop,
          color: Colors.blue,
          size: 56,
        ),
      ));
    }
    return markers;
  }
}
