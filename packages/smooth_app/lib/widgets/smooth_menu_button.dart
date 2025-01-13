import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';

/// A Button similar to a [PopupMenuButton] for non Apple platforms.
/// On iOS and macOS, it's still an [IconButton], but that opens a
/// [CupertinoActionSheet].
class SmoothPopupMenuButton<T> extends StatefulWidget {
  const SmoothPopupMenuButton({
    required this.onSelected,
    required this.itemBuilder,
    this.actionsTitle,
    this.buttonIcon,
    this.buttonLabel,
  })  : assert(buttonLabel == null || buttonLabel.length > 0),
        assert(actionsTitle == null || actionsTitle.length > 0);

  final void Function(T value) onSelected;
  final Iterable<SmoothPopupMenuItem<T>> Function(BuildContext context)
      itemBuilder;
  final String? actionsTitle;
  final Icon? buttonIcon;
  final String? buttonLabel;

  @override
  State<SmoothPopupMenuButton<T>> createState() =>
      _SmoothPopupMenuButtonState<T>();
}

class _SmoothPopupMenuButtonState<T> extends State<SmoothPopupMenuButton<T>> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.buttonIcon ?? Icon(Icons.adaptive.more),
      tooltip: widget.buttonLabel ??
          MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: _openModalSheet,
    );
  }

  void _openModalSheet() {
    showSmoothModalSheet(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        final Iterable<SmoothPopupMenuItem<T>> list = widget
            .itemBuilder(context)
            .where((SmoothPopupMenuItem<T> item) => item.enabled);

        return SmoothModalSheet(
          title: widget.actionsTitle ??
              AppLocalizations.of(context).menu_button_list_actions,
          prefixIndicator: true,
          bodyPadding: EdgeInsets.zero,
          body: ListView.separated(
            padding: EdgeInsetsDirectional.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
            ),
            itemCount: widget.itemBuilder(context).length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final SmoothPopupMenuItem<T> item = list.elementAt(index);

              return ListTile(
                leading: item.icon != null ? Icon(item.icon) : null,
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onSelected(item.value);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        );
      },
    );
  }
}

class SmoothPopupMenuItem<T> {
  const SmoothPopupMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  }) : assert(label.length > 0);

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}
