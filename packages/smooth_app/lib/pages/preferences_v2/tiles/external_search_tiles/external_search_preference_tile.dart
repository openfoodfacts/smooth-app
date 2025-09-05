import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

abstract class ExternalSearchPreferenceTile extends PreferenceTile {
  const ExternalSearchPreferenceTile({required super.icon}) : super(title: '');

  String buildTitle(BuildContext context, String keyword);
  String getSearchUrl(BuildContext context, String keyword);

  @override
  Widget build(BuildContext context) {
    final String? keyword = context
        .watch<PreferencesRootSearchController>()
        .query;

    return keyword != null
        ? PreferenceTile(
            icon: icon,
            title: buildTitle(context, keyword),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              LaunchUrlHelper.launchURLInWebViewOrBrowser(
                context,
                getSearchUrl(
                  context,
                  context.read<PreferencesRootSearchController>().query!,
                ),
              );
            },
          )
        : EMPTY_WIDGET;
  }
}
