import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class UrlPreferenceTile extends PreferenceTile {
  UrlPreferenceTile({
    required super.title,
    required this.url,
    super.leading,
    super.icon,
    super.subtitleText,
    super.key,
  }) : assert(url.isNotEmpty);

  final String url;

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      leading: leading,
      icon: icon,
      title: title,
      subtitleText: subtitleText,
      trailing: icons.ExternalLink(
        size: 16.0,
        color: _getIconColor(Theme.of(context)),
      ),
      onTap: () async =>
          LaunchUrlHelper.launchURLInWebViewOrBrowser(context, url),
    );
  }

  /// Returns the standard icon color for external link icons.
  ///
  /// Ensures proper visibility in both light and dark modes.
  Color _getIconColor(ThemeData theme) {
    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return Colors.white;
    }
  }
}
