import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';

class SvgIconChip extends StatelessWidget {
  const SvgIconChip(this.iconUrl, {required this.height});

  final String iconUrl;
  final double height;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minWidth: height),
    child: SvgCache(iconUrl, height: height),
  );
}
