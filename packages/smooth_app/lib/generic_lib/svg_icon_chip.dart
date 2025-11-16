import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SvgIconChip extends StatelessWidget {
  const SvgIconChip(this.iconUrl, {required this.height});

  final String iconUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool nutriScoreLogo =
        iconUrl.contains(RegExp(r'.*/nutriscore-[a-z]-.*\.svg')) == true;

    Widget child = SvgCache(iconUrl, height: height);

    if (nutriScoreLogo) {
      child = Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.lightTheme() ? Colors.black26 : Colors.white54,
              width: 1.0,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6.5),
              bottom: Radius.circular(8.0),
            ),
          ),
          child: child,
        ),
      );
    }

    return child;
  }
}
