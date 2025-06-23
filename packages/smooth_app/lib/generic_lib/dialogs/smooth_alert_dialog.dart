import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_responsive.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/keyboard_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

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
    this.leadingTitle,
    required this.body,
    this.positiveAction,
    this.negativeAction,
    this.neutralAction,
    this.actionsAxis,
    this.actionsOrder,
    this.close = false,
    this.margin,
    this.contentPadding,
  }) : assert(
         body is! LayoutBuilder,
         "LayoutBuilder isn't supported with Dialogs",
       );

  final String? title;
  final Widget? leadingTitle;
  final bool close;
  final Widget body;
  final SmoothActionButton? positiveAction;
  final SmoothActionButton? negativeAction;
  final SmoothActionButton? neutralAction;
  final Axis? actionsAxis;
  final SmoothButtonsBarOrder? actionsOrder;
  final EdgeInsets? margin;
  final EdgeInsetsDirectional? contentPadding;

  /// Default value [_defaultInsetPadding] in dialog.dart
  static const EdgeInsets defaultMargin = EdgeInsets.symmetric(
    horizontal: 40.0,
    vertical: 24.0,
  );

  static const EdgeInsetsDirectional _smallContentPadding =
      EdgeInsetsDirectional.only(
        start: SMALL_SPACE,
        top: MEDIUM_SPACE,
        end: SMALL_SPACE,
        bottom: SMALL_SPACE,
      );

  static const EdgeInsetsDirectional _contentPadding =
      EdgeInsetsDirectional.only(
        start: 22.0,
        top: VERY_LARGE_SPACE,
        end: 22.0,
        bottom: 22.0,
      );

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent(context);
    final EdgeInsetsDirectional padding =
        contentPadding ?? defaultContentPadding(context);

    return AlertDialog(
      scrollable: false,
      elevation: 4.0,
      insetPadding: margin ?? defaultMargin,
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

  Padding _buildBottomBar(EdgeInsetsDirectional padding) {
    final bool singleButton =
        (positiveAction != null &&
            negativeAction == null &&
            neutralAction == null) ||
        (negativeAction != null &&
            positiveAction == null &&
            neutralAction == null) ||
        (neutralAction != null &&
            positiveAction == null &&
            negativeAction == null);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: padding.bottom,
        start: (actionsAxis == Axis.horizontal || singleButton)
            ? SMALL_SPACE
            : 0.0,
        end: positiveAction != null && negativeAction != null
            ? 0.0
            : SMALL_SPACE,
      ),
      child: SmoothActionButtonsBar(
        positiveAction: positiveAction,
        negativeAction: negativeAction,
        neutralAction: neutralAction,
        axis: actionsAxis,
        order: actionsOrder,
      ),
    );
  }

  bool get hasActions =>
      positiveAction != null || negativeAction != null || neutralAction != null;

  Widget _buildContent(final BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(height: 1.5),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          _SmoothDialogTitle(
            label: title!,
            close: close,
            leading: leadingTitle,
          ),
        body,
      ],
    ),
  );

  static EdgeInsetsDirectional defaultContentPadding(BuildContext context) {
    return (context.isSmallDevice() ? _smallContentPadding : _contentPadding);
  }
}

class _SmoothDialogTitle extends StatelessWidget {
  const _SmoothDialogTitle({
    required this.label,
    required this.close,
    this.leading,
  });

  static const double _titleHeight = 32.0;

  final String label;
  final bool close;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle =
        Theme.of(context).textTheme.displayMedium ?? const TextStyle();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: _titleHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (leading != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: leading is Icon ? 2.0 : 0.0,
                    end: SMALL_SPACE,
                  ),
                  child: IconTheme(
                    data: IconThemeData(color: textStyle.color),
                    child: leading!,
                  ),
                ),
              _buildCross(true),
              Expanded(
                child: FittedBox(child: Text(label, style: textStyle)),
              ),
              _buildCross(false),
            ],
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCross(final bool isPlaceHolder) {
    if (close) {
      return _SmoothDialogCrossButton(visible: !isPlaceHolder);
    } else {
      return EMPTY_WIDGET;
    }
  }
}

class _SmoothDialogCrossButton extends StatelessWidget {
  const _SmoothDialogCrossButton({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: visible,
        child: Semantics(
          label: MaterialLocalizations.of(context).closeButtonLabel,
          button: true,
          excludeSemantics: true,
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
        ),
      );
    } else {
      return EMPTY_WIDGET;
    }
  }
}

enum SmoothButtonsBarOrder {
  /// If the [axis] is [Axis.horizontal], the positive button will be at the end
  /// If the [axis] is [Axis.vertical], the positive button will be at the first
  /// position
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
    this.neutralAction,
    this.axis,
    this.order,
    this.padding,
    super.key,
  }) : assert(
         positiveAction != null ||
             negativeAction != null ||
             neutralAction != null,
         'At least one action must be passed!',
       );

  const SmoothActionButtonsBar.single({
    required SmoothActionButton action,
    Key? key,
  }) : this(positiveAction: action, key: key);

  final SmoothActionButton? positiveAction;
  final SmoothActionButton? negativeAction;
  final SmoothActionButton? neutralAction;
  final Axis? axis;
  final SmoothButtonsBarOrder? order;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Axis buttonsAxis = axis ?? _findDefaultAxis(context);
    final List<Widget> actions = _buildActions(
      context,
      buttonsAxis,
      order ?? SmoothButtonsBarOrder.auto,
      positiveAction: positiveAction,
      negativeAction: negativeAction,
      neutralAction: neutralAction,
    )!;

    if (buttonsAxis == Axis.horizontal) {
      // With multiple buttons, inject a small space between them
      if (actions.length > 1) {
        if (actions.length > 2) {
          // space injected before 3rd item
          actions.insert(2, const SizedBox(width: VERY_SMALL_SPACE));
        }
        // space injected before 2nd item
        actions.insert(1, const SizedBox(width: VERY_SMALL_SPACE));
      }

      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions,
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.zero,
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
  SmoothActionButton? neutralAction,
}) {
  if (positiveAction == null &&
      negativeAction == null &&
      neutralAction == null) {
    return null;
  }

  List<Widget> actions;

  if (axis == Axis.horizontal) {
    // Negative action first
    actions = <Widget>[
      if (negativeAction != null)
        Expanded(child: _SmoothActionFlatButton(buttonData: negativeAction)),
      if (neutralAction != null)
        Expanded(child: _SmoothActionFlatButton(buttonData: neutralAction)),
      if (positiveAction != null)
        Expanded(
          child: _SmoothActionElevatedButton(buttonData: positiveAction),
        ),
    ];
  } else {
    // Positive first
    actions = <Widget>[
      if (positiveAction != null)
        SizedBox(
          width: double.infinity,
          child: _SmoothActionElevatedButton(buttonData: positiveAction),
        ),
      if (neutralAction != null)
        SizedBox(
          width: double.infinity,
          child: _SmoothActionFlatButton(buttonData: neutralAction),
        ),
      if (negativeAction != null)
        SizedBox(
          width: double.infinity,
          child: _SmoothActionFlatButton(buttonData: negativeAction),
        ),
    ];

    // Positive first if numerical
    if (order == SmoothButtonsBarOrder.numerical) {
      actions = actions.reversed.toList();
    }
  }

  if (Directionality.of(context) == TextDirection.rtl) {
    return actions.reversed.toList();
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
  const _SmoothActionElevatedButton({required this.buttonData});

  final SmoothActionButton buttonData;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Semantics(
      value: buttonData.text,
      button: true,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 30.0),
        child: SmoothSimpleButton(
          onPressed: buttonData.onPressed,
          minWidth: buttonData.minWidth ?? 20.0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              buttonData.text.toUpperCase(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: buttonData.lines ?? 2,
              style: themeData.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: buttonData.textColor ?? themeData.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmoothActionFlatButton extends StatelessWidget {
  const _SmoothActionFlatButton({required this.buttonData});

  final SmoothActionButton buttonData;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Theme(
      data: themeData.copyWith(
        buttonTheme: const ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
        ),
      ),
      child: Semantics(
        value: buttonData.text,
        button: true,
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: TextButton(
            onPressed: buttonData.onPressed,
            style: TextButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: ROUNDED_BORDER_RADIUS,
              ),
              textStyle: themeData.textTheme.bodyMedium!.copyWith(
                color: themeData.colorScheme.onPrimary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
              minimumSize: const Size(0, 46.0),
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
                    color:
                        buttonData.textColor ?? themeData.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: buttonData.lines ?? 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [Button] that can be displayed in the [body] of a [SmoothAlertDialog].
class SmoothAlertContentButton extends StatelessWidget {
  const SmoothAlertContentButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            if (icon != null) ExcludeSemantics(child: Icon(icon)),
          ],
        ),
      ),
    );
  }
}

/// A custom dialog where you only have to pass a [title] and a [message].
/// By default an "OK" button will be show., but you can override it by passing
/// a [positiveAction] and/or [negativeAction]
class SmoothSimpleErrorAlertDialog extends StatelessWidget {
  const SmoothSimpleErrorAlertDialog({
    required this.title,
    required this.message,
    this.positiveAction,
    this.negativeAction,
    this.actionsAxis,
    this.actionsOrder,
    this.contentPadding,
  });

  final String title;
  final String message;
  final SmoothActionButton? positiveAction;
  final SmoothActionButton? negativeAction;
  final Axis? actionsAxis;
  final SmoothButtonsBarOrder? actionsOrder;
  final EdgeInsetsDirectional? contentPadding;

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      children: <Widget>[
        SvgPicture.asset(
          'assets/misc/error.svg',
          width: MINIMUM_TOUCH_SIZE * 2,
          package: AppHelper.APP_PACKAGE,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: LARGE_SPACE),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
        ),
      ],
    );

    SmoothActionButton? positiveButton = positiveAction;
    if (positiveAction == null && negativeAction == null) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      positiveButton = SmoothActionButton(
        text: appLocalizations.okay,
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    return SmoothAlertDialog(
      body: content,
      positiveAction: positiveButton,
      negativeAction: negativeAction,
      actionsAxis: actionsAxis,
      actionsOrder: actionsOrder,
      contentPadding: contentPadding,
    );
  }
}

class SmoothListAlertDialog extends StatelessWidget {
  SmoothListAlertDialog({
    required this.title,
    required this.list,
    this.header,
    ScrollController? scrollController,
    this.positiveAction,
    this.negativeAction,
    this.actionsAxis,
    this.actionsOrder,
  }) : _scrollController = scrollController ?? ScrollController();

  final String title;
  final Widget? header;
  final Widget list;
  final SmoothActionButton? positiveAction;
  final SmoothActionButton? negativeAction;
  final Axis? actionsAxis;
  final SmoothButtonsBarOrder? actionsOrder;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return SmoothAlertDialog(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 0.0,
        vertical: SMALL_SPACE,
      ),
      body: SizedBox(
        height:
            MediaQuery.sizeOf(context).height /
            (context.keyboardVisible ? 1.0 : 1.5),
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: <Widget>[
            Container(
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsetsDirectional.only(
                start: 23.0,
                end: 24.0,
                top: SMALL_SPACE,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            if (header != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SMALL_SPACE,
                  vertical: MEDIUM_SPACE,
                ),
                child: header,
              ),
            Expanded(
              child: Scrollbar(controller: _scrollController, child: list),
            ),
          ],
        ),
      ),
      positiveAction: positiveAction,
      negativeAction: negativeAction,
      actionsAxis: actionsAxis,
      actionsOrder: actionsOrder,
    );
  }
}
