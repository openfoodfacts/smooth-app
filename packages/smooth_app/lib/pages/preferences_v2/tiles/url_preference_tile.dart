import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';

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
    final ThemeData theme = Theme.of(context);

    return PreferenceTile(
      leading: leading,
      icon: icon,
      title: title,
      subtitleText: subtitleText,
      trailing: icons.ExternalLink(
        size: 16.0,
        color: context.lightTheme() ? theme.primaryColor : Colors.white,
      ),
      onTap: () async =>
          LaunchUrlHelper.launchURLInWebViewOrBrowser(context, url),
    );
  }
}
