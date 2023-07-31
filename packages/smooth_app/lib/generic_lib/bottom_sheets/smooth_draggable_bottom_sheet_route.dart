import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_draggable_bottom_sheet.dart';

/// Code freely inspired from [https://github.com/surfstudio/flutter-bottom-sheet]
Future<T?> showDraggableModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder headerBuilder,
  required double headerHeight,
  required WidgetBuilder bodyBuilder,
  double? initHeight,
  double? maxHeight,
  BorderRadius? borderRadius,
  Color? bottomSheetColor,
  Color? barrierColor,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  assert(headerHeight > 0.0);

  return Navigator.of(context, rootNavigator: true).push(
    _FlexibleBottomSheetRoute<T>(
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      initHeight: initHeight ?? 0.5,
      bodyBuilder: bodyBuilder,
      headerBuilder: headerBuilder,
      headerHeight: headerHeight,
      borderRadius: borderRadius,
      bottomSheetBackgroundColor: bottomSheetColor,
    ),
  );
}

/// A modal route with flexible bottom sheet.
class _FlexibleBottomSheetRoute<T> extends PopupRoute<T> {
  _FlexibleBottomSheetRoute({
    required this.initHeight,
    required this.headerBuilder,
    required this.headerHeight,
    required this.bodyBuilder,
    this.barrierLabel,
    this.borderRadius,
    this.bottomSheetBackgroundColor,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder headerBuilder;
  final double headerHeight;
  final WidgetBuilder bodyBuilder;
  final double initHeight;
  final BorderRadius? borderRadius;
  final Color? bottomSheetBackgroundColor;

  @override
  final String? barrierLabel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => Colors.black54;

  late AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    _animationController = AnimationController(
      duration: transitionDuration,
      vsync: navigator!.overlay!,
    );

    return _animationController;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget bottomSheet = MediaQuery.removePadding(
      removeBottom: false,
      context: context,
      child: SmoothDraggableBottomSheet(
        initHeightFraction: initHeight,
        headerBuilder: headerBuilder,
        bodyBuilder: bodyBuilder,
        animationController: _animationController,
        headerHeight: headerHeight,
        borderRadius: borderRadius,
        bottomSheetColor: bottomSheetBackgroundColor,
      ),
    );

    return Theme(
      data: Theme.of(context),
      child: bottomSheet,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const Offset begin = Offset(0.0, 1.0);
    const Offset end = Offset.zero;
    const Cubic curve = Curves.ease;
    final Animatable<Offset> tween =
        Tween<Offset>(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      ),
    );
  }

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);
}
