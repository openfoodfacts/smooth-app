import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:smooth_app/cache/files/file_cache_manager.dart';

import '../tests_utils/path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockedPathProviderPlatform();

  _runTests(FileCacheManager.temporary, 'Temporary');
  _runTests(FileCacheManager.persistent, 'Persistent');
}

void _runTests(FileCache cache, String debugLabel) {
  const String testFileContent = 'Hello World';
  const String fileKey = 'hello';
  final String label = '[$debugLabel]';

  test('$label Add file', () async {
    final FileCache cache = FileCacheManager.temporary;
    expect(
        await cache.put(fileKey, Uint8List.fromList(testFileContent.codeUnits)),
        true);
    expect(await cache.containsKey(fileKey), true);
  });
  test('$label Get file', () async {
    expect(
      await cache.put(fileKey, Uint8List.fromList(testFileContent.codeUnits)),
      true,
    );
    final Uint8List? content = await cache.get(fileKey);

    expect(
        String.fromCharCodes(
          content!.toList(growable: false),
        ),
        testFileContent);
  });

  test('$label Remove file', () async {
    expect(
        await cache.put(fileKey, Uint8List.fromList(testFileContent.codeUnits)),
        true);
    expect(await cache.remove(fileKey), true);
    expect(await cache.containsKey(fileKey), false);
  });

  test('$label Clear cache', () async {
    await cache.clear();
    expect(await cache.length, 0);
  });
}
