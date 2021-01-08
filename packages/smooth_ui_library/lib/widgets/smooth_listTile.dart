import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SmoothListTile extends StatelessWidget {
  const SmoothListTile(
      {@required this.text, @required this.onPressed, this.leadingWidget});

  final String text;
  final Widget leadingWidget;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        height: 60.0,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(20.0))),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              text,
            ),
            _buildIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (leadingWidget == null) {
      return SvgPicture.asset(
        'assets/misc/right_arrow.svg',
        color: Theme.of(context).accentColor,
      );
    } else {
      return leadingWidget;
    }
  }
}
