// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/helpers/system_ui_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/homepage/body/lists/homepage_scan_history.dart';
import 'package:smooth_app/pages/homepage/camera/expandable_view/expandable_camera.dart';
import 'package:smooth_app/pages/homepage/camera/view/ui/camera_view.dart';
import 'package:smooth_app/pages/homepage/header/homepage_flexible_header.dart';
import 'package:smooth_app/pages/homepage/utils/homepage_physics.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const double CAMERA_PEAK = 0.4;

  // HEADER_ROUNDED_RADIUS
  static const double BORDER_RADIUS = 30.0;
  static const double APP_BAR_HEIGHT = 160.0;
  static const double HORIZONTAL_PADDING = 24.0;
  static const double TOP_ICON_PADDING =
      kToolbarHeight - kMinInteractiveDimension;

  @override
  State<HomePage> createState() => HomePageState();

  static HomePageState of(BuildContext context) {
    return context.read<HomePageState>();
  }
}

class HomePageState extends State<HomePage> {
  final Key _screenKey = UniqueKey();

  // Lazy values (used to minimize the time required on each frame)
  double? _cameraPeakHeight;
  double? _scrollPositionBeforePause;

  late ScrollController _controller;
  late CustomScannerController _cameraController;
  late final AppLifecycleListener _lifecycleListener;

  bool _ignoreAllEvents = false;
  ScrollStartNotification? _scrollStartNotification;
  ScrollStartNotification? _scrollInitialStartNotification;
  ScrollMetrics? _userInitialScrollMetrics;
  HomePageSnapScrollPhysics? _physics;
  ScrollDirection _direction = ScrollDirection.forward;
  bool _screenVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _cameraController = CustomScannerController(
      controller: MobileScannerController(autoStart: false),
    );
    _lifecycleListener = AppLifecycleListener(
      onPause: _onPause,
      onResume: _onResume,
    );

    _setInitialScroll();
  }

  void _onPause() {
    if (_controller.hasClients) {
      _scrollPositionBeforePause = _controller.offset;
      _cameraController.onPause();
    }
  }

  void _onResume() {
    if (_scrollPositionBeforePause != null &&
        isCameraVisible(offset: _scrollPositionBeforePause)) {
      _cameraController.start();
    }
  }

  void _setInitialScroll() {
    /// This algorithm looks like an infinite loop, but it is not.
    /// The first time, the MediaQuery is not yet ready, so we schedule
    /// another frame to try again.
    onNextFrame(() {
      final double offset = _initialOffset;

      if (offset <= 0) {
        // The MediaQuery is not yet ready (reproducible in production)
        _setInitialScroll();
      } else {
        _physics = HomePageSnapScrollPhysics(
          steps: <double>[0.0, cameraPeak, cameraHeight],
          lastStepBlocking: true,
        );
        _controller.jumpTo(_initialOffset);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<HomePageState>.value(value: this),
        ChangeNotifierProvider<ScrollController>.value(value: _controller),
      ],
      child: VisibilityDetector(
        key: _screenKey,
        onVisibilityChanged: (VisibilityInfo visibility) {
          _screenVisible = visibility.visibleFraction > 0;
          _onScreenVisibilityChanged(_screenVisible);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: NotificationListener<Notification>(
            onNotification: (Notification notification) {
              if (_ignoreAllEvents) {
                return false;
              }

              if (notification is ScrollStartNotification) {
                if (notification.dragDetails != null) {
                  _scrollInitialStartNotification = _scrollStartNotification;
                } else {
                  _scrollInitialStartNotification = null;
                }

                _scrollStartNotification = notification;
              } else if (notification is UserScrollNotification) {
                _direction = notification.direction;

                if (notification.direction != ScrollDirection.idle) {
                  _userInitialScrollMetrics = notification.metrics;
                }
              } else if (notification is ScrollEndNotification) {
                // Ignore if this is just a tap or a non-user event
                // (drag detail == null)
                if (notification.metrics.axis != Axis.vertical ||
                    notification.dragDetails == null ||
                    (_scrollInitialStartNotification == null &&
                        _scrollStartNotification?.metrics ==
                            notification.metrics)) {
                  return false;
                }

                _onScrollEnded(notification);
              } else if (notification is ScrollUpdateNotification) {
                if (notification.metrics.axis != Axis.vertical) {
                  return false;
                }
                _onScrollUpdate(notification);
              }
              return false;
            },
            child: Builder(
              builder: (BuildContext context) {
                return CustomScrollView(
                  physics: _ignoreAllEvents
                      ? const NeverScrollableScrollPhysics()
                      : _physics,
                  controller: _controller,
                  slivers: <Widget>[
                    HomePageExpandableView(
                      controller: _cameraController,
                      height:
                          MediaQuery.sizeOf(context).height -
                          kBottomNavigationBarHeight -
                          MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    const HomePageFlexibleHeader(),
                    //const HomePageMostScannedProducts(),
                    const HomePageScanHistory(),
                    const SliverFillRemaining(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double get cameraHeight =>
      MediaQuery.sizeOf(context).height -
      MediaQuery.viewPaddingOf(context).bottom -
      kBottomNavigationBarHeight;

  double get cameraPeak => _initialOffset;

  double get _appBarHeight =>
      HomePageFlexibleHeader.HEIGHT + MediaQuery.paddingOf(context).top;

  double get _initialOffset => cameraHeight * (1 - HomePage.CAMERA_PEAK);

  bool get isCameraFullyVisible => _controller.offset == 0.0;

  bool isCameraVisible({double? offset}) {
    if (_screenVisible) {
      final double position = offset ?? _controller.offset;
      return position >= 0.0 && position < cameraHeight;
    }
    return false;
  }

  bool get isExpanded => _controller.offset < _initialOffset;

  void ignoreAllEvents(bool value) {
    setState(() => _ignoreAllEvents = value);
  }

  void expandCamera({Duration? duration}) {
    _physics?.ignoreNextScroll = true;
    _controller.animateTo(
      0,
      duration: duration ?? const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void collapseCamera() {
    if (_controller.offset == _initialOffset) {
      return;
    }

    ignoreAllEvents(false);
    _physics?.ignoreNextScroll = true;
    _controller.animateTo(
      _initialOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void showAppBar({VoidCallback? onAppBarVisible}) {
    const Duration duration = Duration(milliseconds: 200);
    _controller.animateTo(
      MediaQuery.sizeOf(context).height -
          MediaQuery.viewPaddingOf(context).bottom -
          kBottomNavigationBarHeight,
      duration: duration,
      curve: Curves.easeOutCubic,
    );

    if (onAppBarVisible != null) {
      Future<void>.delayed(duration, () => onAppBarVisible.call());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// On scroll, update:
  /// - The status bar theme (light/dark)
  /// - Start/stop the camera
  /// - Update the type of the settings icon
  void _onScrollUpdate(ScrollUpdateNotification notification) {
    if (context.darkTheme(listen: false) ||
        _controller.offset.ceilToDouble() < cameraHeight) {
      SystemChrome.setSystemUIOverlayStyle(SystemUIStyle.light);
      if (!_cameraController.isStarted) {
        _cameraController.start();
      }
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUIStyle.dark);
      _cameraController.stop();
    }
  }

  /// When a scroll is finished, animate the content to the correct position
  void _onScrollEnded(ScrollEndNotification notification) {
    final double cameraViewHeight = cameraHeight;
    final double scrollPosition = notification.metrics.pixels;

    final List<double> steps = <double>[0.0, cameraPeak, cameraViewHeight];
    if (steps.contains(scrollPosition) && _userInitialScrollMetrics != null) {
      final double fixedPosition = HomePageSnapScrollPhysics.fixInconsistency(
        steps,
        scrollPosition,
        _userInitialScrollMetrics!.pixels,
      );

      if (fixedPosition != scrollPosition &&
          _scrollInitialStartNotification == null) {
        // If the user scrolls really quickly, he/she can miss a step
        Future<void>.delayed(Duration.zero, () {
          _controller.jumpTo(fixedPosition);
        });
      }
      return;
    } else if (scrollPosition.roundToDouble() >= cameraViewHeight ||
        (_direction == ScrollDirection.idle &&
            _scrollInitialStartNotification == null)) {
      return;
    }

    final double position;
    _cameraPeakHeight ??= cameraViewHeight * (1 - HomePage.CAMERA_PEAK);

    if (scrollPosition < (_cameraPeakHeight!)) {
      if (_direction == ScrollDirection.reverse) {
        position = 0.0;
      } else {
        position = _initialOffset;
      }
    } else if (scrollPosition < cameraViewHeight) {
      if (_direction == ScrollDirection.reverse) {
        position = _cameraPeakHeight!;
      } else {
        position = cameraViewHeight;
      }
    } else if (_direction == ScrollDirection.reverse) {
      position = cameraViewHeight + _appBarHeight;
    } else {
      position = cameraViewHeight;
    }

    Future<void>.delayed(Duration.zero, () {
      _controller.animateTo(
        position,
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  void _onScreenVisibilityChanged(bool visible) {
    if (visible && isCameraVisible()) {
      _cameraController.start();
    } else {
      _cameraController.stop();
    }
  }
}

class SliverListBldr extends StatelessWidget {
  const SliverListBldr({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 20, right: 10),
          child: SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: const Text('Text'),
          ),
        );
      }, childCount: 20),
    );
  }
}
