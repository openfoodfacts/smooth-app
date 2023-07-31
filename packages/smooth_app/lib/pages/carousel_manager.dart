import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';

class ExternalCarouselManager extends StatefulWidget {
  const ExternalCarouselManager({
    super.key,
    required this.child,
  });

  final Widget child;

  static ExternalCarouselManagerState watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedCarouselManager>()!
        .state;
  }

  static ExternalCarouselManagerState? find(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<_InheritedCarouselManager>()
        ?.state;
  }

  static ExternalCarouselManagerState read(BuildContext context) {
    return find(context)!;
  }

  @override
  State<ExternalCarouselManager> createState() =>
      ExternalCarouselManagerState();
}

class ExternalCarouselManagerState extends State<ExternalCarouselManager> {
  final CarouselController _controller = CarouselController();

  String? _currentBarcode;

  @override
  Widget build(BuildContext context) {
    return _InheritedCarouselManager(
      state: this,
      child: widget.child,
    );
  }

  void showSearchCard({bool notify = false}) {
    animatePageTo(0);

    if (notify) {
      SmoothHapticFeedback.lightNotification();
    }
  }

  // With an animation
  void animatePageTo(int page) => _controller.animateToPage(page);

  // Without an animation
  void moveToSearchCard() => _controller.jumpToPage(0);

  CarouselController get controller => _controller;

  String? get currentBarcode => _currentBarcode;

  set currentBarcode(String? barcode) =>
      setState(() => _currentBarcode = barcode);

  bool updateShouldNotify(ExternalCarouselManagerState oldState) {
    return oldState.currentBarcode != _currentBarcode;
  }
}

class _InheritedCarouselManager extends InheritedWidget {
  const _InheritedCarouselManager({
    required Widget child,
    required this.state,
    Key? key,
  }) : super(key: key, child: child);

  final ExternalCarouselManagerState state;

  @override
  bool updateShouldNotify(_InheritedCarouselManager oldWidget) {
    return state.updateShouldNotify(oldWidget.state);
  }
}
