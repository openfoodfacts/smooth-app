import 'package:flutter/material.dart';

class ListHelper {
  ListHelper({required this.onTap, required this.title, this.icon});
  String title;
  void Function() onTap;
  Icon? icon;
}
