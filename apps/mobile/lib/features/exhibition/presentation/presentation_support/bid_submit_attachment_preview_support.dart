part of '../exhibition_trade_pages.dart';

bool _bidSubmitAttachmentIsImageMimeType(String mimeType) {
  return mimeType == 'image/png' ||
      mimeType == 'image/jpeg' ||
      mimeType == 'image/webp';
}

Future<bool> _openBidSubmitAttachmentLocalFile(String path) {
  final override = BidSubmitAttachmentDebugOverrides._localFileOpenerOverride;
  if (override != null) {
    return override(path);
  }
  return _openProjectAttachmentLocalFile(path);
}

extension _BidSubmitAttachmentPreviewActions on _BidSubmitPageState {
  Future<void> previewAttachment(_BidSubmitAttachmentSlotState slot) async {
    final draft = slot.resolvedDraft;
    if (!slot.isConfirmed || draft == null) {
      _showBidSubmitAttachmentMessage('请先完成当前附件上传确认，再进行预览检查。');
      return;
    }
    if (slot.previewOpening) {
      return;
    }

    setState(() => slot.previewOpening = true);
    if (_bidSubmitAttachmentIsImageMimeType(draft.mimeType)) {
      await _showProjectAttachmentLocalImagePreviewDialog(
        context,
        fileName: draft.fileName,
        bytes: draft.bytes,
      );
      if (mounted) {
        setState(() => slot.previewOpening = false);
      }
      return;
    }

    final tempFile = await _writeProjectAttachmentPreviewTempFile(
      fileName: draft.fileName,
      bytes: draft.bytes,
    );
    final opened = await _openBidSubmitAttachmentLocalFile(tempFile.path);
    if (!mounted) {
      return;
    }
    setState(() => slot.previewOpening = false);
    _showBidSubmitAttachmentMessage(
      opened ? '已打开附件预览。' : '附件已生成本地预览文件，但当前设备未能直接打开。',
    );
  }

  void _showBidSubmitAttachmentMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}
