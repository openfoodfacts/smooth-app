import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/cache/cache_manager.dart';
import 'package:smooth_app/cache/files/file_cache_manager_impl.dart';

/// Files caches work with a [String] key.
/// This key being the filename.
typedef FileCache = CacheMap<String, Uint8List>;

/// Cache allowing to store files in the device persistent storage
class FileCacheManager {
  const FileCacheManager._();

  static FileCache? _temporaryCache;
  static FileCache? _longLivingCache;

  static FileCache get temporary {
    _temporaryCache = FileCacheManagerImpl(
      rootDirectory: getTemporaryDirectory(),
      subFolderName: 'temp',
    );

    return _temporaryCache!;
  }

  static FileCache get persistent {
    _longLivingCache = FileCacheManagerImpl(
      rootDirectory: getApplicationDocumentsDirectory(),
      subFolderName: 'persistent',
    );

    return _longLivingCache!;
  }
}
