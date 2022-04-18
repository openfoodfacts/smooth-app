import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/cache/cache_manager.dart';

part 'files_cache_impl.dart';

enum FilesCacheType {
  /// Implementation based on [getTemporaryDirectory]
  /// There is no guarantee that files stored will persist over time
  shortLiving,

  /// Implementation based on [getApplicationDocumentsDirectory]
  /// You have the guarantee that files won't be deleted automatically by the
  /// system (eg: in case of low storage)
  longLiving,
}

/// Files caches work will a [String] key.
/// This key being the filename.
typedef FilesCache = CacheManager<String, Uint8List>;

/// Cache allowing to store files in the device persistent storage
class FilesCacheManager {
  const FilesCacheManager._();

  static const String _DEFAULT_CACHE_NAME = 'default';
  static final Map<String, FilesCache> _singletons = <String, FilesCache>{};

  /// Get a [FilesCache] by giving its [name] and its [type]
  /// If no [name] is provided, the default cache will be returned
  /// If no [type] is provided, the default implementation will rely on a long
  /// living cache
  static Future<FilesCache> get({
    String? name = 'default',
    FilesCacheType type = FilesCacheType.longLiving,
  }) async {
    final String cacheName = name ?? _DEFAULT_CACHE_NAME;

    if (!_singletons.containsKey(cacheName)) {
      final _FilesCacheManagerImpl cache = _FilesCacheManagerImpl(type);
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
