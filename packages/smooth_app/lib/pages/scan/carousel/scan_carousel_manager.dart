import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';

/// Allow to control the [ScanPageCarousel] from outside
class ExternalScanCarouselManager extends StatefulWidget {
  const ExternalScanCarouselManager({super.key, required this.child});

  final Widget child;

  static ExternalScanCarouselManagerState watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedCarouselManager>()!
        .state;
  }

  static ExternalScanCarouselManagerState? find(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<_InheritedCarouselManager>()
        ?.state;
  }

  static ExternalScanCarouselManagerState read(BuildContext context) {
    return find(context)!;
  }

  @override
  State<ExternalScanCarouselManager> createState() =>
      ExternalScanCarouselManagerState();
}

class ExternalScanCarouselManagerState
    extends State<ExternalScanCarouselManager> {
  final CarouselSliderController _controller = CarouselSliderController();

  /// A hidden attribute to force to return to the Scanner tab
  /// This value should only be accessed via [forceShowScannerTab], as it will
  /// consume this value (= turn it to false) when it is read.
  bool _forceShowScannerTab = false;
  String? currentBarcode;

  @override
  Widget build(BuildContext context) {
    return _InheritedCarouselManager(state: this, child: widget.child);
  }

  void showSearchCard({bool notify = false}) {
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

  CarouselSliderController get controller => _controller;

  bool updateShouldNotify(ExternalScanCarouselManagerState oldState) {
    return oldState.currentBarcode != currentBarcode || _forceShowScannerTab;
  }
}

class _InheritedCarouselManager extends InheritedWidget {
  const _InheritedCarouselManager({required super.child, required this.state});

  final ExternalScanCarouselManagerState state;

  @override
  bool updateShouldNotify(_InheritedCarouselManager oldWidget) {
    return state.updateShouldNotify(oldWidget.state);
  }
}
