import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SmoothPopupMenuButton<T> extends StatefulWidget {
  const SmoothPopupMenuButton({
    required this.onSelected,
    required this.itemBuilder,
    this.actionsTitle,
    this.buttonIcon,
    this.buttonLabel,
  })  : assert(buttonLabel == null || buttonLabel.length > 0),
        assert(actionsTitle == null || actionsTitle.length > 0);

  final Icon? buttonIcon;
  final String? buttonLabel;
  final String? actionsTitle;
  final void Function(T value) onSelected;
  final Iterable<SmoothPopupMenuItem<T>> Function(BuildContext context)
      itemBuilder;

  @override
  State<SmoothPopupMenuButton<T>> createState() =>
      _SmoothPopupMenuButtonState<T>();
}

class _SmoothPopupMenuButtonState<T> extends State<SmoothPopupMenuButton<T>> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return IconButton(
        icon: widget.buttonIcon ?? Icon(Icons.adaptive.more),
        tooltip: widget.buttonLabel ??
            MaterialLocalizations.of(context).showMenuTooltip,
        onPressed: _openModalSheet,
      );
    } else {
      return PopupMenuButton<T>(
        icon: widget.buttonIcon ?? Icon(Icons.adaptive.more),
        tooltip: widget.buttonLabel ??
            MaterialLocalizations.of(context).showMenuTooltip,
        onSelected: widget.onSelected,
        itemBuilder: (BuildContext context) {
          return widget.itemBuilder(context).map((SmoothPopupMenuItem<T> item) {
            return PopupMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
              ),
            );
          }).toList(growable: false);
        },
      );
    }
  }

  // iOS and macOS behavior
  void _openModalSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              widget.actionsTitle ??
                  AppLocalizations.of(context).menu_button_list_actions,
            ),
            actions: widget
                .itemBuilder(context)
                .where((SmoothPopupMenuItem<T> item) => item.enabled)
                .map((SmoothPopupMenuItem<T> item) {
              return CupertinoActionSheetAction(
                isDefaultAction:
                    item.type == SmoothPopupMenuItemType.highlighted,
                isDestructiveAction:
                    item.type == SmoothPopupMenuItemType.destructive,
                onPressed: () {
                  widget.onSelected(item.value);
                  Navigator.of(context).maybePop();
                },
                child: Text(item.label),
              );
            }).toList(growable: false),
          );
        });
  }
}

class SmoothPopupMenuItem<T> {
  const SmoothPopupMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.type,
    this.enabled = true,
  }) : assert(label.length > 0);

  final T value;
  final String label;
  final IconData? icon;
  final SmoothPopupMenuItemType? type;
  final bool enabled;
}

enum SmoothPopupMenuItemType {
  normal,
  highlighted,
  destructive,
}
