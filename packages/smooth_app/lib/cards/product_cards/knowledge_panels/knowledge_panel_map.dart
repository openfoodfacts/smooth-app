import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';

class KnowledgePanelMap extends StatelessWidget {
  const KnowledgePanelMap(this.mapElement);

  final KnowledgePanelMapElement mapElement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          bounds: LatLngBounds(LatLng(58.8, 6.1), LatLng(59, 6.2)),
          boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(8.0)),
          zoom: 8.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                point: LatLng(40.0, -120.0),
                builder: (ctx) =>
                    Icon(
                      Icons.pin_drop,
                      color: Colors.blue,
                      size: 56,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}