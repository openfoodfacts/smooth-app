import 'package:flutter/material.dart';

/// Full screen route sliding up, used by the selector screens.
Route<T> smoothSelectorRoute<T>(WidgetBuilder builder) {
  return PageRouteBuilder<T>(
    pageBuilder: (BuildContext context, _, _) => builder(context),
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final Animation<Offset> position =
              Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

          return SlideTransition(
            position: position,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
  );
}
