import 'package:flutter/material.dart';

class ModalBottomSheetHeader extends StatelessWidget {
  const ModalBottomSheetHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
