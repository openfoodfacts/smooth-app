import 'dart:math' as math;
import 'dart:ui';

/// 90 degree rotations.
enum Rotation {
  noon,
  threeOClock,
  sixOClock,
  nineOClock,
}

extension RotationExtension on Rotation {
  /// Returns the rotation in radians cw.
  double get radians {
    switch (this) {
      case Rotation.noon:
        return 0;
      case Rotation.threeOClock:
        return math.pi / 2;
      case Rotation.sixOClock:
        return math.pi;
      case Rotation.nineOClock:
        return 3 * math.pi / 2;
    }
  }

  /// Returns the rotation rotated 90 degrees to the right.
  Rotation get rotateRight {
    switch (this) {
      case Rotation.noon:
        return Rotation.threeOClock;
      case Rotation.threeOClock:
        return Rotation.sixOClock;
      case Rotation.sixOClock:
        return Rotation.nineOClock;
      case Rotation.nineOClock:
        return Rotation.noon;
    }
  }

  /// Returns true if the rotated width is the initial height.
  bool get isTilted {
    switch (this) {
      case Rotation.noon:
      case Rotation.sixOClock:
        return false;
      case Rotation.threeOClock:
      case Rotation.nineOClock:
        return true;
    }
  }

  /// Returns the offset as rotated.
  Offset getRotatedOffset(
    final Offset offset01,
    final double noonWidth,
    final double noonHeight,
  ) {
    switch (this) {
      case Rotation.noon:
        return Offset(
          noonWidth * offset01.dx,
          noonHeight * offset01.dy,
        );
      case Rotation.sixOClock:
        return Offset(
          noonWidth * (1 - offset01.dx),
          noonHeight * (1 - offset01.dy),
        );
      case Rotation.threeOClock:
        return Offset(
          noonWidth * offset01.dy,
          noonHeight * (1 - offset01.dx),
        );
      case Rotation.nineOClock:
        return Offset(
          noonWidth * (1 - offset01.dy),
          noonHeight * offset01.dx,
        );
    }
  }
}
