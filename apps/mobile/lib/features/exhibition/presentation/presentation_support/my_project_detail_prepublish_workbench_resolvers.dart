part of '../exhibition_trade_pages.dart';

enum _MyProjectBottomPublishCtaKind { sincerity, attachment, publish, disabled }

const List<String> _projectRequiredQuoteBasisAttachmentKinds = <String>[
  _projectAttachmentKindEffectImage,
  _projectAttachmentKindConstructionDoc,
  _projectAttachmentKindMaterialSample,
];

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

  int get requiredTotal => _projectRequiredQuoteBasisAttachmentKinds.length;

  int get requiredCompleted {
    return _projectRequiredQuoteBasisAttachmentKinds.where((String kind) {
      return (countsByKind[kind] ?? 0) > 0;
    }).length;
  }

  bool get allRequiredKindsPresent => requiredCompleted >= requiredTotal;

  List<String> get missingRequiredLabels {
    return _projectRequiredQuoteBasisAttachmentKinds
        .where((String kind) => (countsByKind[kind] ?? 0) <= 0)
        .map(_projectAttachmentKindLabel)
        .toList(growable: false);
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

  String get requiredSummaryLabel {
    if (loading) {
      return '正在读取';
    }
    if (unavailable) {
      return '暂不可用';
    }
    return '$requiredCompleted/$requiredTotal 必传已补齐';
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

bool _sincerityGreenChannelChoiceCompleted(
  _ProjectAuthenticitySinceritySnapshot? sincerity,
) {
  final choice = sincerity?.freezeFeedback?.myChoice;
  return choice == 'support_freeze' || choice == 'oppose_freeze';
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
  if (quoteBasis.loading) {
    return '正在核对报价依据资料';
  }
  if (quoteBasis.unavailable) {
    return '报价依据资料暂不可用';
  }
  if (!quoteBasis.allRequiredKindsPresent) {
    return '必传资料待补充：${quoteBasis.missingRequiredLabels.join('、')}';
  }
  if (pricingLoading) {
    return '正在核对诚意金绿色通道';
  }
  if (!_sincerityGreenChannelChoiceCompleted(sincerity)) {
    return '诚意金绿色通道待表态';
  }
  return '发布前待办已清晰，可确认发布';
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

  if (!quoteBasis.allRequiredKindsPresent) {
    return _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.attachment,
      label: '补充报价依据资料',
      helper: '请先补齐必传资料：${quoteBasis.missingRequiredLabels.join('、')}。',
      enabled: true,
    );
  }

  if (pricingLoading) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.disabled,
      label: '正在读取诚意金绿色通道',
      helper: '请等待云端诚意金状态和表态记录回读完成。',
      enabled: false,
    );
  }

  if (!_sincerityGreenChannelChoiceCompleted(sincerity)) {
    return const _MyProjectBottomPublishCtaPlan(
      kind: _MyProjectBottomPublishCtaKind.sincerity,
      label: '完成诚意金绿色通道表态',
      helper: '请选择支持或暂不支持项目真实性诚意金机制，任一选择均可继续发布。',
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
    label: '确认并发布',
    helper: quoteBasis.allKindsPresent
        ? '提交后按平台发布规则处理，结果以云端项目状态为准。'
        : '设备物料清单、服务清单仍建议补充；当前已满足三类必传资料和绿色通道表态。',
    enabled: true,
  );
}
