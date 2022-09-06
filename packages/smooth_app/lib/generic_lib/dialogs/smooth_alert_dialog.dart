import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_responsive.dart';

/// Custom Dialog to use in the app
///
/// ```dart
/// showDialog<void>(
///        context: context,
///        builder: (BuildContext context) {
///          return SmoothAlertDialog(...)
///	       }
/// )
/// ```
///
/// If only one action button is provided, simply pass a [positiveAction]
/// - [actionsAxis] allows to specify the axis of the buttons. By default, will
///   be [Axis.horizontal], unless it is a small device
/// - [actionsOrder] allows to force the order of the buttons. By default, will
///   be "smart" by guessing the order based on the axis
class SmoothAlertDialog extends StatelessWidget {
  const SmoothAlertDialog({
    this.title,
    required this.body,
    this.positiveAction,
    this.negativeAction,
    this.actionsAxis,
    this.actionsOrder,
    this.close = false,
  });

  final String? title;
  final bool close;
  final Widget body;
  final SmoothActionButton? positiveAction;
  final SmoothActionButton? negativeAction;
  final Axis? actionsAxis;
  final SmoothButtonsBarOrder? actionsOrder;

  static const EdgeInsets _smallContentPadding = EdgeInsets.only(
    left: SMALL_SPACE,
    top: MEDIUM_SPACE,
    right: SMALL_SPACE,
    bottom: SMALL_SPACE,
  );

  static const EdgeInsets _contentPadding = EdgeInsets.only(
    left: 22.0,
    top: VERY_LARGE_SPACE,
    right: 22.0,
    bottom: 22.0,
  );

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent(context);
    final EdgeInsets padding =
        context.isSmallDevice() ? _smallContentPadding : _contentPadding;

    return AlertDialog(
      scrollable: false,
      elevation: 4.0,
      contentPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
      content: ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: Column(
                children: <Widget>[
                  content,
                  if (hasActions) _buildBottomBar(padding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildBottomBar(EdgeInsets padding) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: padding.bottom,
        start: SMALL_SPACE,
      ),
      child: SmoothActionButtonsBar(
        positiveAction: positiveAction,
        negativeAction: negativeAction,
        axis: actionsAxis,
        order: actionsOrder,
      ),
    );
  }

  bool get hasActions => positiveAction != null || negativeAction != null;

  Widget _buildContent(final BuildContext context) => DefaultTextStyle.merge(
        style: const TextStyle(height: 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (title != null) _SmoothDialogTitle(label: title!, close: close),
            body,
          ],
        ),
      );
}

class _SmoothDialogTitle extends StatelessWidget {
  const _SmoothDialogTitle({
    required this.label,
    required this.close,
  });

  static const double _titleHeight = 32.0;

  final String label;
  final bool close;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: _titleHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildCross(true),
              Expanded(
                child: FittedBox(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
              ),
              _buildCross(false),
            ],
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.onBackground),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCross(final bool isPlaceHolder) {
    if (close) {
      return _SmoothDialogCrossButton(
        visible: !isPlaceHolder,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _SmoothDialogCrossButton extends StatelessWidget {
  const _SmoothDialogCrossButton({
    required this.visible,
  });

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: visible,
        child: InkWell(
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(SMALL_SPACE),
            child: Icon(
              Icons.close,
              size: _SmoothDialogTitle._titleHeight - (2 * SMALL_SPACE),
            ),
          ),
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

enum SmoothButtonsBarOrder {
  /// If the [axis] is [Axis.horizontal], the positive button will be on the end
  /// If the [axis] is [Axis.vertical], the positive button will be on the start
  auto,

  /// Whatever the [axis] is, the positive button will always be at first place
  numerical,
}

/// Will display one or two buttons.
/// Note: This Widget supports both RTL and LTR languages.
class SmoothActionButtonsBar extends StatelessWidget {
  const SmoothActionButtonsBar({
    this.positiveAction,
    this.negativeAction,
    this.axis,
    this.order,
    super.key,
  }) : assert(positiveAction != null || negativeAction != null,
            'At least one action must be passed!');

  const SmoothActionButtonsBar.single({
    required SmoothActionButton action,
    Key? key,
  }) : this(
          positiveAction: action,
          key: key,
        );

  final SmoothActionButton? positiveAction;
  final SmoothActionButton? negativeAction;
  final Axis? axis;
  final SmoothButtonsBarOrder? order;

  @override
  Widget build(BuildContext context) {
    final Axis buttonsAxis = axis ?? _findDefaultAxis(context);
    final List<Widget> actions = _buildActions(
      context,
      buttonsAxis,
      order ?? SmoothButtonsBarOrder.auto,
      positiveAction: positiveAction,
      negativeAction: negativeAction,
    )!;

    if (buttonsAxis == Axis.horizontal) {
      // With two buttons, inject a small space between them
      if (actions.length == 2) {
        actions.insert(
          1,
          const SizedBox(width: VERY_SMALL_SPACE),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions,
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions,
        ),
      );
    }
  }

  /// On "small devices", prefer a vertical layout by default.
  Axis _findDefaultAxis(BuildContext context) {
    if (context.isSmallDevice()) {
      return Axis.vertical;
    } else {
      return Axis.horizontal;
    }
  }
}

/// Generates Actions buttons with:
/// In LTR mode: Negative - Positive
/// In RTL mode: Positive - Negative
List<Widget>? _buildActions(
  BuildContext context,
  Axis axis,
  SmoothButtonsBarOrder order, {
  SmoothActionButton? positiveAction,
  SmoothActionButton? negativeAction,
}) {
  if (positiveAction == null && negativeAction == null) {
    return null;
  }

  List<Widget> actions;

  if (axis == Axis.horizontal) {
    // Negative action first
    actions = <Widget>[
      if (negativeAction != null)
        Expanded(
          child: _SmoothActionFlatButton(
            buttonData: negativeAction,
          ),
        ),
      if (positiveAction != null)
        Expanded(
          child: _SmoothActionElevatedButton(
            buttonData: positiveAction,
          ),
        ),
    ];
  } else {
    // Positive first
    actions = <Widget>[
      if (positiveAction != null)
        SizedBox(
          width: double.infinity,
          child: _SmoothActionElevatedButton(
            buttonData: positiveAction,
          ),
        ),
      if (negativeAction != null)
        SizedBox(
          width: double.infinity,
          child: _SmoothActionFlatButton(
            buttonData: negativeAction,
          ),
        ),
    ];

    // Positive first if numerical
    if (order == SmoothButtonsBarOrder.numerical) {
      actions = actions.reversed.toList();
    }
  }

  if (Directionality.of(context) == TextDirection.rtl) {
    return actions.reversed.toList(growable: false);
  } else {
    return actions;
  }
}

class SmoothActionButton {
  SmoothActionButton({
    required this.text,
    required this.onPressed,
    this.minWidth,
    this.height,
    this.lines,
    this.textColor,
  }) : assert(text.isNotEmpty);

  final String text;
  final VoidCallback? onPressed;
  final int? lines;
  final double? minWidth;
  final double? height;
  final Color? textColor;
}

class _SmoothActionElevatedButton extends StatelessWidget {
  const _SmoothActionElevatedButton({
    required this.buttonData,
  });

  final SmoothActionButton buttonData;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return SmoothSimpleButton(
      onPressed: buttonData.onPressed,
      minWidth: buttonData.minWidth ?? 20.0,
      // Ensures FittedBox not used then even the one word text overflows into next line,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          buttonData.text.toUpperCase(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: buttonData.lines ?? 2,
          style: themeData.textTheme.bodyText2!.copyWith(
            fontWeight: FontWeight.bold,
            color: buttonData.textColor ?? themeData.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _SmoothActionFlatButton extends StatelessWidget {
  const _SmoothActionFlatButton({
    required this.buttonData,
  });

  final SmoothActionButton buttonData;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Theme(
      data: themeData.copyWith(
        buttonTheme: const ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
        ),
      ),
      child: TextButton(
        onPressed: buttonData.onPressed,
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: ROUNDED_BORDER_RADIUS,
          ),
          textStyle: themeData.textTheme.bodyText2!.copyWith(
            color: themeData.colorScheme.onPrimary,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SMALL_SPACE,
          ),
        ),
        child: SizedBox(
          height: buttonData.lines != null
              ? VERY_LARGE_SPACE * buttonData.lines!
              : null,
          width: buttonData.minWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              buttonData.text.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: buttonData.textColor ?? themeData.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: buttonData.lines ?? 2,
            ),
          ),
        ),
      ),
    );
  }
}
