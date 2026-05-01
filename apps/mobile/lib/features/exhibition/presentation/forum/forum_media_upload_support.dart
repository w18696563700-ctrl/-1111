part of 'forum_pages.dart';

typedef ForumPublishMediaPicker =
    Future<List<ForumPublishMediaDraft>> Function(ForumPublishMediaType type);

class ForumPublishMediaDraft {
  const ForumPublishMediaDraft({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

final class ForumPublishMediaDebugOverrides {
  const ForumPublishMediaDebugOverrides._();

  static ForumPublishMediaPicker? _pickerOverride;

  static void installPicker(ForumPublishMediaPicker? picker) {
    _pickerOverride = picker;
  }

  static void reset() {
    _pickerOverride = null;
  }
}

enum ForumPublishMediaType { image, video, file }

enum _ForumComposerMediaStage {
  selectedPending,
  initStarting,
  uploading,
  confirming,
  confirmedReady,
  draftBound,
  uploadFailed,
}

class _ForumResolvedMediaDraft {
  const _ForumResolvedMediaDraft({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
    required this.checksum,
    required this.mediaType,
  });

  final String fileName;
  final List<int> bytes;
  final String mimeType;
  final String checksum;
  final ForumPublishMediaType mediaType;

  int get sizeInBytes => bytes.length;
}

class _ForumResolvedMediaDraftResult {
  const _ForumResolvedMediaDraftResult._({this.draft, this.errorMessage});

  const _ForumResolvedMediaDraftResult.success(_ForumResolvedMediaDraft draft)
    : this._(draft: draft);

  const _ForumResolvedMediaDraftResult.failure(String errorMessage)
    : this._(errorMessage: errorMessage);

  final _ForumResolvedMediaDraft? draft;
  final String? errorMessage;
}

class _ForumComposerMediaItem {
  const _ForumComposerMediaItem({
    required this.localId,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    required this.checksum,
    required this.mediaType,
    required this.stage,
    this.directive,
    this.fileAssetId,
    this.statusMessage,
  });

  final String localId;
  final String fileName;
  final String mimeType;
  final List<int> bytes;
  final String checksum;
  final ForumPublishMediaType mediaType;
  final _ForumComposerMediaStage stage;
  final UploadDirective? directive;
  final String? fileAssetId;
  final String? statusMessage;

  int get sizeInBytes => bytes.length;

  bool get isTransferActive =>
      stage == _ForumComposerMediaStage.initStarting ||
      stage == _ForumComposerMediaStage.uploading ||
      stage == _ForumComposerMediaStage.confirming;

  bool get isConfirmed =>
      stage == _ForumComposerMediaStage.confirmedReady ||
      stage == _ForumComposerMediaStage.draftBound;

  bool get isBoundToDraft => stage == _ForumComposerMediaStage.draftBound;

  bool get canStartUpload =>
      stage == _ForumComposerMediaStage.selectedPending ||
      stage == _ForumComposerMediaStage.uploadFailed;

  _ForumComposerMediaItem copyWith({
    _ForumComposerMediaStage? stage,
    UploadDirective? directive,
    Object? fileAssetId = _forumMediaNoChange,
    Object? statusMessage = _forumMediaNoChange,
  }) {
    return _ForumComposerMediaItem(
      localId: localId,
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
      checksum: checksum,
      mediaType: mediaType,
      stage: stage ?? this.stage,
      directive: directive ?? this.directive,
      fileAssetId: identical(fileAssetId, _forumMediaNoChange)
          ? this.fileAssetId
          : fileAssetId as String?,
      statusMessage: identical(statusMessage, _forumMediaNoChange)
          ? this.statusMessage
          : statusMessage as String?,
    );
  }
}

const Object _forumMediaNoChange = Object();
const String _forumAttachmentBusinessType = 'forum_draft_attachment';
const String _forumAttachmentFileKind = 'media';
const int _forumDocumentMaxSizeInBytes = 20 * 1024 * 1024;

Future<List<ForumPublishMediaDraft>> _pickForumPublishMedia(
  ForumPublishMediaType type,
) async {
  final override = ForumPublishMediaDebugOverrides._pickerOverride;
  if (override != null) {
    return override(type);
  }

  if (type == ForumPublishMediaType.image) {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return const <ForumPublishMediaDraft>[];
    }
    return <ForumPublishMediaDraft>[
      ForumPublishMediaDraft(
        fileName: _forumImagePickerFileName(image),
        bytes: await image.readAsBytes(),
      ),
    ];
  }

  final selected = await openFile(
    acceptedTypeGroups: <XTypeGroup>[
      switch (type) {
        ForumPublishMediaType.image => const XTypeGroup(
          label: '论坛图片',
          extensions: <String>['jpg', 'jpeg', 'png', 'webp', 'gif'],
          uniformTypeIdentifiers: <String>['public.image'],
        ),
        ForumPublishMediaType.video => const XTypeGroup(
          label: '论坛视频',
          extensions: <String>['mp4', 'mov', 'm4v', 'webm'],
          uniformTypeIdentifiers: <String>['public.movie', 'public.video'],
        ),
        ForumPublishMediaType.file => const XTypeGroup(
          label: '论坛文件',
          extensions: <String>[
            'pdf',
            'txt',
            'doc',
            'docx',
            'xls',
            'xlsx',
            'ppt',
            'pptx',
          ],
          uniformTypeIdentifiers: <String>[
            'com.adobe.pdf',
            'public.plain-text',
            'com.microsoft.word.doc',
            'org.openxmlformats.wordprocessingml.document',
            'com.microsoft.excel.xls',
            'org.openxmlformats.spreadsheetml.sheet',
            'com.microsoft.powerpoint.ppt',
            'org.openxmlformats.presentationml.presentation',
          ],
        ),
      },
    ],
    confirmButtonText: switch (type) {
      ForumPublishMediaType.image => '选择图片',
      ForumPublishMediaType.video => '选择视频',
      ForumPublishMediaType.file => '选择文件',
    },
  );

  if (selected == null) {
    return const <ForumPublishMediaDraft>[];
  }
  return <ForumPublishMediaDraft>[
    ForumPublishMediaDraft(
      fileName: selected.name,
      bytes: await selected.readAsBytes(),
    ),
  ];
}

String _forumImagePickerFileName(XFile image) {
  final normalizedName = image.name.trim();
  if (normalizedName.isNotEmpty) {
    return normalizedName;
  }
  final normalizedPath = image.path.trim();
  if (normalizedPath.isNotEmpty) {
    final separatorIndex = normalizedPath.lastIndexOf(Platform.pathSeparator);
    final candidate = separatorIndex == -1
        ? normalizedPath
        : normalizedPath.substring(separatorIndex + 1);
    if (candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }
  return 'forum-image-${DateTime.now().millisecondsSinceEpoch}.jpg';
}

String _forumPickerOpenFailureMessage(ForumPublishMediaType type) {
  return switch (type) {
    ForumPublishMediaType.image => '当前设备暂时打不开图片选择器，请稍后再试',
    ForumPublishMediaType.video => '当前设备暂时打不开视频选择器，请稍后再试',
    ForumPublishMediaType.file => '当前设备暂时打不开文件选择器，请稍后再试',
  };
}

_ForumResolvedMediaDraftResult _resolveForumMediaDraft(
  ForumPublishMediaDraft draft,
  ForumPublishMediaType requestedType,
) {
  final fileName = draft.fileName.trim();
  final extension = _forumMediaExtension(fileName);
  final mimeType = _forumMediaMimeType(extension);
  if (extension == null || mimeType == null) {
    return _ForumResolvedMediaDraftResult.failure(
      _unsupportedForumAttachmentMessage(requestedType),
    );
  }

  if (requestedType == ForumPublishMediaType.image &&
      !mimeType.startsWith('image/')) {
    return const _ForumResolvedMediaDraftResult.failure(
      '当前只支持 JPG、PNG、WEBP、GIF 图片',
    );
  }
  if (requestedType == ForumPublishMediaType.video &&
      !mimeType.startsWith('video/')) {
    return const _ForumResolvedMediaDraftResult.failure(
      '当前只支持 MP4、MOV、M4V、WEBM 视频',
    );
  }
  if (requestedType == ForumPublishMediaType.file &&
      !_isForumDocumentMimeType(mimeType)) {
    return const _ForumResolvedMediaDraftResult.failure(
      '论坛附件目前只支持图片、视频以及 PDF/文档文件。',
    );
  }
  if (requestedType == ForumPublishMediaType.file &&
      draft.bytes.length > _forumDocumentMaxSizeInBytes) {
    return const _ForumResolvedMediaDraftResult.failure(
      '论坛文档附件单个文件不能超过 20 MiB。',
    );
  }

  return _ForumResolvedMediaDraftResult.success(
    _ForumResolvedMediaDraft(
      fileName: fileName,
      bytes: draft.bytes,
      mimeType: mimeType,
      checksum: sha256.convert(draft.bytes).toString(),
      mediaType: requestedType,
    ),
  );
}

String? _forumMediaExtension(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  final dotIndex = normalized.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == normalized.length - 1) {
    return null;
  }
  return normalized.substring(dotIndex + 1);
}

String? _forumMediaMimeType(String? extension) {
  return switch (extension) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    'mp4' => 'video/mp4',
    'mov' => 'video/quicktime',
    'm4v' => 'video/x-m4v',
    'webm' => 'video/webm',
    'pdf' => 'application/pdf',
    'txt' => 'text/plain',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls' => 'application/vnd.ms-excel',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt' => 'application/vnd.ms-powerpoint',
    'pptx' =>
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    _ => null,
  };
}

bool _isForumDocumentMimeType(String mimeType) {
  return switch (mimeType) {
    'application/pdf' ||
    'text/plain' ||
    'application/msword' ||
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
    'application/vnd.ms-excel' ||
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
    'application/vnd.ms-powerpoint' ||
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
      true,
    _ => false,
  };
}

String _forumAttachmentDisplayTypeLabel(String mimeType) {
  if (mimeType.startsWith('image/')) {
    return '图片';
  }
  if (mimeType.startsWith('video/')) {
    return '视频';
  }
  return switch (mimeType) {
    'application/pdf' => 'PDF',
    'text/plain' => '文本',
    'application/msword' ||
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      'Word',
    'application/vnd.ms-excel' ||
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
      'Excel',
    'application/vnd.ms-powerpoint' ||
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
      'PPT',
    _ => '文件',
  };
}

IconData _forumAttachmentDisplayIcon(String mimeType) {
  if (mimeType.startsWith('image/')) {
    return Icons.photo_outlined;
  }
  if (mimeType.startsWith('video/')) {
    return Icons.videocam_outlined;
  }
  return switch (mimeType) {
    'application/pdf' => Icons.picture_as_pdf_outlined,
    'text/plain' => Icons.description_outlined,
    'application/msword' ||
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      Icons.article_outlined,
    'application/vnd.ms-excel' ||
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
      Icons.table_chart_outlined,
    'application/vnd.ms-powerpoint' ||
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
      Icons.slideshow_outlined,
    _ => Icons.attach_file_rounded,
  };
}

String _forumAttachmentFileKindForItem(_ForumComposerMediaItem item) {
  if (item.mediaType != ForumPublishMediaType.file) {
    return _forumAttachmentFileKind;
  }
  final sanitized = item.fileName.trim().replaceAll(
    RegExp(r'[\\/\u0000-\u001F]'),
    '_',
  );
  return sanitized.isEmpty ? 'document' : sanitized;
}

String _unsupportedForumAttachmentMessage(ForumPublishMediaType type) {
  return switch (type) {
    ForumPublishMediaType.image => '当前只支持 JPG、PNG、WEBP、GIF 图片',
    ForumPublishMediaType.video => '当前只支持 MP4、MOV、M4V、WEBM 视频',
    ForumPublishMediaType.file => '论坛附件目前只支持图片、视频以及 PDF/文档文件。',
  };
}

String _forumMediaStageLabel(_ForumComposerMediaItem item) {
  return switch (item.stage) {
    _ForumComposerMediaStage.selectedPending => '已选中，准备上传',
    _ForumComposerMediaStage.initStarting => '正在申请上传',
    _ForumComposerMediaStage.uploading => '上传中',
    _ForumComposerMediaStage.confirming => '正在确认',
    _ForumComposerMediaStage.confirmedReady => '已确认，待保存到草稿',
    _ForumComposerMediaStage.draftBound => '已承接到当前草稿',
    _ForumComposerMediaStage.uploadFailed => '上传失败',
  };
}

String _forumAttachmentSummaryLabel(_ForumComposerMediaItem item) {
  final typeLabel = _forumAttachmentDisplayTypeLabel(item.mimeType);
  if (item.sizeInBytes <= 0) {
    return '$typeLabel · 已绑定到草稿';
  }
  return '$typeLabel · ${_forumMediaSizeLabel(item.sizeInBytes)}';
}

String _forumMediaSizeLabel(int sizeInBytes) {
  if (sizeInBytes <= 0) {
    return '大小待确认';
  }
  if (sizeInBytes < 1024) {
    return '$sizeInBytes B';
  }
  if (sizeInBytes < 1024 * 1024) {
    return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
