import 'package:flutter/material.dart';

const String APP_NAME = 'OpenFoodFacts';

const Widget EMPTY_WIDGET = SizedBox.shrink();

const double VERY_SMALL_SPACE = 4.0;
const double SMALL_SPACE = 8.0;
const double BALANCED_SPACE = 10.0;
const double MEDIUM_SPACE = 12.0;
const double LARGE_SPACE = 16.0;
const double VERY_LARGE_SPACE = 20.0;

/// Standard minimum touch/target size, cf. goldens.dart
const double MINIMUM_TOUCH_SIZE = kMinInteractiveDimension;

/// Default icon size, cf. [Icon]
const double DEFAULT_ICON_SIZE = 24.0;

/// Background, e.g SmoothCard
const Radius ROUNDED_RADIUS = Radius.circular(20.0);
//ignore: non_constant_identifier_names
const BorderRadius ROUNDED_BORDER_RADIUS = BorderRadius.all(ROUNDED_RADIUS);

/// Topbar…
const Radius HEADER_ROUNDED_RADIUS = Radius.circular(30.0);
//ignore: non_constant_identifier_names
const BorderRadius HEADER_BORDER_RADIUS = BorderRadius.all(
  HEADER_ROUNDED_RADIUS,
);

/// Full screen button, e.g. KnowledgePanel
const Radius ANGULAR_RADIUS = Radius.circular(8.0);
//ignore: non_constant_identifier_names
const BorderRadius ANGULAR_BORDER_RADIUS = BorderRadius.all(ANGULAR_RADIUS);

/// Buttons & TextFields
const Radius CIRCULAR_RADIUS = Radius.circular(40.0);
//ignore: non_constant_identifier_names
const BorderRadius CIRCULAR_BORDER_RADIUS = BorderRadius.all(CIRCULAR_RADIUS);

const BorderRadius MAX_BORDER_RADIUS = BorderRadius.all(Radius.circular(100.0));
