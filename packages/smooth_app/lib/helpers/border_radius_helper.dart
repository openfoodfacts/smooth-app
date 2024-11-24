import 'package:flutter/widgets.dart';

class BorderRadiusHelper {
  BorderRadiusHelper._();

  /// [InkWell] only supports [BorderRadius].
  /// This helps to create a [BorderRadius] from a [BorderRadiusDirectional].
  static BorderRadius fromDirectional({
    required BuildContext context,
    Radius? topStart,
    Radius? topEnd,
    Radius? bottomStart,
    Radius? bottomEnd,
  }) {
    final TextDirection textDirection = Directionality.of(context);

    return BorderRadius.only(
      topLeft: textDirection == TextDirection.ltr
          ? topStart ?? Radius.zero
          : topEnd ?? Radius.zero,
      topRight: textDirection == TextDirection.ltr
          ? topEnd ?? Radius.zero
          : topStart ?? Radius.zero,
      bottomLeft: textDirection == TextDirection.ltr
          ? bottomStart ?? Radius.zero
          : bottomEnd ?? Radius.zero,
      bottomRight: textDirection == TextDirection.ltr
          ? bottomEnd ?? Radius.zero
          : bottomStart ?? Radius.zero,
    );
  }
}
