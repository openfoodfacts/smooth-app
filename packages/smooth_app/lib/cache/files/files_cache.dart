import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_app/cache/cache_manager.dart';

part 'files_cache_impl.dart';

/// Files caches work with a [String] key.
/// This key being the filename.
typedef FileCache = CacheMap<String, Uint8List>;

/// Cache allowing to store files in the device persistent storage
class FileCacheManager {
  const FileCacheManager._();

  static FileCache? _temporaryCache;
  static FileCache? _longLivingCache;

  static FileCache get temporary {
    _temporaryCache ??= _ShortLivingFileCacheManagerImpl(
      subFolderName: 'temp',
    );

    return _temporaryCache!;
  }

  static FileCache get persistent {
    _longLivingCache ??= _LongLivingFilesCacheManagerImpl(
      subFolderName: 'files',
    );

    return _longLivingCache!;
  }
}
