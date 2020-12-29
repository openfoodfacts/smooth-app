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
///


class SmoothAlertDialog extends StatelessWidget {

  const SmoothAlertDialog({
    this.title,
    this.close = true,
    @required this.context,
    @required this.body,
    @required this.actions,
    this.height,
  });

  final String title;
  final bool close;
  final BuildContext context;
  final Widget body;
  final List<SmoothSimpleButton> actions;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(),
          Container(
            height: height,
            child: body,
          ),
        ]
      ),



      actions: [
        SizedBox(
          height: 58,
            width: MediaQuery.of(context).size.width,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Credits to https://stackoverflow.com/a/64697189/13313941
                children: actions,
            ),
        ),



      ],
    );
  }

  Widget _buildTitle(){
    double height = 29;

    if(title == null){
      return Container();
    }
    else{
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[

              _buildCrossPlaceHolder(),
              Container(
                height: height,
                child: Text(
                  '$title',
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              _buildCross(),



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

  Widget _buildCross(){
    if(close){
      return InkWell(
        child: Icon(Icons.close, size: height,),
        onTap: () => Navigator.of(context, rootNavigator: true)
            .pop('dialog'),
      );
    } else{
      return Container();
    }
  }

  Widget _buildCrossPlaceHolder(){  //Just a placeholder that the title is still centered
    if(close){
      return Visibility(
        child: SizedBox(
          height: height,
          width: height,
          child: InkWell(
            child: Icon(Icons.close, size: height,),
            onTap: () => Navigator.of(context, rootNavigator: true)
                .pop('dialog'),
          ),
        ),
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: false,
      );
    }
    else{
    return Container();
    }

  }



  }
