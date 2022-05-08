import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:smooth_app/cache/files/files_cache.dart';

import '../utils/path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockedPathProviderPlatform();

  const String testFileContent = 'Hello World';
  const String fileKey = 'hello';

  test('Add file', () async {
    final FileCache cache = await FileCacheManager.getDefault();
    expect(
        await cache.put(fileKey, Uint8List.fromList(testFileContent.codeUnits)),
        true);
    expect(await cache.containsKey(fileKey), true);
  });
  test('Get file', () async {
    final FileCache cache = await FileCacheManager.getDefault();
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

  test('Remove file', () async {
    final FileCache cache = await FileCacheManager.getDefault();
    expect(
        await cache.put(fileKey, Uint8List.fromList(testFileContent.codeUnits)),
        true);
    expect(await cache.remove(fileKey), true);
    expect(await cache.containsKey(fileKey), false);
  });

  test('Clear cache', () async {
    final FileCache cache = await FileCacheManager.getDefault();
    await cache.clear();
    expect(await cache.length, 0);
  });
}
