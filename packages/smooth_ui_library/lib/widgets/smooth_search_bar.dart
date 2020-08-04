
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmoothSearchBar extends StatelessWidget {

  const SmoothSearchBar({this.controller, this.hintText, this.color = Colors.black, this.borderRadius = 20.0});

  final TextEditingController controller;
  final String hintText;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 24.0,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      shadowColor: color.withAlpha(160),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyText1,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            borderSide: BorderSide.none
          ),
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.black),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset('assets/navigation/search.svg', color: Colors.grey,),
          ),
          focusColor: color,
        ),
      ),
    );
  }

}