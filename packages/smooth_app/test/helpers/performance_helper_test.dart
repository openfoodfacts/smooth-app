import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/helpers/performance_helper.dart';

void main() {
  group('Performance Improvements Tests', () {
    test('PerformanceHelper timing works correctly', () {
      // Test sync timing
      final int result = PerformanceHelper.timeSync<int>(
        'test_operation',
        () {
          // Simulate some work
          int sum = 0;
          for (int i = 0; i < 1000; i++) {
            sum += i;
          }
          return sum;
        },
        details: 'summing 1000 numbers',
      );
      
      expect(result, equals(499500)); // 0+1+2+...+999 = 999*1000/2 = 499500
    });

    test('PerformanceHelper async timing works correctly', () async {
      final String result = await PerformanceHelper.timeAsync<String>(
        'async_test_operation',
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'completed';
        },
        details: 'async delay test',
      );
      
      expect(result, equals('completed'));
    });
  });
}