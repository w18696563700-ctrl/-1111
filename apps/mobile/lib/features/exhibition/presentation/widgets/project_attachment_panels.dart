part of '../exhibition_trade_pages.dart';

class _SelectedProjectAttachmentCard extends StatelessWidget {
  const _SelectedProjectAttachmentCard({required this.draft});

  final _ResolvedProjectAttachmentDraft draft;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              draft.fileName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _DetailLine(
              label: '文件类型',
              value: _projectAttachmentFileTypeLabel(draft.extension),
            ),
            _DetailLine(
              label: '文件大小',
              value: _projectAttachmentSizeLabel(draft.sizeInBytes),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachmentStatePanel extends StatelessWidget {
  const _ProjectAttachmentStatePanel({
    required this.status,
    required this.message,
    required this.selectedDraft,
  });

  final _ProjectAttachmentUiStatus status;
  final String? message;
  final _ResolvedProjectAttachmentDraft? selectedDraft;

  @override
  Widget build(BuildContext context) {
    final title = _title();
    final body = message ?? _body();
    final nextStep = _nextStep();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body),
          if (nextStep != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              nextStep,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  String _title() {
    return switch (status) {
      _ProjectAttachmentUiStatus.idle => '等待选择附件',
      _ProjectAttachmentUiStatus.selecting => '正在选择附件',
      _ProjectAttachmentUiStatus.selectedReady => '附件已选中',
      _ProjectAttachmentUiStatus.initStarting => '正在申请上传',
      _ProjectAttachmentUiStatus.initFailed => '上传初始化未通过',
      _ProjectAttachmentUiStatus.directUploading => '正在上传附件',
      _ProjectAttachmentUiStatus.directUploadFailed => '附件发送暂未完成',
      _ProjectAttachmentUiStatus.confirming => '正在确认上传结果',
      _ProjectAttachmentUiStatus.confirmFailed => '附件确认暂未完成',
      _ProjectAttachmentUiStatus.confirmAccepted => '上传确认已完成',
      _ProjectAttachmentUiStatus.unsupportedType => '当前文件类型暂不支持',
    };
  }

  String _body() {
    return switch (status) {
      _ProjectAttachmentUiStatus.idle => '当前还没有开始上传。选择文件后，页面会继续走正式三步上传链路。',
      _ProjectAttachmentUiStatus.selecting => '正在打开文件选择器，请选择当前项目要补充的附件。',
      _ProjectAttachmentUiStatus.selectedReady => '当前附件已经选中，可以直接发起上传。',
      _ProjectAttachmentUiStatus.initStarting => '页面正在申请当前附件的上传策略。',
      _ProjectAttachmentUiStatus.initFailed ||
      _ProjectAttachmentUiStatus.directUploadFailed ||
      _ProjectAttachmentUiStatus.confirmFailed =>
        _projectAttachmentUploadErrorMessage(status),
      _ProjectAttachmentUiStatus.directUploading => '页面正在把当前附件发送到签名直传地址。',
      _ProjectAttachmentUiStatus.confirming => '直传已完成，页面正在确认当前附件的上传结果。',
      _ProjectAttachmentUiStatus.confirmAccepted =>
        '当前附件已上传并完成绑定确认；页面会等待正式项目附件结果返回后再展示项目附件结果。',
      _ProjectAttachmentUiStatus.unsupportedType =>
        '当前只支持 PDF、DOC、DOCX 附件，请重新选择。',
    };
  }

  String? _nextStep() {
    return switch (status) {
      _ProjectAttachmentUiStatus.selectedReady => '下一步：点击“上传当前附件”继续。',
      _ProjectAttachmentUiStatus.initFailed ||
      _ProjectAttachmentUiStatus.directUploadFailed => '下一步：重新上传当前附件即可。',
      _ProjectAttachmentUiStatus.confirmFailed => '下一步：点击“再次确认上传结果”或重新上传当前附件。',
      _ProjectAttachmentUiStatus.confirmAccepted when selectedDraft != null =>
        '当前已上传并完成绑定确认：${selectedDraft!.fileName}',
      _ => null,
    };
  }
}

class _ProjectAttachmentList extends StatelessWidget {
  const _ProjectAttachmentList({
    required this.records,
    required this.emptyMessage,
    required this.canContinue,
  });

  final List<_ProjectAttachmentRecord> records;
  final String emptyMessage;
  final bool canContinue;

  @override
  Widget build(BuildContext context) {
    if (!canContinue) {
      return const _EmptyNotice(
        title: '当前不可继续上传',
        message: '当前没有承接到项目实例时，附件上传入口会保持受控不可继续。',
      );
    }

    if (records.isEmpty) {
      return _EmptyNotice(
        title: '当前还没有项目附件结果',
        message:
            '$emptyMessage 页面只会在拿到正式 projectAttachment 结果后展示项目附件结果；当前只保留上传确认记录。',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '本次上传确认记录',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          '这些记录只说明当前会话的上传确认已经完成，正式项目附件结果仍以后端返回为准。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 12),
        ...records.asMap().entries.map((
          MapEntry<int, _ProjectAttachmentRecord> entry,
        ) {
          final isLast = entry.key == records.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: _ProjectAttachmentRecordCard(record: entry.value),
          );
        }),
      ],
    );
  }
}

class _ProjectAttachmentRecordCard extends StatelessWidget {
  const _ProjectAttachmentRecordCard({required this.record});

  final _ProjectAttachmentRecord record;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              record.fileName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _DetailLine(
              label: '文件类型',
              value: _projectAttachmentFileTypeLabel(record.extension),
            ),
            _DetailLine(
              label: '文件大小',
              value: _projectAttachmentSizeLabel(record.sizeInBytes),
            ),
            const _DetailLine(
              label: '当前状态',
              value: '已上传并完成绑定确认，待项目附件结果返回',
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }
}
