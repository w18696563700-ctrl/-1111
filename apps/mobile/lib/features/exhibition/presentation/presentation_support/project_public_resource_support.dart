part of '../exhibition_trade_pages.dart';

typedef ProjectPublicResourceExternalUrlOpener = Future<bool> Function(Uri uri);

const String _projectPublicResourceCategoryContractTemplate =
    'contract_template';
const String _projectPublicResourceCategoryProcessGuide = 'process_guide';
const String _projectPublicResourceCategoryOtherResource = 'other_resource';

final class ProjectPublicResourceDebugOverrides {
  const ProjectPublicResourceDebugOverrides._();

  static ProjectPublicResourceExternalUrlOpener? _externalUrlOpener;

  static void installExternalUrlOpener(
    ProjectPublicResourceExternalUrlOpener? opener,
  ) {
    _externalUrlOpener = opener;
  }

  static void reset() {
    _externalUrlOpener = null;
  }
}

class _ProjectPublicResourceCategoryOption {
  const _ProjectPublicResourceCategoryOption({
    required this.value,
    required this.label,
    required this.summary,
  });

  final String value;
  final String label;
  final String summary;
}

const List<_ProjectPublicResourceCategoryOption>
_projectPublicResourceCategoryOptions = <_ProjectPublicResourceCategoryOption>[
  _ProjectPublicResourceCategoryOption(
    value: _projectPublicResourceCategoryContractTemplate,
    label: '合同模板',
    summary: '用于承接平台共享合同模板资料，只提供下载，不提供上传或删除。',
  ),
  _ProjectPublicResourceCategoryOption(
    value: _projectPublicResourceCategoryProcessGuide,
    label: '流程图与说明',
    summary: '用于承接流程图与说明资料，帮助理解项目发布与续接过程。',
  ),
  _ProjectPublicResourceCategoryOption(
    value: _projectPublicResourceCategoryOtherResource,
    label: '公共资料',
    summary: '用于承接平台共享公共资料，不替代项目详情文书区。',
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
    return '这次公共资源目录读取超时了。你可以稍后重新读取；这不代表项目详情文书区不可用。';
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
    'FILE_ACCESS_NOT_FOUND' => '当前资料不存在或暂不可下载。',
    'FILE_ACCESS_PERMISSION_DENIED' => '当前账号暂不可下载这份资料。',
    'FILE_ACCESS_UNAVAILABLE' => '当前资料暂不可下载，请稍后再试。',
    _ => switch (result.controlledState) {
      AppPageState.unauthorized => '当前登录态不可用，请重新登录或刷新后再试。',
      AppPageState.forbidden => '当前账号暂不可下载这份资料。',
      AppPageState.notFound => '当前资料不存在或暂不可下载。',
      _ => '当前资料暂不可下载，请稍后再试。',
    },
  };
}

Future<bool> _openProjectPublicResourceUrl(String accessUrl) async {
  final uri = Uri.tryParse(accessUrl);
  if (uri == null || uri.scheme.isEmpty) {
    return false;
  }

  final override = ProjectPublicResourceDebugOverrides._externalUrlOpener;
  if (override != null) {
    return override(uri);
  }

  try {
    if (Platform.isMacOS) {
      final result = await Process.run('open', <String>[uri.toString()]);
      return result.exitCode == 0;
    }
    if (Platform.isLinux) {
      final result = await Process.run('xdg-open', <String>[uri.toString()]);
      return result.exitCode == 0;
    }
    if (Platform.isWindows) {
      final result = await Process.run('cmd', <String>[
        '/c',
        'start',
        '',
        uri.toString(),
      ]);
      return result.exitCode == 0;
    }
  } on ProcessException {
    return false;
  }

  return false;
}
