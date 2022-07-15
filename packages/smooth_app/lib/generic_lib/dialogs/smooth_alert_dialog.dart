import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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

class SmoothAlertDialog extends StatelessWidget {
  const SmoothAlertDialog({
    this.title,
    required this.body,
    this.positiveAction,
    this.negativeAction,
    this.close = false,
  });

  final String? title;
  final bool close;
  final Widget body;
  final SmoothActionButton? positiveAction;
  final SmoothActionButton? negativeAction;

  static const EdgeInsets _contentPadding = EdgeInsets.only(
    left: 24.0,
    top: VERY_LARGE_SPACE,
    right: 24.0,
    bottom: 24.0,
  );

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent(context);

    return AlertDialog(
      scrollable: true,
      elevation: 4.0,
      shape: const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
      content: Padding(
        padding: _contentPadding,
        child: Column(
          children: <Widget>[
            content,
            if (hasActions) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Padding _buildBottomBar() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: _contentPadding.bottom,
        start: SMALL_SPACE,
      ),
      child: SmoothActionButtonsBar(
        positiveAction: positiveAction,
        negativeAction: negativeAction,
      ),
    );
  }

  bool get hasActions => positiveAction != null || negativeAction != null;

  Widget _buildContent(final BuildContext context) => Column(
        children: <Widget>[
          if (title != null) ...<Widget>[
            SizedBox(
              height: 32.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildCross(true, context),
                  if (title != null)
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          title!,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                    ),
                  _buildCross(false, context),
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.onBackground),
            const SizedBox(height: 12),
          ],
          body,
        ],
      );

  Widget _buildCross(final bool isPlaceHolder, final BuildContext context) {
    if (close) {
      return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: !isPlaceHolder,
        child: InkWell(
          child: const Icon(
            Icons.close,
            size: 29.0,
          ),
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class SmoothActionButtonsBar extends StatelessWidget {
  const SmoothActionButtonsBar({
    this.positiveAction,
    this.negativeAction,
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _buildActions(
        context,
        positiveAction: positiveAction,
        negativeAction: negativeAction,
      )!,
    );
  }
}

/// Generates Actions buttons with:
/// In LTR mode: Negative - Positive
/// In RTL mode: Positive - Negative
List<Widget>? _buildActions(
  BuildContext context, {
  SmoothActionButton? positiveAction,
  SmoothActionButton? negativeAction,
}) {
  if (positiveAction == null && negativeAction == null) {
    return null;
  }

  final List<Widget> actions = <Widget>[
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
      // if fitted box not used then even the one word text overflows into next line,
      child: FittedBox(
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
        ),
        child: SizedBox(
          height: buttonData.lines != null
              ? VERY_LARGE_SPACE * buttonData.lines!
              : null,
          child: FittedBox(
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
