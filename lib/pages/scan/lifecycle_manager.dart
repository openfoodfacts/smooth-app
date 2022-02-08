import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// This Widgets tracks if the child is currently visible on screen and if the
/// app gets minimized/resumed by the system
class LifeCycleManager extends StatefulWidget {
  const LifeCycleManager({
    required this.onResume,
    required this.onPause,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Function() onResume;
  final Function() onPause;
  final Widget child;

  @override
  LifeCycleManagerState createState() => LifeCycleManagerState();
}

class LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  double visibleFraction = 100.0;
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;

  void checkLifeCycle() {
    if (appLifecycleState == AppLifecycleState.inactive ||
        visibleFraction == 0.0) {
      widget.onPause.call();
    } else if (appLifecycleState == AppLifecycleState.resumed &&
        visibleFraction > 0.0) {
      widget.onResume.call();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  // Lifecycle changes are not handled by either of the used plugin. This means
  // we are responsible to control camera resources when the lifecycle state is
  // updated. Failure to do so might lead to unexpected behavior
  // didChangeAppLifecycleState is called when the system puts the app in the
  // background or returns the app to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifecycleState = state;
    checkLifeCycle();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey<String>('VisibilityDetector'),
      onVisibilityChanged: (VisibilityInfo info) {
        visibleFraction = info.visibleFraction;
        checkLifeCycle();
      },
      child: widget.child,
    );
  }
}
