part of '../exhibition_trade_pages.dart';

typedef ProjectAttachmentPicker = Future<ProjectAttachmentDraft?> Function();
typedef ProjectAttachmentExternalUrlOpener = Future<bool> Function(Uri uri);

const String _projectAttachmentBusinessType = 'project';
const String _projectAttachmentFileKind = 'project_attachment';
const String _projectAttachmentKindEffectImage = 'effect_image';
const String _projectAttachmentKindConstructionDoc = 'construction_doc';
const String _projectAttachmentKindOtherMaterial = 'other_material';

class ProjectAttachmentDraft {
  const ProjectAttachmentDraft({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

final class ProjectAttachmentDebugOverrides {
  const ProjectAttachmentDebugOverrides._();

  static ProjectAttachmentPicker? _pickerOverride;
  static ProjectAttachmentExternalUrlOpener? _externalUrlOpener;

  static void installPicker(ProjectAttachmentPicker? picker) {
    _pickerOverride = picker;
  }

  static void installExternalUrlOpener(
    ProjectAttachmentExternalUrlOpener? opener,
  ) {
    _externalUrlOpener = opener;
  }

  static void clearSession() {}

  static void reset() {
    _pickerOverride = null;
    _externalUrlOpener = null;
    clearSession();
  }
}

enum _ProjectAttachmentUploadUiStatus {
  idle,
  selecting,
  selectedReady,
  initStarting,
  initFailed,
  directUploading,
  directUploadFailed,
  confirming,
  confirmFailed,
  binding,
  bindFailed,
  bindSucceeded,
  unsupportedType,
}

class _ResolvedProjectAttachmentDraft {
  const _ResolvedProjectAttachmentDraft({
    required this.fileName,
    required this.bytes,
    required this.extension,
    required this.mimeType,
    required this.checksum,
  });

  final String fileName;
  final List<int> bytes;
  final String extension;
  final String mimeType;
  final String checksum;

  int get sizeInBytes => bytes.length;
}

class _ProjectAttachmentKindOption {
  const _ProjectAttachmentKindOption({
    required this.value,
    required this.label,
    required this.summary,
    required this.supportedTypes,
  });

  final String value;
  final String label;
  final String summary;
  final String supportedTypes;
}

const List<_ProjectAttachmentKindOption> _projectAttachmentKindOptions =
    <_ProjectAttachmentKindOption>[
      _ProjectAttachmentKindOption(
        value: _projectAttachmentKindEffectImage,
        label: '效果图（必传）',
        summary: '用于补充效果图或展示图；这是预发布详情里的必传附件，只接受图片文件。',
        supportedTypes: 'PNG / JPEG / WEBP',
      ),
      _ProjectAttachmentKindOption(
        value: _projectAttachmentKindOtherMaterial,
        label: '材质图（选传）',
        summary: '用于补充材质、工艺或现场参考资料，接受图片或文档。',
        supportedTypes: 'PNG / JPEG / WEBP / PDF / DOC / DOCX',
      ),
      _ProjectAttachmentKindOption(
        value: _projectAttachmentKindConstructionDoc,
        label: '尺寸图（选传）',
        summary: '用于补充尺寸、施工尺寸或平立面尺寸文档，只接受文档文件。',
        supportedTypes: 'PDF / DOC / DOCX',
      ),
    ];

Future<ProjectAttachmentDraft?> _pickProjectAttachmentDraft() async {
  final override = ProjectAttachmentDebugOverrides._pickerOverride;
  if (override != null) {
    return override();
  }

  final file = await openFile();
  if (file == null) {
    return null;
  }

  return ProjectAttachmentDraft(
    fileName: file.name,
    bytes: await file.readAsBytes(),
  );
}

_ResolvedProjectAttachmentDraft? _resolveProjectAttachmentDraft(
  ProjectAttachmentDraft draft,
) {
  final extension = _projectAttachmentExtension(draft.fileName);
  final mimeType = _projectAttachmentMimeType(extension);
  if (extension == null || mimeType == null) {
    return null;
  }

  return _ResolvedProjectAttachmentDraft(
    fileName: draft.fileName,
    bytes: draft.bytes,
    extension: extension,
    mimeType: mimeType,
    checksum: sha256.convert(draft.bytes).toString(),
  );
}

String? _projectAttachmentExtension(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  final dotIndex = normalized.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == normalized.length - 1) {
    return null;
  }

  final extension = normalized.substring(dotIndex + 1);
  return switch (extension) {
    'png' || 'jpg' || 'jpeg' || 'webp' || 'pdf' || 'doc' || 'docx' => extension,
    _ => null,
  };
}

String? _projectAttachmentMimeType(String? extension) {
  return switch (extension) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ => null,
  };
}

String _projectAttachmentFileTypeLabel(String extension) {
  return switch (extension) {
    'png' => 'PNG 图片',
    'jpg' || 'jpeg' => 'JPEG 图片',
    'webp' => 'WEBP 图片',
    'pdf' => 'PDF 文档',
    'doc' => 'DOC 文档',
    'docx' => 'DOCX 文档',
    _ => extension.toUpperCase(),
  };
}

String _projectAttachmentMimeTypeLabel(String mimeType) {
  return switch (mimeType) {
    'image/png' => 'PNG 图片',
    'image/jpeg' => 'JPEG 图片',
    'image/webp' => 'WEBP 图片',
    'application/pdf' => 'PDF 文档',
    'application/msword' => 'DOC 文档',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      'DOCX 文档',
    _ => mimeType,
  };
}

String _projectAttachmentKindLabel(String attachmentKind) {
  return switch (attachmentKind) {
    _projectAttachmentKindEffectImage => '效果图',
    _projectAttachmentKindConstructionDoc => '尺寸图',
    _projectAttachmentKindOtherMaterial => '材质图',
    _ => attachmentKind,
  };
}

String _projectAttachmentChooseActionLabel(String attachmentKind) {
  return switch (attachmentKind) {
    _projectAttachmentKindEffectImage => '选择效果图',
    _projectAttachmentKindConstructionDoc => '选择尺寸图',
    _projectAttachmentKindOtherMaterial => '选择材质图',
    _ => '选择项目附件',
  };
}

String _projectAttachmentVisibilityLabel(String visibility) {
  return switch (visibility) {
    'owner_private' => '仅 owner 私域可见',
    _ => visibility,
  };
}

String _projectAttachmentSizeLabel(int sizeInBytes) {
  if (sizeInBytes < 1024) {
    return '$sizeInBytes B';
  }
  if (sizeInBytes < 1024 * 1024) {
    return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
  }

  return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _projectAttachmentUploadErrorMessage(
  _ProjectAttachmentUploadUiStatus status,
) {
  return switch (status) {
    _ProjectAttachmentUploadUiStatus.initFailed => '当前附件上传初始化未完成，请稍后重试。',
    _ProjectAttachmentUploadUiStatus.directUploadFailed =>
      '当前附件直传未完成，请重新上传当前附件。',
    _ProjectAttachmentUploadUiStatus.confirmFailed => '当前附件确认结果未完成，请再次确认或重新上传。',
    _ProjectAttachmentUploadUiStatus.bindFailed => '当前附件还没有形成正式项目附件，请重新绑定。',
    _ => '',
  };
}

ProjectPublicResourceFileAccessReadModel?
_projectAttachmentFileAccessFromPayload(Object? payload) {
  try {
    return ProjectPublicResourceFileAccessReadModel.fromPayload(payload);
  } on FormatException {
    return null;
  }
}

String _projectAttachmentUnsupportedTypeMessage(String attachmentKind) {
  return switch (attachmentKind) {
    _projectAttachmentKindEffectImage => '效果图只支持 PNG、JPEG、WEBP 图片。',
    _projectAttachmentKindConstructionDoc => '尺寸图只支持 PDF、DOC、DOCX 文件。',
    _projectAttachmentKindOtherMaterial => '材质图只支持图片、PDF、DOC、DOCX 文件。',
    _ => '当前文件类型暂不支持。',
  };
}

bool _projectAttachmentKindMatchesMimeType(String kind, String mimeType) {
  final isImage = mimeType.startsWith('image/');
  final isDocument =
      mimeType == 'application/pdf' ||
      mimeType == 'application/msword' ||
      mimeType ==
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  return switch (kind) {
    _projectAttachmentKindEffectImage => isImage,
    _projectAttachmentKindConstructionDoc => isDocument,
    _projectAttachmentKindOtherMaterial => isImage || isDocument,
    _ => false,
  };
}

bool _projectAttachmentIsImageMimeType(String mimeType) {
  return mimeType.startsWith('image/');
}

bool _projectAttachmentCanOpenLocally(String mimeType) {
  return _projectAttachmentIsImageMimeType(mimeType) ||
      _projectAttachmentKindMatchesMimeType(
        _projectAttachmentKindConstructionDoc,
        mimeType,
      );
}

String _projectAttachmentAccessMode(String mimeType) {
  return _projectAttachmentCanOpenLocally(mimeType) ? 'preview' : 'download';
}

String _projectAttachmentDraftPreviewButtonLabel(String mimeType) {
  return _projectAttachmentIsImageMimeType(mimeType) ? '预览当前图片' : '在系统中打开';
}

String _projectAttachmentRecordPreviewButtonLabel(String mimeType) {
  return _projectAttachmentIsImageMimeType(mimeType) ? '预览图片' : '预览文书';
}

int _projectAttachmentNextSortOrder(List<ProjectAttachmentReadModel> items) {
  if (items.isEmpty) {
    return 0;
  }

  final maxSortOrder = items
      .map((ProjectAttachmentReadModel item) => item.sortOrder)
      .reduce((int left, int right) => left > right ? left : right);
  return maxSortOrder + 1;
}

ProjectAttachmentListReadModel? _projectAttachmentListFromPayload(
  Object? payload,
) {
  try {
    return ProjectAttachmentListReadModel.fromPayload(payload);
  } on FormatException {
    return null;
  }
}

String _projectAttachmentTimestampLabel(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return raw;
  }

  final local = parsed.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

String _projectAttachmentListFailureMessage(ExhibitionLoadResult result) {
  if (_projectAttachmentRouteMissingMessage(result.message)
      case final String message) {
    return message;
  }

  return switch (result.state) {
    AppPageState.unauthorized => '当前登录状态不可继续补资料，请重新登录后再试。',
    AppPageState.forbidden => '当前主体暂不可继续补资料。',
    AppPageState.notFound => '当前项目详情文书区暂未返回可读内容。',
    _ =>
      result.message ==
              'current fake transport did not provide this canonical path'
          ? '当前项目详情文书区暂未接通读侧。'
          : '当前项目详情文书列表读取失败，请稍后重试。',
  };
}

String _projectAttachmentBindFailureMessage(
  ExhibitionActionResult result, {
  required String fileName,
}) {
  final rawMessage = result.message;
  if (_projectAttachmentRouteMissingMessage(rawMessage)
      case final String message) {
    return message;
  }
  // Keep the backend-provided Chinese business reason when available so bind
  // failures are not flattened back into a generic "未完成" fallback.
  if (_isNormalizedChineseBusinessMessage(rawMessage)) {
    return rawMessage!;
  }

  return switch (result.errorCode) {
    'AUTH_SESSION_INVALID' => '当前登录状态已失效，请重新登录后再试。',
    'PROJECT_ATTACHMENT_FORBIDDEN' => '当前账号没有权限补充该项目资料。',
    'PROJECT_ATTACHMENT_DUPLICATE' => '当前资料已存在，请勿重复补充。',
    'PROJECT_ATTACHMENT_UNAVAILABLE' => '当前项目资料补充入口暂不可用，请稍后再试。',
    _ =>
      rawMessage == 'current fake transport did not provide this canonical path'
          ? '当前项目详情文书区暂未接通写入。'
          : '$fileName 尚未形成项目详情文书，请稍后重试。',
  };
}

String? _projectAttachmentRouteMissingMessage(String? rawMessage) {
  final normalized = rawMessage?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  if (RegExp(
    r'^Cannot GET /api/app/my/projects/[^/]+/attachments$',
  ).hasMatch(normalized)) {
    return '当前云端 BFF 尚未部署项目附件读侧路由，请先同步云端后再试。';
  }

  if (RegExp(
    r'^Cannot POST /api/app/my/projects/[^/]+/attachments$',
  ).hasMatch(normalized)) {
    return '当前云端 BFF 尚未部署项目附件写入路由，请先同步云端后再试。';
  }

  if (RegExp(
    r'^Cannot DELETE /api/app/my/projects/[^/]+/attachments/[^/]+$',
  ).hasMatch(normalized)) {
    return '当前云端 BFF 尚未部署项目附件删除路由，请先同步云端后再试。';
  }

  return null;
}

String _projectAttachmentFileAccessFailureMessage(
  ExhibitionActionResult result,
) {
  final rawMessage = result.message;
  if (_isNormalizedChineseBusinessMessage(rawMessage)) {
    return rawMessage!;
  }
  if (rawMessage ==
      'current fake transport did not provide this canonical path') {
    return '当前文书预览服务暂未接通。';
  }

  return switch (result.errorCode) {
    'AUTH_SESSION_INVALID' => '当前登录状态已失效，请重新登录后再试。',
    'FILE_ACCESS_INVALID' => '当前文书预览参数不可用，请稍后再试。',
    'FILE_ACCESS_FAILED' => '当前文书预览服务暂不可用，请稍后再试。',
    'FILE_ACCESS_NOT_FOUND' => '当前文书不存在或暂不可预览。',
    'FILE_ACCESS_PERMISSION_DENIED' => '当前账号暂不可预览这份文书。',
    'FILE_ACCESS_UNAVAILABLE' => '当前文书预览服务暂不可用，请稍后再试。',
    _ => '当前文书预览服务暂不可用，请稍后再试。',
  };
}

Future<bool> _openProjectAttachmentUrl(String accessUrl) async {
  final uri = Uri.tryParse(accessUrl);
  if (uri == null || uri.scheme.isEmpty) {
    return false;
  }

  final override = ProjectAttachmentDebugOverrides._externalUrlOpener;
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

Future<File> _writeProjectAttachmentPreviewTempFile({
  required String fileName,
  required List<int> bytes,
}) async {
  final safeName = fileName.trim().replaceAll(
    RegExp(r'[\\/\u0000-\u001F]'),
    '_',
  );
  final resolvedName = safeName.isEmpty ? 'project-attachment.bin' : safeName;
  final file = File(
    '${Directory.systemTemp.path}/project-attachment-preview-${DateTime.now().microsecondsSinceEpoch}-$resolvedName',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Future<bool> _openProjectAttachmentLocalFile(String path) async {
  try {
    if (Platform.isMacOS) {
      final result = await Process.run('open', <String>[path]);
      return result.exitCode == 0;
    }
    if (Platform.isLinux) {
      final result = await Process.run('xdg-open', <String>[path]);
      return result.exitCode == 0;
    }
    if (Platform.isWindows) {
      final result = await Process.run('cmd', <String>[
        '/c',
        'start',
        '',
        path,
      ]);
      return result.exitCode == 0;
    }
  } on ProcessException {
    return false;
  }
  return false;
}

String _projectAttachmentDeleteFailureMessage(ExhibitionActionResult result) {
  return switch (result.errorCode) {
    'PROJECT_ATTACHMENT_NOT_FOUND' => '当前附件不存在或已删除。',
    'PROJECT_ATTACHMENT_PERMISSION_DENIED' => '当前主体暂不可删除该附件。',
    _ =>
      result.message ==
              'current fake transport did not provide this canonical path'
          ? '当前项目详情文书区暂未接通删除。'
          : '当前文书删除未完成，请稍后重试。',
  };
}
