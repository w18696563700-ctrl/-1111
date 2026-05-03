part of '../exhibition_trade_pages.dart';

enum _MyProjectBottomPublishCtaKind { sincerity, attachment, publish, disabled }

final class _QuoteBasisChecklistProgress {
  const _QuoteBasisChecklistProgress({
    required this.countsByKind,
    required this.loading,
    required this.unavailable,
  });

  final Map<String, int> countsByKind;
  final bool loading;
  final bool unavailable;

  int get total => _projectAttachmentKindOptions.length;

  int get completed {
    return _projectAttachmentKindOptions.where((
      _ProjectAttachmentKindOption option,
    ) {
      return (countsByKind[option.value] ?? 0) > 0;
    }).length;
  }

  bool get hasRequiredEffectImage {
    return (countsByKind[_projectAttachmentKindEffectImage] ?? 0) > 0;
  }

  bool get allKindsPresent => completed >= total;

  String get summaryLabel {
    if (loading) {
      return '正在读取';
    }
    if (unavailable) {
      return '暂不可用';
    }
    return '$completed/$total 已补充';
  }
}

final class _MyProjectBottomPublishCtaPlan {
  const _MyProjectBottomPublishCtaPlan({
    required this.kind,
    required this.label,
    required this.helper,
    required this.enabled,
  });

  final _MyProjectBottomPublishCtaKind kind;
  final String label;
  final String helper;
  final bool enabled;
}

_QuoteBasisChecklistProgress _quoteBasisChecklistProgressFromAttachments({
  required List<ProjectAttachmentReadModel>? attachments,
  required bool loading,
  required bool unavailable,
}) {
  final counts = <String, int>{
    for (final option in _projectAttachmentKindOptions) option.value: 0,
  };
  for (final attachment
      in attachments ?? const <ProjectAttachmentReadModel>[]) {
    final current = counts[attachment.attachmentKind];
    if (current != null) {
      counts[attachment.attachmentKind] = current + 1;
    }
  }
  return _QuoteBasisChecklistProgress(
    countsByKind: counts,
    loading: loading,
    unavailable: unavailable,
  );
}

String _myProjectPrepublishPendingSummary({
  required _MyProjectStageOption stage,
  required _ProjectAuthenticitySinceritySnapshot? sincerity,
  required bool pricingLoading,
  required _QuoteBasisChecklistProgress quoteBasis,
}) {
  if (stage.value != _MyProjectStageBucket.submitted) {
    return stage.detailNextStep;
  }
  if (pricingLoading) {
    return '正在核对诚意金状态';
  }
  if (sincerity?.satisfied != true) {
    return '诚意金待处理';
  }
  if (quoteBasis.loading) {
    return '正在核对报价依据资料';
  }
  if (quoteBasis.unavailable) {
    return '报价依据资料暂不可用';
  }
  if (!quoteBasis.hasRequiredEffectImage) {
    return '效果图待补充';
  }
  if (!quoteBasis.allKindsPresent) {
    return '报价依据资料 ${quoteBasis.summaryLabel}，建议继续补齐';
  }
  return '发布前待办已清晰，可检查无误后提交发布';
}

_MyProjectBottomPublishCtaPlan _myProjectBottomPublishCtaPlan({
  required String? projectId,
  required String? state,
  required _ProjectAuthenticitySinceritySnapshot? sincerity,
  required bool pricingLoading,
  required _QuoteBasisChecklistProgress quoteBasis,
  required bool canRunLifecycleActions,
}) {
  if (projectId == null || !canRunLifecycleActions) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.disabled,
      label: '暂不可提交',
      helper: '当前项目或账号关系暂不满足发布操作条件。',
      enabled: false,
    );
  }

  if (pricingLoading) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.disabled,
      label: '正在读取诚意金状态',
      helper: '请等待云端状态回读完成。',
      enabled: false,
    );
  }

  if (sincerity?.satisfied != true) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.sincerity,
      label: '继续处理诚意金',
      helper: '完成当前项目真实性诚意金后，再继续发布确认。',
      enabled: true,
    );
  }

  if (quoteBasis.loading) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.disabled,
      label: '正在读取资料状态',
      helper: '请等待报价依据资料回读完成。',
      enabled: false,
    );
  }

  if (quoteBasis.unavailable) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.disabled,
      label: '资料状态暂不可用',
      helper: '当前报价依据资料列表暂不可用，请刷新后再试。',
      enabled: false,
    );
  }

  if (!quoteBasis.hasRequiredEffectImage) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.attachment,
      label: '补充报价依据资料',
      helper: '请先补充效果图，再进行正式发布确认。',
      enabled: true,
    );
  }

  if (!_myProjectCanPublish(state)) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.disabled,
      label: '当前阶段不可发布',
      helper: '发布动作严格跟随云端项目阶段。',
      enabled: false,
    );
  }

  return _MyProjectBottomPublishCtaPlan(
    kind: _MyProjectBottomPublishCtaKind.publish,
    label: '检查无误，提交发布',
    helper: quoteBasis.allKindsPresent
        ? '提交后按平台发布规则处理，结果以云端项目状态为准。'
        : '五类资料尚未全部补齐；当前发布门禁仍按真实效果图与诚意金状态校验。',
    enabled: true,
  );
}
