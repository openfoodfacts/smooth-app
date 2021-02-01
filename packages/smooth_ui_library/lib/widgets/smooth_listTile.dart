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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5.0 , 0 , 5.0),
        child: Card(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 10,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
            )
        ),
      )
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (leadingWidget == null) {
      return SvgPicture.asset(
        'assets/misc/right_arrow.svg',
        color: Theme.of(context).colorScheme.onSurface,
      );
    } else {
      return leadingWidget;
    }
  }
}
