import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Custom [ListTile] for preferences.
class UserPreferencesListTile extends StatelessWidget {
  const UserPreferencesListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.shape,
    this.selected,
    this.selectedColor,
    this.contentPadding,
    this.externalLink,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ShapeBorder? shape;
  final bool? selected;
  final bool? externalLink;
  final Color? selectedColor;
  final EdgeInsetsGeometry? contentPadding;

  /// Icon (leading or trailing) with the standard color.
  static Icon getTintedIcon(
    final IconData iconData,
    final BuildContext context,
  ) => Icon(iconData, color: Theme.of(context).iconTheme.color);

  @override
  Widget build(BuildContext context) {
    final String? titleAsText = title is Text ? (title as Text).data : null;

    final Widget child = ListTile(
      leading: leading,
      title: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.headlineMedium,
        child: title,
      ),
      selected: selected ?? false,
      selectedTileColor: selectedColor,
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: subtitle != null ? VERY_SMALL_SPACE : 2.0,
          ),
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      subtitle: subtitle,
      shape: shape,
    );

    if (titleAsText != null) {
      return Semantics(
        label: titleAsText,
        hint: externalLink == true
            ? AppLocalizations.of(
                context,
              ).user_preferences_item_accessibility_hint
            : null,
        button: true,
        excludeSemantics: true,
        child: child,
      );
    } else {
      return child;
    }
  }
}
