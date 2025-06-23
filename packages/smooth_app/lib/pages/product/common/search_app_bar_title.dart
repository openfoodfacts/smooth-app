import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Common search app bar title.
class SearchAppBarTitle extends StatelessWidget {
  const SearchAppBarTitle({
    required this.title,
    this.multiLines = true,
    required this.editableAppBarTitle,
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
    );

    if (editableAppBarTitle) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      return InkWell(
        onTap: () => Navigator.of(context).pop(true),
        child: Tooltip(
          message: appLocalizations.tap_to_edit_search,
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
    }
    return child;
  }
}
