extension DoubleExtension on double {
  /// Returns the progress of the current value between [min] and [max].
  /// /!\ May return < 0 or > 1 values, use [progressAndClamp] if you want to limit the output.
  /// Eg: 5.progress(0, 10) => 0.5
  /// Eg: -1.progress(0, 5) => -0.2
  double progress(num min, num max) {
    return (this - min) / (max - min);
  }

  /// Returns the progress of the current value between [min] and [max].
  /// The minimum value will always be 0 and the maximum value will always be [clamp].
  double progressAndClamp(num min, double max, double clamp) {
    return progress(min, max).clamp(0.0, clamp);
  }
}

extension IntExtension on int {
  double progress(int min, int max) {
    return (this - min) / (max - min);
  }
}
