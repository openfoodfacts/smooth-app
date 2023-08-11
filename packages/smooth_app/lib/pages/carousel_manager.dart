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

  /// A hidden attribute to force to return to the Scanner tab
  /// This value should only be accessed via [forceShowScannerTab], as it will
  /// consume this value (= turn it to false) when it is read.
  bool _forceShowScannerTab = false;
  String? currentBarcode;

  @override
  Widget build(BuildContext context) {
    return _InheritedCarouselManager(
      state: this,
      child: widget.child,
    );
  }

  void showSearchCard({
    bool notify = false,
  }) {
    animatePageTo(0);

    if (notify) {
      SmoothHapticFeedback.lightNotification();
    }

    setState(() => _forceShowScannerTab = true);
  }

  /// Get the info and consume it immediately
  bool get forceShowScannerTab {
    final bool value = _forceShowScannerTab;
    _forceShowScannerTab = false;
    return value;
  }

  // With an animation
  void animatePageTo(int page) => _controller.animateToPage(page);

  // Without an animation
  void moveToSearchCard() => _controller.jumpToPage(0);

  CarouselController get controller => _controller;

  bool updateShouldNotify(ExternalCarouselManagerState oldState) {
    return oldState.currentBarcode != currentBarcode || _forceShowScannerTab;
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
