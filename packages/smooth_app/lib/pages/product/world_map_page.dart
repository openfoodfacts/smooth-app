import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class WorldMapPage extends StatelessWidget {
  const WorldMapPage({
    required this.title,
    required this.mapOptions,
    required this.children,
    super.key,
  });

  final String? title;
  final MapOptions mapOptions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: AppBar(
        title: Text(title ?? ''),
        backgroundColor:
            AppBarTheme.of(context).backgroundColor?.withValues(alpha: 0.8),
      ),
      extendBodyBehindAppBar: true,
      body: FlutterMap(
        options: mapOptions,
        children: children,
      ),
    );
  }
}
