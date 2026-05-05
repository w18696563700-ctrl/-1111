part of '../exhibition_trade_pages.dart';

typedef ProjectPublicResourceLocalDownloader =
    Future<ProjectPublicResourceDownloadedFile?> Function(
      ProjectPublicResourceFileAccessReadModel access,
      ProjectPublicResourceReadModel resource,
    );
typedef ProjectPublicResourceDownloadedFileAction =
    Future<bool> Function(ProjectPublicResourceDownloadedFile file);

final class ProjectPublicResourceDownloadedFile {
  const ProjectPublicResourceDownloadedFile({
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
}

const String _projectPublicResourceCategoryContractTemplate =
    'contract_template';
const String _projectPublicResourceCategoryProcessGuide = 'process_guide';
const String _projectPublicResourceCategoryOtherResource = 'other_resource';

final class ProjectPublicResourceDebugOverrides {
  const ProjectPublicResourceDebugOverrides._();

  static ProjectPublicResourceLocalDownloader? _localDownloader;
  static ProjectPublicResourceDownloadedFileAction? _localFileOpener;
  static ProjectPublicResourceDownloadedFileAction? _localFileSharer;

  static void installLocalDownloader(
    ProjectPublicResourceLocalDownloader? downloader,
  ) {
    _localDownloader = downloader;
  }

  static void installLocalFileOpener(
    ProjectPublicResourceDownloadedFileAction? opener,
  ) {
    _localFileOpener = opener;
  }

  static void installLocalFileSharer(
    ProjectPublicResourceDownloadedFileAction? sharer,
  ) {
    _localFileSharer = sharer;
  }

  static void reset() {
    _localDownloader = null;
    _localFileOpener = null;
    _localFileSharer = null;
  }
}

class _ProjectPublicResourceCategoryOption {
  const _ProjectPublicResourceCategoryOption({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

const List<_ProjectPublicResourceCategoryOption>
_projectPublicResourceCategoryOptions = <_ProjectPublicResourceCategoryOption>[
  _ProjectPublicResourceCategoryOption(
    value: _projectPublicResourceCategoryContractTemplate,
    label: '合同模板',
  ),
  _ProjectPublicResourceCategoryOption(
    value: _projectPublicResourceCategoryProcessGuide,
    label: '流程图与说明',
  ),
  _ProjectPublicResourceCategoryOption(
    value: _projectPublicResourceCategoryOtherResource,
    label: '公共资料',
  ),
];

ProjectPublicResourceCatalogReadModel? _projectPublicResourceCatalogFromPayload(
  Object? payload,
) {
  try {
    return ProjectPublicResourceCatalogReadModel.fromPayload(payload);
  } on FormatException {
    return null;
  }
}

ProjectPublicResourceFileAccessReadModel?
_projectPublicResourceFileAccessFromPayload(Object? payload) {
  try {
    return ProjectPublicResourceFileAccessReadModel.fromPayload(payload);
  } on FormatException {
    return null;
  }
}

String _projectPublicResourceCategoryLabel(String resourceCategory) {
  return switch (resourceCategory) {
    _projectPublicResourceCategoryContractTemplate => '合同模板',
    _projectPublicResourceCategoryProcessGuide => '流程图与说明',
    _projectPublicResourceCategoryOtherResource => '公共资料',
    _ => resourceCategory,
  };
}

Map<String, int> _projectPublicResourceCategoryCounts(
  List<ProjectPublicResourceReadModel> resources,
) {
  final counts = <String, int>{
    for (final option in _projectPublicResourceCategoryOptions) option.value: 0,
  };
  for (final resource in resources) {
    counts[resource.resourceCategory] =
        (counts[resource.resourceCategory] ?? 0) + 1;
  }
  return counts;
}

String _projectPublicResourceVisibilityLabel(String visibility) {
  return switch (visibility) {
    'app_shared' => '平台共享资料',
    _ => visibility,
  };
}

bool _projectPublicResourceIsTimeoutMessage(String? message) {
  final normalized = message?.toLowerCase() ?? '';
  return normalized.contains('request timed out');
}

bool _projectPublicResourceIsTimeoutResult(ExhibitionLoadResult? result) {
  return result?.state == AppPageState.errorRetryable &&
      _projectPublicResourceIsTimeoutMessage(result?.message);
}

String _projectPublicResourceLoadFailureTitle(ExhibitionLoadResult result) {
  return _projectPublicResourceIsTimeoutResult(result)
      ? '当前公共资源目录读取超时'
      : '当前公共资源下载区暂不可用';
}

String _projectPublicResourceLoadFailureMessage(ExhibitionLoadResult result) {
  if (_projectPublicResourceIsTimeoutResult(result)) {
    return '这次公共资源目录读取超时了。你可以稍后重新读取；这不代表报价依据资料不可用。';
  }

  final rawMessage = result.message;
  if (_isNormalizedChineseBusinessMessage(rawMessage)) {
    return rawMessage!;
  }
  if (rawMessage ==
      'current fake transport did not provide this canonical path') {
    return '当前公共资源目录暂未接通读侧。';
  }

  return switch (result.state) {
    AppPageState.unauthorized => '当前登录态不可用，请重新登录或刷新后再试。',
    AppPageState.forbidden => '当前账号暂不可访问公共资源目录。',
    AppPageState.notFound => '当前公共资源目录暂不可用，请稍后再试。',
    _ => '当前公共资源目录暂不可用，请稍后再试。',
  };
}

String _projectPublicResourceDownloadFailureMessage(
  ExhibitionActionResult result,
) {
  final rawMessage = result.message;
  if (_projectPublicResourceIsTimeoutMessage(rawMessage)) {
    return '当前下载请求超时，请稍后重试。';
  }
  if (_isNormalizedChineseBusinessMessage(rawMessage)) {
    return rawMessage!;
  }
  if (rawMessage ==
      'current fake transport did not provide this canonical path') {
    return '当前下载服务暂未接通。';
  }

  return switch (result.errorCode) {
    'AUTH_SESSION_INVALID' => '当前登录态不可用，请重新登录或刷新后再试。',
    'FILE_ACCESS_INVALID' => '当前下载资料参数不可用，请稍后再试。',
    'FILE_ACCESS_NOT_FOUND' => '资料文件暂不可下载，请稍后重试。',
    'FILE_ACCESS_PERMISSION_DENIED' => '当前账号暂不可下载这份资料。',
    'FILE_ACCESS_UNAVAILABLE' => '资料文件暂不可下载，请稍后重试。',
    _ => switch (result.controlledState) {
      AppPageState.unauthorized => '当前登录态不可用，请重新登录或刷新后再试。',
      AppPageState.forbidden => '当前账号暂不可下载这份资料。',
      AppPageState.notFound => '资料文件暂不可下载，请稍后重试。',
      _ => '资料文件暂不可下载，请稍后重试。',
    },
  };
}

Future<ProjectPublicResourceDownloadedFile?>
_downloadProjectPublicResourceFile({
  required ProjectPublicResourceFileAccessReadModel access,
  required ProjectPublicResourceReadModel resource,
}) async {
  final override = ProjectPublicResourceDebugOverrides._localDownloader;
  if (override != null) {
    return override(access, resource);
  }

  final uri = Uri.tryParse(access.accessUrl);
  if (uri == null || uri.scheme.isEmpty) {
    return null;
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  try {
    final request = await client.getUrl(uri);
    final response = await request.close().timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    if (bytes.isEmpty) {
      return null;
    }

    final directory = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/public_resources',
    );
    await directory.create(recursive: true);
    final fileName = _projectPublicResourceSafeFileName(
      access.fileName ?? resource.fileName,
      fallbackTitle: resource.title,
      mimeType: access.mimeType ?? resource.mimeType,
    );
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return ProjectPublicResourceDownloadedFile(
      path: file.path,
      fileName: fileName,
      mimeType: access.mimeType ?? resource.mimeType,
      sizeBytes: bytes.length,
    );
  } on TimeoutException {
    return null;
  } on IOException {
    return null;
  } finally {
    client.close(force: true);
  }
}

String _projectPublicResourceSafeFileName(
  String? rawFileName, {
  required String fallbackTitle,
  required String? mimeType,
}) {
  final source = (rawFileName?.trim().isNotEmpty == true
      ? rawFileName!.trim()
      : fallbackTitle.trim().isNotEmpty
      ? fallbackTitle.trim()
      : 'public-resource');
  final collapsed = source
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final limited = collapsed.length > 80
      ? collapsed.substring(0, 80)
      : collapsed;
  final withFallback = limited.isEmpty ? 'public-resource' : limited;
  if (withFallback.contains('.')) {
    return withFallback;
  }
  return '$withFallback${_projectPublicResourceFileExtension(mimeType)}';
}

String _projectPublicResourceFileExtension(String? mimeType) {
  return switch (mimeType) {
    'application/pdf' => '.pdf',
    'application/msword' => '.doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      '.docx',
    'image/png' => '.png',
    'image/jpeg' => '.jpg',
    'image/webp' => '.webp',
    _ => '.bin',
  };
}

String _projectPublicResourceFileSizeLabel(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  final kb = bytes / 1024;
  if (kb < 1024) {
    return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';
  }
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(mb >= 100 ? 0 : 1)} MB';
}

Future<bool> _openDownloadedProjectPublicResourceFile(
  ProjectPublicResourceDownloadedFile file,
) async {
  final override = ProjectPublicResourceDebugOverrides._localFileOpener;
  if (override != null) {
    return override(file);
  }
  final result = await FileOpenCoordinator.instance.openPath(
    path: file.path,
    mimeType: file.mimeType,
  );
  return result.opened;
}

Future<bool> _shareDownloadedProjectPublicResourceFile(
  BuildContext context,
  ProjectPublicResourceDownloadedFile file,
) async {
  final override = ProjectPublicResourceDebugOverrides._localFileSharer;
  if (override != null) {
    return override(file);
  }
  try {
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : null;
    final result = await SharePlus.instance.share(
      ShareParams(
        title: file.fileName,
        files: <XFile>[
          XFile(file.path, mimeType: file.mimeType, name: file.fileName),
        ],
        fileNameOverrides: <String>[file.fileName],
        sharePositionOrigin: origin,
      ),
    );
    return result.status != ShareResultStatus.unavailable;
  } on PlatformException {
    return false;
  } on ArgumentError {
    return false;
  } on IOException {
    return false;
  }
}

Future<void> _showProjectPublicResourceDownloadedSheet({
  required BuildContext context,
  required ProjectPublicResourceDownloadedFile file,
  required ValueChanged<String> onMessage,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '下载完成',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                file.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '已保存到 App 本地 · ${_projectPublicResourceFileSizeLabel(file.sizeBytes)}',
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        final opened =
                            await _openDownloadedProjectPublicResourceFile(
                              file,
                            );
                        onMessage(opened ? '已打开下载资料。' : '当前设备暂不能直接打开该资料。');
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('打开'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        final shared =
                            await _shareDownloadedProjectPublicResourceFile(
                              context,
                              file,
                            );
                        onMessage(
                          shared ? '已打开系统分享/保存面板。' : '当前设备暂不能打开保存面板，请稍后重试。',
                        );
                      },
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('保存 / 分享'),
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
