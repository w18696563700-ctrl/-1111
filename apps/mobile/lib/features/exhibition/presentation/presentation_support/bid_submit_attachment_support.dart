part of '../exhibition_trade_pages.dart';

typedef BidSubmitAttachmentPicker =
    Future<BidSubmitAttachmentDraft?> Function();
typedef BidSubmitAttachmentLocalFileOpener = Future<bool> Function(String path);

const String _bidSubmitAttachmentBusinessType = 'project';
const String _bidSubmitProjectUnderstandingFileKind =
    'bid_project_understanding';
const String _bidSubmitQuoteSheetFileKind = 'bid_quote_sheet';
const String _bidSubmitSchedulePlanFileKind = 'bid_schedule_plan';

class BidSubmitAttachmentDraft {
  const BidSubmitAttachmentDraft({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

final class BidSubmitAttachmentDebugOverrides {
  const BidSubmitAttachmentDebugOverrides._();

  static BidSubmitAttachmentPicker? _pickerOverride;
  static BidSubmitAttachmentLocalFileOpener? _localFileOpenerOverride;

  static void installPicker(BidSubmitAttachmentPicker? picker) {
    _pickerOverride = picker;
  }

  static void installLocalFileOpener(
    BidSubmitAttachmentLocalFileOpener? opener,
  ) {
    _localFileOpenerOverride = opener;
  }

  static void reset() {
    _pickerOverride = null;
    _localFileOpenerOverride = null;
  }
}

enum _BidSubmitAttachmentUploadUiStatus {
  idle,
  selecting,
  selectedReady,
  initStarting,
  initFailed,
  directUploading,
  directUploadFailed,
  confirming,
  confirmFailed,
  uploadBound,
  unsupportedType,
}

class _ResolvedBidSubmitAttachmentDraft {
  const _ResolvedBidSubmitAttachmentDraft({
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

class _BidSubmitAttachmentSlotState {
  _BidSubmitAttachmentSlotState({
    required this.key,
    required this.label,
    required this.summary,
    required this.fileKind,
    required this.supportedTypes,
  });

  final String key;
  final String label;
  final String summary;
  final String fileKind;
  final String supportedTypes;
  BidSubmitAttachmentDraft? draft;
  _ResolvedBidSubmitAttachmentDraft? resolvedDraft;
  AppUploadState? uploadState;
  String? uploadMessage;
  String? uploadErrorCode;
  String? uploadPath;
  UploadDirective? uploadDirective;
  String? fileAssetId;
  bool previewOpening = false;

  bool get isConfirmed =>
      uploadState == AppUploadState.uploadBound &&
      _normalizeId(fileAssetId) != null;
}

List<String> _bidSubmitMissingAttachmentLabels(
  List<_BidSubmitAttachmentSlotState> slots,
) {
  return slots
      .where((_BidSubmitAttachmentSlotState slot) => !slot.isConfirmed)
      .map((_BidSubmitAttachmentSlotState slot) => slot.label)
      .toList(growable: false);
}

String? _bidSubmitAttachmentSubmitDisabledMessage(
  List<_BidSubmitAttachmentSlotState> slots,
) {
  final missingLabels = _bidSubmitMissingAttachmentLabels(slots);
  if (missingLabels.isEmpty) {
    return null;
  }
  return '请先完成并确认附件：${missingLabels.join('、')}，再继续提交竞标。';
}

class _BidSubmitAttachmentSlotConfig {
  const _BidSubmitAttachmentSlotConfig({
    required this.key,
    required this.label,
    required this.summary,
    required this.fileKind,
    required this.supportedTypes,
  });

  final String key;
  final String label;
  final String summary;
  final String fileKind;
  final String supportedTypes;
}

const List<_BidSubmitAttachmentSlotConfig> _bidSubmitAttachmentSlotBlueprints =
    <_BidSubmitAttachmentSlotConfig>[
      _BidSubmitAttachmentSlotConfig(
        key: 'project-understanding',
        label: '项目理解',
        summary: '上传项目理解文档，帮助补充你对本次项目的理解与判断。',
        fileKind: _bidSubmitProjectUnderstandingFileKind,
        supportedTypes: 'PNG / JPEG / WEBP / PDF / DOC / DOCX',
      ),
      _BidSubmitAttachmentSlotConfig(
        key: 'quote-sheet',
        label: '报价表',
        summary: '上传报价表文件，建议使用表格或 PDF 形式。',
        fileKind: _bidSubmitQuoteSheetFileKind,
        supportedTypes: 'XLS / XLSX / PDF / DOC / DOCX',
      ),
      _BidSubmitAttachmentSlotConfig(
        key: 'schedule-plan',
        label: '进度安排',
        summary: '上传进度安排文件，用于说明本次竞标的推进节奏。',
        fileKind: _bidSubmitSchedulePlanFileKind,
        supportedTypes: 'PDF / DOC / DOCX / XLS / XLSX',
      ),
    ];

List<_BidSubmitAttachmentSlotState> _createBidSubmitAttachmentSlots() {
  return _bidSubmitAttachmentSlotBlueprints
      .map(
        (_BidSubmitAttachmentSlotConfig item) => _BidSubmitAttachmentSlotState(
          key: item.key,
          label: item.label,
          summary: item.summary,
          fileKind: item.fileKind,
          supportedTypes: item.supportedTypes,
        ),
      )
      .toList(growable: false);
}

Future<BidSubmitAttachmentDraft?> _pickBidSubmitAttachmentDraft() async {
  final override = BidSubmitAttachmentDebugOverrides._pickerOverride;
  if (override != null) {
    return override();
  }

  final file = await openFile();
  if (file == null) {
    return null;
  }

  return BidSubmitAttachmentDraft(
    fileName: file.name,
    bytes: await file.readAsBytes(),
  );
}

_ResolvedBidSubmitAttachmentDraft? _resolveBidSubmitAttachmentDraft(
  BidSubmitAttachmentDraft draft,
) {
  final extension = _bidSubmitAttachmentExtension(draft.fileName);
  final mimeType = _bidSubmitAttachmentMimeType(extension);
  if (extension == null || mimeType == null) {
    return null;
  }

  return _ResolvedBidSubmitAttachmentDraft(
    fileName: draft.fileName,
    bytes: draft.bytes,
    extension: extension,
    mimeType: mimeType,
    checksum: sha256.convert(draft.bytes).toString(),
  );
}

String? _bidSubmitAttachmentExtension(String fileName) {
  final normalized = fileName.trim().toLowerCase();
  final dotIndex = normalized.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == normalized.length - 1) {
    return null;
  }

  final extension = normalized.substring(dotIndex + 1);
  return switch (extension) {
    'png' ||
    'jpg' ||
    'jpeg' ||
    'webp' ||
    'pdf' ||
    'doc' ||
    'docx' ||
    'xls' ||
    'xlsx' => extension,
    _ => null,
  };
}

String? _bidSubmitAttachmentMimeType(String? extension) {
  return switch (extension) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls' => 'application/vnd.ms-excel',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    _ => null,
  };
}

String _bidSubmitAttachmentMimeTypeLabel(String mimeType) {
  return switch (mimeType) {
    'image/png' => 'PNG 图片',
    'image/jpeg' => 'JPEG 图片',
    'image/webp' => 'WEBP 图片',
    'application/pdf' => 'PDF 文档',
    'application/msword' => 'DOC 文档',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      'DOCX 文档',
    'application/vnd.ms-excel' => 'XLS 表格',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
      'XLSX 表格',
    _ => mimeType,
  };
}

String _bidSubmitAttachmentSizeLabel(int sizeInBytes) {
  if (sizeInBytes < 1024) {
    return '$sizeInBytes B';
  }
  if (sizeInBytes < 1024 * 1024) {
    return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
  }

  return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

bool _bidSubmitAttachmentKindMatchesMimeType(String kind, String mimeType) {
  final isImage = mimeType.startsWith('image/');
  final isDocument =
      mimeType == 'application/pdf' ||
      mimeType == 'application/msword' ||
      mimeType ==
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  final isSpreadsheet =
      mimeType == 'application/vnd.ms-excel' ||
      mimeType ==
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  return switch (kind) {
    _bidSubmitProjectUnderstandingFileKind => isImage || isDocument,
    _bidSubmitQuoteSheetFileKind => isDocument || isSpreadsheet,
    _bidSubmitSchedulePlanFileKind => isDocument || isSpreadsheet,
    _ => false,
  };
}

String _bidSubmitAttachmentUnsupportedTypeMessage(String attachmentLabel) {
  return switch (attachmentLabel) {
    '项目理解' => '项目理解只支持图片、PDF、DOC、DOCX 文件。',
    '报价表' => '报价表只支持 XLS、XLSX、PDF、DOC、DOCX 文件。',
    '进度安排' => '进度安排只支持 PDF、DOC、DOCX、XLS、XLSX 文件。',
    _ => '当前文件类型暂不支持。',
  };
}

String _bidSubmitAttachmentUploadFailureMessage(
  _BidSubmitAttachmentUploadUiStatus status,
) {
  return switch (status) {
    _BidSubmitAttachmentUploadUiStatus.initFailed => '当前附件上传初始化未完成，请稍后重试。',
    _BidSubmitAttachmentUploadUiStatus.directUploadFailed =>
      '当前附件直传未完成，请重新上传当前附件。',
    _BidSubmitAttachmentUploadUiStatus.confirmFailed =>
      '当前附件确认结果未完成，请再次确认或重新上传。',
    _ => '',
  };
}

String _bidSubmitAttachmentStatusLabel(_BidSubmitAttachmentSlotState slot) {
  return switch (slot.uploadState) {
    AppUploadState.localValidating => '正在校验上传信息',
    AppUploadState.signedReady => '上传信息已准备好',
    AppUploadState.uploading => '正在上传凭证',
    AppUploadState.uploadFailedRetryable => '上传暂未完成',
    AppUploadState.uploadConfirming => '正在确认上传结果',
    AppUploadState.uploadConfirmFailed => '上传确认暂未完成',
    AppUploadState.uploadBound => '上传已完成',
    null => slot.fileAssetId == null ? '尚未上传' : '已形成绑定结果',
  };
}
