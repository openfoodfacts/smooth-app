import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A tile for preferences in the settings page.
/// It can be used to display a title, an icon, a subtitle, and a trailing widget.
/// It can also be used to handle tap events.
/// The tiles are used inside a [PreferenceCard]. It will also be displayed
/// outside of a card when the user is searching for a tile.
class PreferenceTile extends StatelessWidget {
  const PreferenceTile({
    required this.title,
    this.leading,
    this.leadingSize,
    this.icon,
    this.subtitleText,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    super.key,
  }) : assert(
         (subtitleText != null && subtitle == null) ||
             (subtitleText == null && subtitle != null) ||
             (subtitleText == null && subtitle == null),
         'Either subtitleText or subtitle must be provided, not both.',
       ),
       assert(
         leading == null || icon == null,
         'Either leading or icon must be provided.',
       );

  final Widget? leading;
  final double? leadingSize;
  final Widget? icon;
  final String title;
  final String? subtitleText;
  final Widget? subtitle;
  final Widget? trailing;
  final Function()? onTap;
  final EdgeInsetsDirectional? padding;

  String get keywords =>
      '${title.toLowerCase()} ${subtitleText?.toLowerCase() ?? ''}';

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    final Color iconColor = context.lightTheme()
        ? extension.primarySemiDark
        : Colors.white;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: subtitle != null || subtitleText != null ? 68.0 : 61.0,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: 13.0,
            start: leading != null
                ? (leadingSize != null ? 18.0 - (leadingSize! - 21.0) : 16.0)
                : 18.0,
            end: VERY_LARGE_SPACE,
            bottom: 13.0,
          ),
          child: Row(
            children: <Widget>[
              if (leading != null || icon != null)
                SizedBox(
                  width: leading != null ? leadingSize ?? 23.0 : 21.0,
                  child: Center(
                    child: icons.AppIconTheme(
                      color: iconColor,
                      size: 21.0,
                      child: IconTheme.merge(
                        data: IconThemeData(color: iconColor),
                        child: leading != null
                            ? FittedBox(child: leading)
                            : icon!,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: LARGE_SPACE,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 1.0,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: context.lightTheme()
                              ? extension.primaryBlack
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      if (subtitle != null || subtitleText != null)
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            color: context.lightTheme()
                                ? extension.primarySemiDark.withValues(
                                    alpha: 0.7,
                                  )
                                : Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.5,
                            height: 1.3,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 1.0,
                            ),
                            child: subtitle ?? Text(subtitleText!),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ?_trailing(iconColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _trailing(Color iconColor) =>
      trailing ??
      (onTap != null
          ? icons.Chevron.right(size: 14.0, color: iconColor)
          : null);
}
