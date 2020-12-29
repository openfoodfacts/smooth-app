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
  final BuildContext context;
  final String title;
  final bool close;
  final double height;
  final Widget body;
  final List<SmoothSimpleButton> actions;

  SmoothAlertDialog(
      {Key key,
        this.context,
        this.title,
        this.close  = true,
        this.height,
        this.body,
        this.actions
      })
      : super(key: key);

  @override
  _SmoothAlertDialogState createState() => _SmoothAlertDialogState(
    key: key,
    context: context,
    title: title,
    close: close,
    height: height,
    body: body,
    actions: actions,
  );
}

class _SmoothAlertDialogState extends State<SmoothAlertDialog> {
  final BuildContext context;
  final String title;
  final bool close;
  final double height;
  final Widget body;
  final List<SmoothSimpleButton> actions;

  _SmoothAlertDialogState({Key key,
    this.context,
    this.title,
    this.close,
    this.height,
    this.body,
    this.actions});

  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here

      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(title),
            Container(
              height: height,
              child: body,
            ),
          ]
      ),


      actions: [
        SizedBox(
          height: 58,
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions,
          ),
        ),
      ],
    );
  }


  Widget _buildTitle(String _title) {
    double height = 29;

    if (_title == null) {
      return Container();
    }
    else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              _buildCross(true),
              Container(
                height: height,
                child: Text(
                  '${_title}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline2,
                ),
              ),
              _buildCross(false),


            ],
          ),

          const Divider(
            color: Colors.black,
          ),
          SizedBox(
            height: 15,
          ),
        ],
      );
    }
  }



  Widget _buildCross(bool isPlaceHolder) {
    if (close) {
      return Visibility(
        child: InkWell(
          child: Icon(Icons.close, size: height,),
          onTap: () =>
              Navigator.of(context, rootNavigator: true)
                  .pop('dialog'),
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
///   final BuildContext context;
///   final String title;
///   final bool close;
///   final Widget body;
///   final List<SmoothSimpleButton> actions;
///   final double height;
///
