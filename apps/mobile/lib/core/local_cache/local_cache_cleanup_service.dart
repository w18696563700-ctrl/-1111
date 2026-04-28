import 'dart:io';

import 'package:flutter/painting.dart';

class LocalCacheCleanupResult {
  const LocalCacheCleanupResult({
    required this.imageCacheCleared,
    required this.deletedTemporaryFiles,
    required this.failedTemporaryFiles,
  });

  final bool imageCacheCleared;
  final int deletedTemporaryFiles;
  final int failedTemporaryFiles;

  String get summary {
    if (failedTemporaryFiles > 0) {
      return '已清理图片缓存和 $deletedTemporaryFiles 个临时预览文件，$failedTemporaryFiles 个文件稍后由系统回收。';
    }
    if (deletedTemporaryFiles > 0) {
      return '已清理图片缓存和 $deletedTemporaryFiles 个临时预览文件。';
    }
    return '已清理图片缓存，当前没有可清理的临时预览文件。';
  }
}

class LocalCacheCleanupService {
  LocalCacheCleanupService();

  static const List<String> _safeTemporaryPrefixes = <String>[
    'project-attachment-preview-',
    'forum-preview-',
  ];

  static LocalCacheCleanupService _instance = LocalCacheCleanupService();

  static LocalCacheCleanupService get instance => _instance;

  static void install(LocalCacheCleanupService service) {
    _instance = service;
  }

  static void reset() {
    _instance = LocalCacheCleanupService();
  }

  Future<LocalCacheCleanupResult> clearSafeLocalCache() async {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();

    var deleted = 0;
    var failed = 0;
    final tempDir = Directory.systemTemp;
    if (!await tempDir.exists()) {
      return const LocalCacheCleanupResult(
        imageCacheCleared: true,
        deletedTemporaryFiles: 0,
        failedTemporaryFiles: 0,
      );
    }

    await for (final entity in tempDir.list(followLinks: false)) {
      final name = entity.uri.pathSegments.isEmpty
          ? ''
          : entity.uri.pathSegments.last;
      if (!_safeTemporaryPrefixes.any(name.startsWith)) {
        continue;
      }

      try {
        await entity.delete(recursive: entity is Directory);
        deleted += 1;
      } on FileSystemException {
        failed += 1;
      }
    }

    return LocalCacheCleanupResult(
      imageCacheCleared: true,
      deletedTemporaryFiles: deleted,
      failedTemporaryFiles: failed,
    );
  }
}
