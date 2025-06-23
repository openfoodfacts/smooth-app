import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
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
        title: Text(title ?? '', maxLines: 2),
        backgroundColor: AppBarTheme.of(
          context,
        ).backgroundColor?.withValues(alpha: 0.8),
      ),
      extendBodyBehindAppBar: true,
      body: FlutterMap(
        options: mapOptions,
        children: <Widget>[
          ...children,
          SafeArea(
            child: RichAttributionWidget(
              animationConfig: const ScaleRAWA(),
              alignment: Directionality.of(context) == TextDirection.ltr
                  ? AttributionAlignment.bottomRight
                  : AttributionAlignment.bottomLeft,
              showFlutterMapAttribution: false,
              attributions: <SourceAttribution>[
                TextSourceAttribution(
                  AppLocalizations.of(
                    context,
                  ).open_street_map_contributor_attribution,
                  onTap: () => LaunchUrlHelper.launchURL(
                    'https://www.openstreetmap.org/copyright',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
