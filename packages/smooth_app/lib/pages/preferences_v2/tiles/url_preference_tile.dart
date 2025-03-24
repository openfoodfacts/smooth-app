import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class UrlPreferenceTile extends PreferenceTile {
  UrlPreferenceTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.open_in_browser),
      onTap: () {
        LaunchUrlHelper.launchURLInWebViewOrBrowser(
          context,
          url,
        );
      },
    );
  }

  @override
  String get keywords =>
      '${title.toLowerCase()} ${subtitle?.toLowerCase() ?? ''}';
}
