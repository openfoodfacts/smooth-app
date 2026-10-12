import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';

/// SVG that looks like a ListTile icon.
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.assetName, {this.dontAddColor = false});

  final String assetName;
  final bool dontAddColor;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    assetName,
    height: DEFAULT_ICON_SIZE,
    width: DEFAULT_ICON_SIZE,
    colorFilter: dontAddColor
        ? null
        : ui.ColorFilter.mode(
            _iconColor(Theme.of(context)),
            ui.BlendMode.srcIn,
          ),
    package: AppHelper.APP_PACKAGE,
  );

  /// Returns the standard icon color in a [ListTile].
  ///
  /// Simplified version from [ListTile], which was anyway not kind enough
  /// to make it public.
  Color _iconColor(ThemeData theme) {
    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return Colors.white;
    }
  }
}
