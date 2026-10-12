import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Common search app bar title.
class SearchAppBarTitle extends StatelessWidget {
  const SearchAppBarTitle({
    required this.title,
    required this.editableAppBarTitle,
    this.multiLines = true,
    super.key,
  });

  final String title;
  final bool multiLines;
  final bool editableAppBarTitle;

  @override
  Widget build(BuildContext context) {
    final Widget child = Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: multiLines ? 2 : 1,
      style: const TextStyle(fontStyle: FontStyle.italic),
    );

    if (editableAppBarTitle) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      return InkWell(
        borderRadius: ANGULAR_BORDER_RADIUS,
        onTap: () => Navigator.of(context).pop(true),
        child: Tooltip(
          message: appLocalizations.tap_to_edit_search,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: SMALL_SPACE,
            ),
            child: Opacity(
              opacity: 0.9,
              child: Row(
                children: <Widget>[
                  Expanded(child: child),
                  const icons.Edit(size: 15.0),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return child;
  }
}
