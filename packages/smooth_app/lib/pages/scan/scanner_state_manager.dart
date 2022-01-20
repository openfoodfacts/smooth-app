import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// This Widgets tracks if the scanner is currently visible and if the app
/// is currently open/idle/closed and controls the camera depending
class ScannerStateManager extends StatefulWidget {
  const ScannerStateManager({
    required this.restartCamera,
    required this.stopCamera,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Function() restartCamera;
  final Function() stopCamera;
  final Widget child;

  @override
  ScannerStateManagerState createState() => ScannerStateManagerState();
}

class ScannerStateManagerState extends State<ScannerStateManager>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.inactive) {
      widget.stopCamera.call();
    } else if (state == AppLifecycleState.resumed) {
      widget.restartCamera.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey<String>('VisibilityDetector'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 0.0) {
          widget.stopCamera.call();
        } else {
          widget.restartCamera.call();
        }
      },
      child: widget.child,
    );
  }
}
