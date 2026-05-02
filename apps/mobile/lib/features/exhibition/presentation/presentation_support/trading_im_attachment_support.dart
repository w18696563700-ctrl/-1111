part of '../exhibition_trade_pages.dart';

const String _tradingImUploadBusinessType = 'project';
const String _tradingImUploadFileKind = 'project_attachment';

class _TradingImUploadOutcome {
  const _TradingImUploadOutcome({
    required this.fileAssetId,
    required this.message,
  });

  final String? fileAssetId;
  final String message;

  bool get isSuccess => fileAssetId != null;
}

Future<_TradingImUploadOutcome> _uploadTradingImAttachment({
  required String projectId,
  required ValueChanged<String> onProgress,
}) async {
  onProgress('正在选择沟通附件。');
  final draft = await _pickProjectAttachmentDraft();
  if (draft == null) {
    return const _TradingImUploadOutcome(
      fileAssetId: null,
      message: '当前没有选择附件。',
    );
  }

  final resolved = _resolveProjectAttachmentDraft(draft);
  if (resolved == null) {
    return const _TradingImUploadOutcome(
      fileAssetId: null,
      message: '当前只支持图片、PDF、DOC、DOCX 文件。',
    );
  }

  onProgress('正在申请 ${resolved.fileName} 的上传策略。');
  final initResult = await ExhibitionConsumerLayer.instance.uploadInit(
    UploadInitCommand(
      businessType: _tradingImUploadBusinessType,
      businessId: projectId,
      fileKind: _tradingImUploadFileKind,
      mimeType: resolved.mimeType,
      size: resolved.sizeInBytes,
      checksum: resolved.checksum,
    ),
  );
  final directive = initResult.directive;
  if (initResult.state != AppUploadState.signedReady || directive == null) {
    return _TradingImUploadOutcome(
      fileAssetId: null,
      message: initResult.message ?? '当前附件上传初始化未完成，请稍后重试。',
    );
  }

  onProgress('正在直传 ${resolved.fileName}。');
  final directResult = await ExhibitionConsumerLayer.instance.directUpload(
    directive: directive,
    bodyBytes: resolved.bytes,
  );
  final confirmDirective = directResult.directive;
  if (directResult.state != AppUploadState.uploadConfirming ||
      confirmDirective == null) {
    return _TradingImUploadOutcome(
      fileAssetId: null,
      message: directResult.message ?? '当前附件直传未完成，请重新上传。',
    );
  }

  onProgress('正在确认 ${resolved.fileName} 的 FileAsset。');
  final confirmResult = await ExhibitionConsumerLayer.instance.uploadConfirm(
    directive: confirmDirective,
  );
  final fileAssetId = _normalizeId(confirmResult.fileAssetId);
  if (confirmResult.state != AppUploadState.uploadBound ||
      fileAssetId == null) {
    return _TradingImUploadOutcome(
      fileAssetId: null,
      message: confirmResult.message ?? '当前附件确认失败，请稍后重试。',
    );
  }

  return _TradingImUploadOutcome(
    fileAssetId: fileAssetId,
    message: '${resolved.fileName} 已确认，可随本次沟通提交。',
  );
}

String _tradingImAttachmentText(List<String> fileAssetIds) {
  if (fileAssetIds.isEmpty) {
    return '无附件';
  }
  return fileAssetIds.join('、');
}

String _tradingImRoleLabel(String role) {
  return switch (role) {
    'project_owner' => '项目方',
    'bidder' => '竞标方',
    'viewer' => '查看方',
    'system_seed' => '系统消息',
    _ => role,
  };
}

String _confirmationTypeLabel(String type) {
  return switch (type) {
    'quote' => '报价确认',
    'craft_material' => '工艺材料确认',
    'material_process' => '工艺/材质确认',
    'schedule' => '排期确认',
    _ => type,
  };
}
