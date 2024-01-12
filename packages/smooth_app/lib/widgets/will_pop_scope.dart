import 'package:flutter/widgets.dart';

/// Brings the same behavior as WillPopScope, which is now deprecated
/// [onWillPop] is a bit different and still asks as the first value if we should block the pop
/// The second value is used, if [Navigator.pop()] should provide a specific value (can be null)
class WillPopScope2 extends StatelessWidget {
  const WillPopScope2({
    required this.child,
    required this.onWillPop,
    super.key,
  });

  final Widget child;
  final Future<(bool shouldClose, dynamic res)> Function() onWillPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }

        final (bool shouldClose, dynamic res) = await onWillPop.call();
        if (shouldClose == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            /// Passing a value is required here, otherwise we will have a black screen
            Navigator.of(context).pop(res);
          });
        }
      },
      child: child,
    );
  }
}
