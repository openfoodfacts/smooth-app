import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';

void main() {
  group('AnalyticsHelper', () {
    test('linkPreferences', () async {
      // TODO: Write test
      // Ensure that the function is being awaited properly
      await AnalyticsHelper.linkPreferences();
    });

    test('initSentry', () async {
      // TODO: Write test
      // Ensure that the function is being awaited properly
      await AnalyticsHelper.initSentry();
    });

    test('_setCrashReports', () async {
      // TODO: Write test
      // Ensure that the function is being awaited properly
      await AnalyticsHelper._setCrashReports();
    });

    test('_setAnalyticsReports', () async {
      // TODO: Write test
      // Ensure that the function is being awaited properly
      await AnalyticsHelper._setAnalyticsReports();
    });

    test('_beforeSend', () async {
      // TODO: Write test
      // Ensure that the function is being awaited properly
      await AnalyticsHelper._beforeSend();
    });

    test('initMatomo', () async {
      // TODO: Write test
      // Ensure that the function is being awaited properly
      await AnalyticsHelper.initMatomo();
    });
  });
}