import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/widgets/screen_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// This Widgets tracks if the child is currently visible on screen and if the
/// app gets minimized/resumed by the system
class LifeCycleManager extends StatefulWidget {
  const LifeCycleManager({
    required this.onResume,
    required this.onPause,
    required this.child,
    this.onStart,
    Key? key,
  }) : super(key: key);

  final Function() onResume;
  final Function() onPause;
  final Function()? onStart;
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
    WidgetsBinding.instance!.addObserver(this);

    if (widget.onStart != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => widget.onStart!());
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
        widget.onResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        widget.onPause();
        break;
    }
    if (appLifecycleState == AppLifecycleState.inactive) {
      widget.onPause();
    } else if (appLifecycleState == AppLifecycleState.resumed) {
      widget.onResume();
    }
  }

  void onVisibilityChanged(bool visible) {
    if (visible) {
      widget.onResume();
    } else {
      widget.onPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey<String>('VisibilityDetector'),
      onVisibilityChanged: (VisibilityInfo info) {
        onVisibilityChanged(info.visible);
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
