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
  const SmoothAlertDialog({
    this.title,
    this.close = true,
    this.height,
    required this.body,
    this.actions,
  });

  final String? title;
  final bool close;
  final double? height;
  final Widget body;
  final List<SmoothActionButton>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTitle(context),
          SizedBox(height: height, child: body),
        ],
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

  Widget _buildTitle(final BuildContext context) {
    const double height = 29;

    if (title == null) {
      return Container();
    } else {
      return Column(
        children: <Widget>[
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildCross(true, context),
                if (title != null)
                  SizedBox(
                    height: height,
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                const SizedBox(
                  width: 10,
                ),
                _buildCross(false, context),
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.onBackground,
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      );
    }
  }

  Widget _buildCross(final bool isPlaceHolder, final BuildContext context) {
    if (close) {
      return Visibility(
        child: InkWell(
          child: Icon(
            Icons.close,
            size: height,
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
}

///
///   final String title;
///   final bool close;
///   final Widget body;
///   final List<SmoothActionButton> actions;
///   final double height;
///
