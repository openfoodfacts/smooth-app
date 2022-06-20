import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScreenVisibilityDetector extends StatefulWidget {
  const ScreenVisibilityDetector({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ScreenVisibilityDetector> createState() =>
      _ScreenVisibilityDetectorState();

  static bool visible(BuildContext context) =>
      context.read<ScreenVisibility>().isVisible;

  static bool invisible(BuildContext context) => !visible(context);
}

class _ScreenVisibilityDetectorState extends State<ScreenVisibilityDetector> {
  final ScreenVisibility _notifier = ScreenVisibility(false);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey<String>('ScreenVisibility'),
      onVisibilityChanged: (VisibilityInfo info) {
        _notifier.updateValue(info);
      },
      child: ChangeNotifierProvider<ScreenVisibility>.value(
        value: _notifier,
        child: widget.child,
      ),
    );
  }
}

class ScreenVisibility extends ValueNotifier<bool> {
  ScreenVisibility(super.value);

  bool get isVisible => value;

  void updateValue(VisibilityInfo info) {
    final bool visible = info.visible;

    if (value != visible) {
      value = visible;
    }
  }
}

extension VisibilityInfoExt on VisibilityInfo {
  bool get visible => visibleBounds.height > 0.0;
}
