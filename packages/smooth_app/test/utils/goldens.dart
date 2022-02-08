import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

/// Generate new golden file images by running:
///
///     flutter test --update-goldens

/// Allowable percentage of pixel difference for cross-platform testing. Adjust as
/// needed to accommodate golden file testing on all machines.
///
/// Golden files can sometimes have insignificant differences when run on
/// different platforms (i.e. linux versus mac).
const double _kGoldenDiffTolerance = 0.10;

/// Wrapper function for golden tests in smooth_app.
///
/// Ensures tests are only fail when the tolerance level is exceeded, and
/// golden files are stored in a goldens directory.
Future<void> expectGoldenMatches(dynamic actual, String goldenFileKey) async {
  final String goldenPath = path.join('goldens', goldenFileKey);
  goldenFileComparator = SmoothieFileComparator(path.join(
    (goldenFileComparator as LocalFileComparator).basedir.toString(),
    goldenFileKey,
  ));
  return expectLater(actual, matchesGoldenFile(goldenPath));
}

class SmoothieFileComparator extends LocalFileComparator {
  SmoothieFileComparator(String testFile) : super(Uri.parse(testFile));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent > _kGoldenDiffTolerance) {
      final String error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    if (!result.passed) {
      log('A tolerable difference of ${result.diffPercent * 100}% was found when '
          'comparing $golden.');
    }
    return result.passed || result.diffPercent <= _kGoldenDiffTolerance;
  }
}
