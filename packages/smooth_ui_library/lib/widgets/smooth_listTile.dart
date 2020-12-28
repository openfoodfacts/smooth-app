import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SmoothListTile extends StatelessWidget {

  const SmoothListTile({@required this.text, @required this.onPressed,});

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        height: 60.0,
        padding:
        const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.black.withAlpha(10),
            borderRadius:
            const BorderRadius.all(Radius.circular(20.0))),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(text,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SvgPicture.asset(
              'assets/misc/right_arrow.svg',
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}