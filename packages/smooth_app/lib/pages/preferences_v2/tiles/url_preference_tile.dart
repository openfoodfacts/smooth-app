import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class UrlPreferenceTile extends PreferenceTile {
  const UrlPreferenceTile({
    super.leading,
    super.icon,
    required super.title,
    required this.url,
    super.subtitleText,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      leading: leading,
      icon: icon,
      title: title,
      subtitleText: subtitleText,
      trailing: const Icon(Icons.open_in_browser),
      onTap: () async =>
          LaunchUrlHelper.launchURLInWebViewOrBrowser(context, url),
    );
  }
}
