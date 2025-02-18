import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Brings the same behavior as WillPopScope, which is now deprecated
/// [onWillPop] is a bit different and still asks as the first value if we should block the pop
/// The second value is used, if [Navigator.pop()] should provide a specific value (can be null)
class WillPopScope2 extends StatelessWidget {
  const WillPopScope2({
    required this.child,
    required this.onWillPop,
    this.controller,
    super.key,
  });

  final Widget child;
  final Future<(bool shouldClose, dynamic res)> Function() onWillPop;
  final WillPopScope2Controller? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WillPopScope2Controller?>.value(
      value: controller,
      child: Consumer<WillPopScope2Controller?>(
        builder: (_, WillPopScope2Controller? controller, __) {
          return PopScope(
            canPop: controller?.value ?? false,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) {
                return;
              }

              final (bool shouldClose, dynamic res) = await onWillPop.call();
              if (shouldClose == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    GoRouter.of(context).pop(res);
                  } on GoError catch (error) {
                    if (error.message == 'There is nothing to pop') {
                      // Force to kill the app
                      SystemNavigator.pop();
                    }
                  }
                });
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}

/// Indicates if a [WillPopScope2] should allows to pop (= swipe back
/// gesture on iOS) or not
class WillPopScope2Controller extends ValueNotifier<bool> {
  WillPopScope2Controller({required bool canPop}) : super(canPop);

  void canPop(bool canPop) {
    super.value = canPop;
  }

  @protected
  @override
  set value(bool value) {
    throw Exception('Please use canPop() instead');
  }
}
