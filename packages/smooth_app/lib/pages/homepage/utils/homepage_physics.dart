// ignore_for_file: must_be_immutable
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A custom implementation of [ScrollPhysics] != [_VerticalSnapClampingScrollPhysics]
class HomePageSnapScrollPhysics extends ClampingScrollPhysics {
  HomePageSnapScrollPhysics({
    required List<double> steps,
    this.lastStepBlocking = true,
    final ScrollPhysics? parent,
  }) : steps = steps.toList()..sort(),
       ignoreNextScroll = false,
       super(parent: parent ?? const BouncingScrollPhysics());

  final List<double> steps;

  // If true, scrolling from the bottom with be blocked at the last step
  // If false, scrolling from the bottom will continue
  final bool lastStepBlocking;
  bool ignoreNextScroll;

  @override
  ClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return HomePageSnapScrollPhysics(
      parent: buildParent(ancestor),
      steps: steps,
      lastStepBlocking: lastStepBlocking,
    );
  }

  double? _lastPixels;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      ignoreNextScroll = false;
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      ignoreNextScroll = false;
      return null;
    }

    final Simulation? simulation = super.createBallisticSimulation(
      position,
      velocity,
    );
    final double? simulationX = simulation?.x(double.infinity);
    double? proposedPixels = simulationX;

    if (simulation == null || proposedPixels == null) {
      final (double? min, _) = _getRange(steps, position.pixels);

      if (min != null && min != steps.last && ignoreNextScroll) {
        return ScrollSpringSimulation(
          spring,
          position.pixels,
          min,
          velocity,
          tolerance: toleranceFor(position),
        );
      } else {
        ignoreNextScroll = false;
        return null;
      }
    }

    ignoreNextScroll = false;
    final (double? min, double? max) = _getRange(steps, position.pixels);
    bool hasChanged = false;
    if (min != null && max == null) {
      if (proposedPixels < min) {
        proposedPixels = min;
        hasChanged = true;
      }
    } else if (min != null && max != null) {
      if (position.pixels - proposedPixels > 0) {
        proposedPixels = min;
      } else {
        proposedPixels = max;
      }
      hasChanged = true;
    }

    if (_lastPixels == null) {
      _lastPixels = proposedPixels;
    } else {
      _lastPixels = _fixInconsistency(proposedPixels);
    }

    /// Smooth scroll to a step
    if (hasChanged && (lastStepBlocking || position.pixels < steps.last)) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        _lastPixels!,
        velocity,
        tolerance: tolerance,
      );
    }

    /// Normal scrolling
    return super.createBallisticSimulation(position, velocity);
  }

  // In some cases, the proposed pixels have a giant space and finding the range
  // is incorrect. In that case, we ensure to have a contiguous range.
  double _fixInconsistency(double proposedPixels) {
    return fixInconsistency(steps, proposedPixels, _lastPixels!);
  }

  static double fixInconsistency(
    List<double> steps,
    double proposedPixels,
    double initialPixelPosition,
  ) {
    final int newPosition = _getStepPosition(steps, proposedPixels);
    final int oldPosition = _getStepPosition(steps, initialPixelPosition);

    if (newPosition - oldPosition >= 2) {
      return steps[math.min(newPosition - 1, 0)];
    } else if (newPosition - oldPosition <= -2) {
      return steps[math.min(newPosition + 1, steps.length - 1)];
    }

    return proposedPixels;
  }

  static int _getStepPosition(List<double> steps, double pixels) {
    for (int i = steps.length - 1; i >= 0; i--) {
      final double step = steps.elementAt(i);

      if (pixels >= step) {
        return i;
      }
    }

    return 0;
  }
}

(double?, double?) _getRange(List<double> steps, double position) {
  for (int i = steps.length - 1; i >= 0; i--) {
    final double step = steps[i];

    if (i == steps.length - 1 && position > step) {
      return (step, null);
    } else if (position > step && position < steps[i + 1]) {
      return (step, steps[i + 1]);
    }
  }

  return (null, null);
}
