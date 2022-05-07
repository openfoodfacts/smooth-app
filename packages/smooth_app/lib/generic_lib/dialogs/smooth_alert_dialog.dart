import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

///
///	Open by calling
///
///showDialog<void>(
///        context: context,
///        builder: (BuildContext context) {
///          return SmoothAlertDialog(...)
///	}
///)
///

class SmoothAlertDialog extends StatelessWidget {
  /// The most simple alert dialog: no fancy effects.
  const SmoothAlertDialog({
    this.title,
    required this.body,
    required this.actions,
  })  : close = false,
        maxHeight = null,
        _simpleMode = true;

  /// Advanced alert dialog with fancy effects.
  const SmoothAlertDialog.advanced({
    this.title,
    this.close = true,
    this.maxHeight,
    required this.body,
    this.actions,
  }) : _simpleMode = false;

  final String? title;
  final bool close;
  final double? maxHeight;
  final Widget body;
  final List<SmoothActionButton>? actions;
  final bool _simpleMode;

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent(context);
    return AlertDialog(
      elevation: 4,
      shape: const RoundedRectangleBorder(borderRadius: ROUNDED_BORDER_RADIUS),
      content: _simpleMode
          ? content
          : ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: maxHeight ?? double.infinity * 0.5),
              child: content,
            ),
      actions: actions == null
          ? null
          : <Widget>[
              SizedBox(
                height: 58,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: actions!,
                ),
              ),
            ],
    );
  }

  Widget _buildCross(final bool isPlaceHolder, final BuildContext context) {
    if (close) {
      return Visibility(
        child: InkWell(
          child: const Icon(
            Icons.close,
            size: 29,
          ),
          onTap: () => Navigator.of(context, rootNavigator: true).pop('dialog'),
        ),
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: !isPlaceHolder,
      );
    } else {
      return Container();
    }
  }

  Widget _buildContent(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) ...<Widget>[
            SizedBox(
              height: 32,
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
          if (_simpleMode)
            body
          else
            Expanded(child: SingleChildScrollView(child: body)),
        ],
      );
}
