import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {

  const TestPage(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: null,
    );
  }

}