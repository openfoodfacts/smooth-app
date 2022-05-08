import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/cache/cache_manager.dart';

part 'files_cache_impl.dart';

enum FileCacheType {
  /// Implementation based on [getTemporaryDirectory]
  /// There is no guarantee that files stored will persist over time
  shortLiving,

  /// Implementation based on [getApplicationDocumentsDirectory]
  /// You have the guarantee that files won't be deleted automatically by the
  /// system (eg: in case of low storage)
  longLiving,
}

/// Files caches work with a [String] key.
/// This key being the filename.
typedef FileCache = CacheMap<String, Uint8List>;

/// Cache allowing to store files in the device persistent storage
class FileCacheManager {
  const FileCacheManager._();

  static const String _defaultCacheName = 'default';
  static final Map<String, FileCache> _singletons = <String, FileCache>{};

  /// Returns a "default" implementation based on a [FileCacheType.longLiving]
  /// implementation
  static Future<FileCache> getDefault() => get(
        name: _defaultCacheName,
        type: FileCacheType.longLiving,
      );

  /// Get a [FileCache] by giving its [name] and its [type]
  /// If no [name] is provided, the default cache will be returned
  /// If no [type] is provided, the default implementation will rely on a long
  /// living cache
  static Future<FileCache> get({
    required String name,
    required FileCacheType type,
  }) async {
    if (!_singletons.containsKey(name)) {
      final _FileCacheManagerImpl cache = _FileCacheManagerImpl(type);
      await cache._init(name);
      _singletons[name] = cache;
    }

    return _singletons[name]!;
  }

  static void release(FileCache manager) {
    _singletons.removeWhere((_, FileCache cache) => cache == manager);
  }

  static void dispose() {
    _singletons.clear();
  }
}
