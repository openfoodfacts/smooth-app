import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmoothProductCardThanks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Thank you for adding this product !', style: Theme.of(context).textTheme.bodyText1),
          const SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/misc/checkmark.svg',
                width: 36.0,
                height: 36.0,
                color: Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
