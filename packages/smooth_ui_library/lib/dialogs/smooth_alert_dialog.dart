import 'package:flutter/material.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';

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

class SmoothAlertDialog extends StatefulWidget {
  const SmoothAlertDialog(
      {Key key,
      this.title,
      this.close = true,
      this.height,
      this.body,
      this.actions})
      : super(key: key);

  final String title;
  final bool close;
  final double height;
  final Widget body;
  final List<SmoothSimpleButton> actions;

  @override
  _SmoothAlertDialogState createState() => _SmoothAlertDialogState();
}

class _SmoothAlertDialogState extends State<SmoothAlertDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),

      content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        _buildTitle(widget.title),
        Container(
          height: widget.height,
          child: widget.body,
        ),
      ]),

      actions: <Widget>[
        SizedBox(
          height: 58.0,
          width: MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.actions,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String _title) {

    if (_title == null) {
      return Container();
    } else {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildCross(true),
              Flexible(
                child: Text(
                  '$_title',
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.center,
                ),
              ),
              _buildCross(false),
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
          const SizedBox(
            height: 15.0,
          ),
        ],
      );
    }
  }

  Widget _buildCross(bool isPlaceHolder) {
    if (widget.close) {
      return Visibility(
        child: InkWell(
          child: Icon(
            Icons.close,
            size: widget.height,
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
///   final List<SmoothSimpleButton> actions;
///   final double height;
///
