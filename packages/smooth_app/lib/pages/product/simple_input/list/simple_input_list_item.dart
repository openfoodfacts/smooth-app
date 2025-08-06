import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SimpleInputListItem extends StatefulWidget {
  const SimpleInputListItem({
    required this.term,
    required this.isNew,
    required this.reorderable,
    required this.editable,
    required this.position,
    required this.onChanged,
    required this.onRemoveItem,
  });

  final String term;
  final bool isNew;
  final bool reorderable;
  final bool editable;
  final int position;
  final Function(int position, String term) onChanged;
  final Function(String term, Widget child) onRemoveItem;

  @override
  State<SimpleInputListItem> createState() => _SimpleInputListItemState();
}

class _SimpleInputListItemState extends State<SimpleInputListItem> {
  late final TextEditingControllerWithHistory _controller;
  late final FocusNode _focusNode;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.editable) {
      _controller = TextEditingControllerWithHistory(text: widget.term);
      _focusNode = FocusNode()..addListener(_onFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    Widget child;
    if (widget.editable) {
      child = _getEditableItem();
    } else {
      child = _getItem();
    }

    child = ListTile(
      leading: widget.reorderable
          ? ReorderableDelayedDragStartListener(
              index: widget.position,
              child: const icons.Menu.hamburger(),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.editable) ...<Widget>[
            _SimpleInputListItemAction(
              tooltip: appLocalizations
                  .edit_product_form_item_save_edit_item_tooltip,
              icon: Icon(Icons.check_circle_rounded, color: extension.success),
              visible: _isEditing,
              onTap: _saveEdit,
            ),
            _SimpleInputListItemAction(
              tooltip: appLocalizations
                  .edit_product_form_item_cancel_edit_item_tooltip,
              icon: Icon(Icons.cancel, color: extension.error),
              visible: _isEditing,
              onTap: _cancelEdit,
            ),
          ],
          _SimpleInputListItemAction(
            tooltip:
                appLocalizations.edit_product_form_item_remove_item_tooltip,
            icon: const Icon(Icons.delete),
            onTap: () => widget.onRemoveItem(widget.term, child),
            visible: !_isEditing,
          ),
        ],
      ),
      contentPadding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: 1.5,
      ),
      minTileHeight: 48.0,
      title: child,
    );

    if (widget.editable) {
      return ClipRRect(child: child);
    } else {
      return child;
    }
  }

  Widget _getItem() {
    return Text(
      widget.term,
      style: TextStyle(
        fontWeight: widget.isNew ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _getEditableItem() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: TextTheme.of(context).bodyLarge,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: 1,
      onEditingComplete: _saveEdit,
    );
  }

  void _saveEdit() {
    if (_controller.text.trim().isEmpty) {
      widget.onRemoveItem(widget.term, _getItem());
    } else {
      widget.onChanged(widget.position, _controller.text);
    }

    setState(() => _isEditing = false);
    _focusNode.unfocus();
  }

  void _cancelEdit() {
    _controller.resetToInitialValue();
    _focusNode.unfocus();
    setState(() => _isEditing = false);
  }

  void _onFocus() {
    if (_focusNode.hasFocus && !_isEditing) {
      setState(() => _isEditing = true);
    } else if (!_focusNode.hasFocus && _isEditing) {
      _cancelEdit();
    }
  }

  @override
  void dispose() {
    if (widget.editable) {
      _controller.dispose();
    }
    super.dispose();
  }
}

class _SimpleInputListItemAction extends StatefulWidget {
  const _SimpleInputListItemAction({
    required this.onTap,
    required this.icon,
    required this.tooltip,
    this.visible = true,
  });

  final VoidCallback onTap;
  final Widget icon;
  final String tooltip;
  final bool visible;

  @override
  State<_SimpleInputListItemAction> createState() =>
      _SimpleInputListItemActionState();
}

class _SimpleInputListItemActionState extends State<_SimpleInputListItemAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: SmoothAnimationsDuration.medium,
      reverseDuration: SmoothAnimationsDuration.short,
    )..addListener(() => setState(() {}));

    if (widget.visible) {
      _controller.forward(from: 1.0);
    }

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _sizeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_SimpleInputListItemAction oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: _controller.value == 0.0,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: SizedBox(
          width: _sizeAnimation.value * (SMALL_SPACE * 2 + 24.0),
          child: Tooltip(
            message: widget.tooltip,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: widget.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
