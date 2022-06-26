import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// This Widgets tracks both the app lifecycle and the screen visibility
/// [onStart] will be called only when the Widget is displayed for the first time
/// (= during the [initState] phase)
/// [onResume] will be called once the app is reopened (eg: the app is minimized
/// and brought back to front)
/// [onPause] will be called once the app is minimized
/// [onVisible] will be called if this part of the tree is visible
/// [onInvisible] will be called if this part of the tree is invisible
class LifeCycleManager extends StatefulWidget {
  const LifeCycleManager({
    required this.onResume,
    required this.onPause,
    required this.child,
    this.onStart,
    this.onVisible,
    this.onInvisible,
    super.key,
  });

  final Function() onResume;
  final Function() onPause;
  final Function()? onStart;
  final Function()? onVisible;
  final Function()? onInvisible;
  final Widget child;

  @override
  LifeCycleManagerState createState() => LifeCycleManagerState();
}

class LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.onStart != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onStart!());
    }
  }

  // Lifecycle changes are not handled by either of the used plugin. This means
  // we are responsible to control camera resources when the lifecycle state is
  // updated. Failure to do so might lead to unexpected behavior
  // didChangeAppLifecycleState is called when the system puts the app in the
  // background or returns the app to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifecycleState = state;
    _onLifeCycleChanged();
  }

  void _onLifeCycleChanged() {
    switch (appLifecycleState) {
      case AppLifecycleState.resumed:
        Logs.d('Lifecycle: on resume');
        widget.onResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        Logs.d('Lifecycle: on pause');
        widget.onPause();
        break;
    }
  }

  void _onVisibilityChanged(bool visible) {
    if (visible) {
      Logs.d('Visibility: visible');
      widget.onVisible?.call();
    } else {
      Logs.d('Visibility: invisible');
      widget.onInvisible?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey<String>('VisibilityDetector'),
      onVisibilityChanged: (VisibilityInfo info) {
        _onVisibilityChanged(info.visible);
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
