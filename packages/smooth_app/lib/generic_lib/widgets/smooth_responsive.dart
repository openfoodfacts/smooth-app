import 'package:flutter/material.dart';

class SmoothResponsive {
  SmoothResponsive(final BuildContext context) {
    width = MediaQuery.widthOf(context);
  }

  late final double width;

  DeviceType get deviceType {
    if (width <= DeviceType.small.maxWidth) {
      return DeviceType.small;
    } else if (width <= DeviceType.smartphone.maxWidth) {
      return DeviceType.smartphone;
    } else if (width <= DeviceType.tablet.maxWidth) {
      return DeviceType.tablet;
    } else {
      return DeviceType.large;
    }
  }
}

/// Custom Widget to provide a responsive behavior.
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
    final SmoothResponsive responsive = SmoothResponsive(context);

    return switch (responsive.deviceType) {
      DeviceType.small => smallDeviceBuilder?.call(context) 
        ?? defaultDeviceBuilder(context),

      DeviceType.smartphone => defaultDeviceBuilder(context),

      DeviceType.tablet => tabletDeviceBuilder?.call(context)
        ?? defaultDeviceBuilder(context),

      DeviceType.large => largeDeviceBuilder?.call(context)
        ?? defaultDeviceBuilder(context),
    };
  }
}

enum DeviceType {
  small(maxWidth: 400.0),
  smartphone(maxWidth: 600.0),
  tablet(maxWidth: 800.0),
  large(maxWidth: double.infinity);

  const DeviceType({required this.maxWidth});

  final double maxWidth;
}
