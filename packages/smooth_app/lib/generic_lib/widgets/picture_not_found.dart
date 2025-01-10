import 'package:flutter/material.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class PictureNotFound extends StatelessWidget {
  const PictureNotFound({
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  })  : backgroundDecoration = null,
        _useInk = false;

  const PictureNotFound.decoration({
    this.backgroundDecoration,
    this.foregroundColor,
    super.key,
  })  : backgroundColor = null,
        _useInk = false;

  const PictureNotFound.ink({
    this.backgroundDecoration,
    this.foregroundColor,
    super.key,
  })  : _useInk = true,
        backgroundColor = null;

  final BoxDecoration? backgroundDecoration;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool _useInk;

  @override
  Widget build(BuildContext context) {
    final Widget child = SizedBox.expand(
      child: FractionallySizedBox(
        widthFactor: 0.5,
        heightFactor: 0.5,
        child: FittedBox(
          child: icons.Milk.unhappy(
            color: foregroundColor ?? const Color(0xFF949494),
            size: 1000,
          ),
        ),
      ),
    );

    if (_useInk) {
      return Ink(
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFE5E5E5),
        ).copyWith(
          color: backgroundDecoration?.color,
          image: backgroundDecoration?.image,
          border: backgroundDecoration?.border,
          borderRadius: backgroundDecoration?.borderRadius,
          boxShadow: backgroundDecoration?.boxShadow,
          gradient: backgroundDecoration?.gradient,
          backgroundBlendMode: backgroundDecoration?.backgroundBlendMode,
          shape: BoxShape.rectangle,
        ),
        child: child,
      );
    } else {
      final BoxDecoration decoration;
      if (backgroundDecoration != null && backgroundDecoration!.color == null) {
        decoration = backgroundDecoration!.copyWith(
          color: backgroundColor ?? const Color(0xFFE5E5E5),
        );
      } else {
        decoration = BoxDecoration(
          color: backgroundColor ?? const Color(0xFFE5E5E5),
        );
      }

      return DecoratedBox(
        decoration: decoration,
        child: child,
      );
    }
  }
}
