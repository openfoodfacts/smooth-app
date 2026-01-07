import 'package:flutter/widgets.dart';

class SmoothResponsive {
  const SmoothResponsive._();

  static bool isSmallDevice(BuildContext context) {
    return MediaQuery.of(context).isSmallDevice();
  }

  static bool isSmartphoneDevice(BuildContext context) {
    return MediaQuery.of(context).isSmartphoneDevice();
  }

  static bool isTabletDevice(BuildContext context) {
    return MediaQuery.of(context).isTabletDevice();
  }

  static bool isLargeDevice(BuildContext context) {
    return MediaQuery.of(context).isLargeDevice();
  }
}

extension MediaQueryResponsiveExtensions on MediaQueryData {
  static const double _MAX_SMALL_DEVICE_WIDTH = 400.0;
  static const double _MAX_SMARTPHONE_WIDTH = 600.0;
  static const double _MAX_TABLET_WIDTH = 800.0;

  bool isSmallDevice() {
    return size.width <= _MAX_SMALL_DEVICE_WIDTH;
  }

  bool isSmartphoneDevice() {
    return size.width <= _MAX_SMARTPHONE_WIDTH;
  }

  bool isTabletDevice() {
    return size.width <= _MAX_TABLET_WIDTH;
  }

  bool isLargeDevice() {
    return size.width > _MAX_TABLET_WIDTH;
  }

  DeviceType get _deviceType {
    if (size.width <= _MAX_SMALL_DEVICE_WIDTH) {
      return DeviceType.small;
    } else if (size.width <= _MAX_SMARTPHONE_WIDTH) {
      return DeviceType.smartphone;
    } else if (size.width <= _MAX_TABLET_WIDTH) {
      return DeviceType.tablet;
    } else {
      return DeviceType.large;
    }
  }
}

extension BuildContextResponsiveExtensions on BuildContext {
  bool isSmallDevice() {
    return SmoothResponsive.isSmallDevice(this);
  }

  bool isSmartphoneDevice() {
    return SmoothResponsive.isSmartphoneDevice(this);
  }

  bool isTabletDevice() {
    return SmoothResponsive.isTabletDevice(this);
  }

  bool isLargeDevice() {
    return SmoothResponsive.isLargeDevice(this);
  }

  DeviceType get deviceType => MediaQuery.of(this)._deviceType;
}

/// Custom Widget to provide a responsive behavior.
/// [defaultDeviceBuilder] is mandatory and will be used if no value is provided
class SmoothResponsiveBuilder extends StatelessWidget {
  const SmoothResponsiveBuilder({
    required this.defaultDeviceBuilder,
    this.smallDeviceBuilder,
    this.tabletDeviceBuilder,
    this.largeDeviceBuilder,
    super.key,
  });

  final WidgetBuilder defaultDeviceBuilder;
  final WidgetBuilder? smallDeviceBuilder;
  final WidgetBuilder? tabletDeviceBuilder;
  final WidgetBuilder? largeDeviceBuilder;

  @override
  Widget build(BuildContext context) {
    if (largeDeviceBuilder != null && context.isLargeDevice()) {
      return largeDeviceBuilder!(context);
    } else if (tabletDeviceBuilder != null && context.isTabletDevice()) {
      return tabletDeviceBuilder!(context);
    } else if (smallDeviceBuilder != null && context.isSmallDevice()) {
      return smallDeviceBuilder!(context);
    } else {
      return defaultDeviceBuilder(context);
    }
  }
}

enum DeviceType { small, smartphone, tablet, large }
