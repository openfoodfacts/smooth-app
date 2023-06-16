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
    this.fixKeyboard = false,
    bool? resizeToAvoidBottomInset,
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
    super.primary = true,
    super.drawerDragStartBehavior = DragStartBehavior.start,
    super.extendBody = false,
    super.extendBodyBehindAppBar = false,
    super.drawerScrimColor,
    super.drawerEdgeDragWidth,
    super.drawerEnableOpenDragGesture = true,
    super.endDrawerEnableOpenDragGesture = true,
    super.restorationId,
  }) : super(
          resizeToAvoidBottomInset:
              fixKeyboard ? false : resizeToAvoidBottomInset,
        );

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

  /// On some screens an extra padding maybe wrongly added when the keyboard is
  /// visible
  final bool fixKeyboard;

  @override
  ScaffoldState createState() => SmoothScaffoldState();
}

class SmoothScaffoldState extends ScaffoldState {
  @override
  Widget build(BuildContext context) {
    Widget child = super.build(context);

    final MediaQueryData mediaQuery = MediaQuery.of(context);

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
              height: mediaQuery.viewPadding.top,
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
              height: mediaQuery.viewPadding.top,
              child: ColoredBox(
                color: statusBarColor,
              ),
            ),
          ],
        );
      }
    }

    if ((widget as SmoothScaffold).fixKeyboard) {
      final double padding = MediaQuery.of(context).viewInsets.bottom -
          MediaQuery.of(context).viewPadding.bottom;

      if (padding > 0.0) {
        child = Padding(
          padding: EdgeInsets.only(bottom: padding),
          child: child,
        );
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme.of(context).copyWith(
            systemOverlayStyle: _overlayStyle,
          ),
        ),
        child: child,
      ),
    );
  }

  bool get _contentBehindStatusBar =>
      (widget as SmoothScaffold).contentBehindStatusBar == true;

  bool get _spaceBehindStatusBar =>
      (widget as SmoothScaffold).spaceBehindStatusBar == true;

  Brightness? get _brightness =>
      (widget as SmoothScaffold).brightness ??
      SmoothBrightnessOverride.of(context)?.brightness;

  SystemUiOverlayStyle get _overlayStyle {
    final Brightness? brightness;

    // Invert brightness on iOS devices
    if (Platform.isIOS && _brightness == null) {
      switch (Theme.of(context).brightness) {
        case Brightness.dark:
          brightness = Brightness.light;
          break;
        case Brightness.light:
          brightness = Brightness.dark;
          break;
      }
    } else {
      brightness = _brightness;
    }

    switch (brightness) {
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

/// Class allowing to override the default [Brightness] of
/// a [SmoothScaffold].
class SmoothBrightnessOverride extends InheritedWidget {
  const SmoothBrightnessOverride({
    required Widget child,
    Key? key,
    this.brightness,
  }) : super(key: key, child: child);

  final Brightness? brightness;

  @override
  bool updateShouldNotify(SmoothBrightnessOverride oldWidget) =>
      brightness != oldWidget.brightness;

  static SmoothBrightnessOverride? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SmoothBrightnessOverride>();
  }
}
