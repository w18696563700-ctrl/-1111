part of '../exhibition_trade_pages.dart';

typedef ProjectAttachmentPicker = Future<ProjectAttachmentDraft?> Function();

class ProjectAttachmentDraft {
  const ProjectAttachmentDraft({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

final class ProjectAttachmentDebugOverrides {
  const ProjectAttachmentDebugOverrides._();

  static ProjectAttachmentPicker? _pickerOverride;

  static void installPicker(ProjectAttachmentPicker? picker) {
    _pickerOverride = picker;
  }

  static void clearSession() {
    _ProjectAttachmentSessionStore.clear();
  }

  static void reset() {
    _pickerOverride = null;
    clearSession();
  }
}

enum _ProjectAttachmentUiStatus {
  idle,
  selecting,
  selectedReady,
  initStarting,
  initFailed,
  directUploading,
  directUploadFailed,
  confirming,
  confirmFailed,
  confirmAccepted,
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

class _ProjectAttachmentRecord {
  const _ProjectAttachmentRecord({
    required this.fileName,
    required this.extension,
    required this.sizeInBytes,
  });

  final String fileName;
  final String extension;
  final int sizeInBytes;
}

final class _ProjectAttachmentSessionStore {
  const _ProjectAttachmentSessionStore._();

  static final Map<String, List<_ProjectAttachmentRecord>> _records =
      <String, List<_ProjectAttachmentRecord>>{};

  static List<_ProjectAttachmentRecord> read(String projectId) {
    final records = _records[projectId];
    if (records == null) {
      return const <_ProjectAttachmentRecord>[];
    }

    return List<_ProjectAttachmentRecord>.unmodifiable(records);
  }

  static void rememberConfirmAccepted(
    String projectId,
    _ResolvedProjectAttachmentDraft draft,
  ) {
    final records = _records.putIfAbsent(
      projectId,
      () => <_ProjectAttachmentRecord>[],
    );
    records.insert(
      0,
      _ProjectAttachmentRecord(
        fileName: draft.fileName,
        extension: draft.extension,
        sizeInBytes: draft.sizeInBytes,
      ),
    );
  }

  static void clear() {
    _records.clear();
  }
}

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
    'pdf' || 'doc' || 'docx' => extension,
    _ => null,
  };
}

String? _projectAttachmentMimeType(String? extension) {
  return switch (extension) {
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ => null,
  };
}

String _projectAttachmentFileTypeLabel(String extension) {
  return switch (extension) {
    'pdf' => 'PDF 文档',
    'doc' => 'DOC 文档',
    'docx' => 'DOCX 文档',
    _ => extension.toUpperCase(),
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

String _projectAttachmentUploadErrorMessage(_ProjectAttachmentUiStatus status) {
  return switch (status) {
    _ProjectAttachmentUiStatus.initFailed => '上传初始化未通过，可稍后重试。',
    _ProjectAttachmentUiStatus.directUploadFailed => '文件发送未完成，可直接重试当前附件。',
    _ProjectAttachmentUiStatus.confirmFailed => '附件确认结果未完成，可再次确认当前附件。',
    _ => '',
  };
}
