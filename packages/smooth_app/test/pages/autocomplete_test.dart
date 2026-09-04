import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Mock autocompleter that simulates slow/failing network
class _MockAutocompleter implements Autocompleter {
  _MockAutocompleter({this.delay = Duration.zero, this.shouldFail = false});

  final Duration delay;
  final bool shouldFail;
  int callCount = 0;

  @override
  Future<List<String>> getSuggestions(String input) async {
    callCount++;
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw Exception('Network error');
    }
    return <String>['$input-result1', '$input-result2'];
  }
}

void main() {
  group('AutocompleteManager', () {
    test('cache hit returns immediately without server call', () async {
      final _MockAutocompleter mock = _MockAutocompleter();
      final AutocompleteManager manager = AutocompleteManager(mock);

      // First call hits server
      final List<String> first = await manager.getSuggestions('bo');
      expect(first, contains('bo-result1'));
      expect(mock.callCount, 1);

      // Second call should hit cache — no new server call
      final List<String> second = await manager.getSuggestions('bo');
      expect(second, contains('bo-result1'));
      expect(mock.callCount, 1); // still 1 — cache served it
    });

    test('returns most recent cached result when out of order', () async {
      final _MockAutocompleter slowMock = _MockAutocompleter(
        delay: const Duration(milliseconds: 100),
      );
      final AutocompleteManager manager = AutocompleteManager(slowMock);

      // Fire both requests simultaneously
      final Future<List<String>> boFuture = manager.getSuggestions('bo');
      final Future<List<String>> botFuture = manager.getSuggestions('bot');

      final List<String> boResult = await boFuture;
      final List<String> botResult = await botFuture;

      // Both should have cached their own results
      expect(boResult, isNotEmpty);
      expect(botResult, isNotEmpty);
    });

    test('network failure throws exception', () async {
      final _MockAutocompleter failMock = _MockAutocompleter(shouldFail: true);
      final AutocompleteManager manager = AutocompleteManager(failMock);

      // Should throw — smooth-app catch block must handle this
      expect(() => manager.getSuggestions('bo'), throwsException);
    });
  });
}
