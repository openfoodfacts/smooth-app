import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmoothScaffold extends Scaffold {
  const SmoothScaffold({
    this.brightness,
    this.statusBarBackgroundColor,
    this.contentBehindStatusBar = false,
    this.spaceBehindStatusBar = false,
    super.key,
    super.appBar,
    super.body,
    super.floatingActionButton,
    super.floatingActionButtonLocation,
    super.floatingActionButtonAnimator,
    super.persistentFooterButtons,
    super.drawer,
    super.onDrawerChanged,
    super.endDrawer,
    super.onEndDrawerChanged,
    super.bottomNavigationBar,
    super.bottomSheet,
    super.backgroundColor,
    super.resizeToAvoidBottomInset,
    super.primary = true,
    super.drawerDragStartBehavior = DragStartBehavior.start,
    super.extendBody = false,
    super.extendBodyBehindAppBar = false,
    super.drawerScrimColor,
    super.drawerEdgeDragWidth,
    super.drawerEnableOpenDragGesture = true,
    super.endDrawerEnableOpenDragGesture = true,
    super.restorationId,
  });

  static Color get semiTranslucentStatusBar {
    if (Platform.isIOS || Platform.isMacOS) {
      return const Color(0x66000000);
    } else {
      return const Color(0x33000000);
    }
  }

  final Brightness? brightness;
  final Color? statusBarBackgroundColor;
  final bool contentBehindStatusBar;
  final bool spaceBehindStatusBar;

  @override
  ScaffoldState createState() => SmoothScaffoldState();
}

class SmoothScaffoldState extends ScaffoldState {
  @override
  Widget build(BuildContext context) {
    Widget child = super.build(context);

    if (_contentBehindStatusBar) {
      final Color statusBarColor =
          (widget as SmoothScaffold).statusBarBackgroundColor ??
              AppBarTheme.of(context).backgroundColor ??
              SmoothScaffold.semiTranslucentStatusBar;

      if (_spaceBehindStatusBar) {
        child = Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).viewPadding.top,
              child: ColoredBox(
                color: statusBarColor,
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: child,
              ),
            ),
          ],
        );
      } else {
        child = Stack(
          children: <Widget>[
            child,
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).viewPadding.top,
              child: ColoredBox(
                color: statusBarColor,
              ),
            ),
          ],
        );
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: child,
    );
  }

  bool get _contentBehindStatusBar =>
      (widget as SmoothScaffold).contentBehindStatusBar == true;

  bool get _spaceBehindStatusBar =>
      (widget as SmoothScaffold).spaceBehindStatusBar == true;

  Brightness? get _brightness => (widget as SmoothScaffold).brightness;

  SystemUiOverlayStyle get _overlayStyle {
    switch (_brightness) {
      case Brightness.dark:
        return const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        );
      case Brightness.light:
      default:
        return const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        );
    }
  }
}
