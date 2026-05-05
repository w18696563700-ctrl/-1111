part of '../exhibition_trade_pages.dart';

final class _ProjectAlbumSavedPhotoFile {
  const _ProjectAlbumSavedPhotoFile({
    required this.path,
    required this.mimeType,
  });

  final String path;
  final String? mimeType;
}

Future<_ProjectAlbumSavedPhotoFile?> _downloadProjectAlbumPhotoToLocal({
  required String accessUrl,
  required ProjectAlbumPhotoView photo,
  required ProjectCommunicationFilePreviewAccessView access,
}) async {
  final bytes = await _loadProjectAttachmentRemoteBytes(
    accessUrl,
    maxBytes: _projectAttachmentRemoteFilePreviewMaxBytes,
  );
  if (bytes == null || bytes.isEmpty) {
    return null;
  }
  final directory = Directory(
    '${(await getApplicationDocumentsDirectory()).path}/project_album',
  );
  await directory.create(recursive: true);
  final mimeType = access.mimeType ?? photo.mimeType;
  final fileName = _projectAlbumSafeLocalFileName(
    photoId: photo.photoId,
    mimeType: mimeType,
  );
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return _ProjectAlbumSavedPhotoFile(path: file.path, mimeType: mimeType);
}

Future<void> _showProjectAlbumSavedSheet(
  BuildContext context, {
  required _ProjectAlbumSavedPhotoFile file,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '已保存到本地',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '相册照片已保存到本地缓存，可打开查看或通过系统面板另存。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final opened = await _openProjectAttachmentLocalFile(
                          file.path,
                          mimeType: file.mimeType,
                        );
                        if (!sheetContext.mounted) {
                          return;
                        }
                        if (!opened) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('当前图片暂无法打开。')),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('打开'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final shared = await _shareProjectAlbumSavedPhoto(
                          sheetContext,
                          file,
                        );
                        if (!sheetContext.mounted) {
                          return;
                        }
                        if (!shared) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('当前图片暂无法分享另存。')),
                          );
                        }
                      },
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('分享/另存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> _shareProjectAlbumSavedPhoto(
  BuildContext context,
  _ProjectAlbumSavedPhotoFile file,
) async {
  try {
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : null;
    final result = await SharePlus.instance.share(
      ShareParams(
        title: '项目相册照片',
        files: <XFile>[
          XFile(file.path, mimeType: file.mimeType, name: '项目相册照片'),
        ],
        fileNameOverrides: const <String>['项目相册照片'],
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.unavailable;
  } on PlatformException {
    return false;
  }
}

String _projectAlbumSafeLocalFileName({
  required String photoId,
  required String? mimeType,
}) {
  final normalizedPhotoId = photoId.trim().replaceAll(
    RegExp(r'[\\/:*?"<>|\x00-\x1F]'),
    '_',
  );
  final baseName = normalizedPhotoId.isEmpty
      ? 'project-album-photo'
      : 'project-album-$normalizedPhotoId';
  return '$baseName${_projectAlbumFileExtension(mimeType)}';
}

String _projectAlbumFileExtension(String? mimeType) {
  return switch (mimeType) {
    'image/png' => '.png',
    'image/jpeg' => '.jpg',
    'image/webp' => '.webp',
    _ => '.bin',
  };
}
