
import 'package:flutter/material.dart';

class SmoothToggle extends StatelessWidget {

  const SmoothToggle({@required this.value, this.onChanged});

  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: Colors.black,
      value: value,
      onChanged: onChanged,
    );
  }

}