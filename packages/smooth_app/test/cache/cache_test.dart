import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:smooth_app/cache/files/files_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  const String testFileContent = 'Hello World';
  const String fileKey = 'hello';

  test('Add file', () async {
    final FilesCache cache = await FilesCacheManager.get();
    await cache.save(fileKey, Uint8List.fromList(testFileContent.codeUnits));
    expect(await cache.has(fileKey), true);
  });
  test('Get file', () async {
    final FilesCache cache = await FilesCacheManager.get();
    await cache.save(fileKey, Uint8List.fromList(testFileContent.codeUnits));
    final Uint8List? content = await cache.get(fileKey);

    expect(
        String.fromCharCodes(
          content!.toList(growable: false),
        ),
        testFileContent);
  });

  test('Remove file', () async {
    final FilesCache cache = await FilesCacheManager.get();
    await cache.save(fileKey, Uint8List.fromList(testFileContent.codeUnits));
    await cache.remove(fileKey);
    expect(await cache.has(fileKey), false);
  });
}

class _FakePathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getLibraryPath() async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getDownloadsPath() async {
    throw UnimplementedError();
  }
}
