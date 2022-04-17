// ignore_for_file: avoid_classes_with_only_static_members
// ignore_for_file: avoid_slow_async_io

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/cache/cache_manager.dart';

/// Files caches work will a [String] key.
/// This key being the filename.
typedef FilesCache = CacheManager<String, Uint8List>;

/// Cache allowing to store files in the device persistent storage
class FilesCacheManager {
  const FilesCacheManager._();

  static const String _DEFAULT_CACHE_NAME = 'default';
  static final Map<String, FilesCache> _singletons = <String, FilesCache>{};

  /// Get a [FilesCache] by giving its [name]
  /// If no [name] is provided, the default cache will be returned
  static Future<FilesCache> get({
    String? name = 'default',
  }) async {
    final String cacheName = name ?? _DEFAULT_CACHE_NAME;

    if (!_singletons.containsKey(cacheName)) {
      final _FilesCacheManagerImpl cache = _FilesCacheManagerImpl();
      await cache._init(name);
      _singletons[cacheName] = cache;
    }

    return _singletons[name]!;
  }

  static void release(FilesCache manager) {
    _singletons.removeWhere((_, FilesCache cache) => cache == manager);
  }

  static void dispose() {
    _singletons.clear();
  }
}

class _FilesCacheManagerImpl extends FilesCache {
  static const String _DEFAULT_FOLDER_NAME = 'default';

  late Directory _directory;

  Future<void> _init(String? name) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    _directory = Directory(
      join(directory.absolute.path, 'temporary_files_cache',
          name ?? _DEFAULT_FOLDER_NAME),
    );
    await _directory.create(recursive: true);
  }

  File _getFilePath(String key) {
    return File(join(_directory.absolute.path, key));
  }

  @override
  Future<Uint8List?> get(String key) {
    final File file = _getFilePath(key);
    return file
        .exists()
        .then((bool exists) => exists ? file.readAsBytes() : null);
  }

  @override
  Future<bool> has(String key) {
    return _getFilePath(key).exists();
  }

  @override
  Future<bool> save(
    String key,
    Uint8List item, {
    bool overrideExistingItem = true,
  }) async {
    if (await has(key) && !overrideExistingItem) {
      return false;
    }

    // Will erase existing file
    final File file = _getFilePath(key);

    try {
      await file.writeAsBytes(
        item,
        mode: FileMode.writeOnly,
        flush: true,
      );
    } on FileSystemException {
      return false;
    }

    return true;
  }

  @override
  Future<int> get count => _directory.list().length;

  @override
  Future<bool> remove(String key) async {
    if (await has(key)) {
      await _getFilePath(key).delete();
      return true;
    }

    return false;
  }

  @override
  Future<void> clear() {
    return _directory.delete(recursive: true);
  }
}
