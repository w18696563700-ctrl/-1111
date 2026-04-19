part of 'enterprise_hub_workbench_pages.dart';

EnterprisePublishedChangeDisposition enterprisePublishedChangeDisposition({
  required EnterpriseHubCurrentChangeRequestSnapshot? currentChangeRequest,
  required EnterpriseHubPublishedChangeStatusData? status,
  required EnterpriseHubPublishedChangeReadiness? readiness,
}) {
  final effectiveStatus =
      status?.changeStatus ?? currentChangeRequest?.changeStatus ?? 'draft';
  final changeRequestId =
      _normalizedText(status?.changeRequestId) ??
      _normalizedText(currentChangeRequest?.changeRequestId);
  final rejectionReason =
      _normalizedText(status?.rejectionReason) ??
      _normalizedText(currentChangeRequest?.rejectionReason);
  switch (effectiveStatus.trim()) {
    case 'submitted':
      return const EnterprisePublishedChangeDisposition(
        subtitle: '当前变更已提交，请直接查看真实状态结果。',
        panelTitle: '变更已提交',
        panelBody: '当前变更已提交到正式审核流，保存修改不会直接更新线上展示。',
        panelHighlighted: true,
        showSubmitAction: false,
        showViewStatusAction: true,
        viewStatusPrimary: true,
        showBlockers: false,
      );
    case 'under_review':
      return const EnterprisePublishedChangeDisposition(
        subtitle: '当前变更审核中，请直接查看真实状态结果。',
        panelTitle: '变更审核中',
        panelBody: '当前变更已进入治理审核阶段，线上展示仍以 liveSnapshot 为准。',
        panelHighlighted: true,
        showSubmitAction: false,
        showViewStatusAction: true,
        viewStatusPrimary: true,
        showBlockers: false,
      );
    case 'approved':
      return const EnterprisePublishedChangeDisposition(
        subtitle: '当前变更已审核通过，待 apply；approved 不等于已上线。',
        panelTitle: '变更已审核通过',
        panelBody: '当前变更已 approved，待平台 apply 后才会写入 live listing。',
        panelHighlighted: true,
        showSubmitAction: false,
        showViewStatusAction: true,
        viewStatusPrimary: true,
        showBlockers: false,
      );
    case 'applied':
      return const EnterprisePublishedChangeDisposition(
        subtitle: '当前变更已 apply 到线上展示，可查看最终结果。',
        panelTitle: '变更已写入线上展示',
        panelBody: '当前变更已 applied，liveSnapshot 已更新到当前公开展示真值。',
        panelHighlighted: true,
        showSubmitAction: false,
        showViewStatusAction: true,
        viewStatusPrimary: true,
        showBlockers: false,
      );
    case 'rejected':
      return EnterprisePublishedChangeDisposition(
        subtitle: '当前变更未通过，请先查看真实状态结果。',
        panelTitle: '变更未通过',
        panelBody: rejectionReason == null
            ? '当前变更未通过审核，当前页不会假装改动已上线。'
            : '当前变更未通过审核：$rejectionReason',
        panelHighlighted: false,
        showSubmitAction: false,
        showViewStatusAction: true,
        viewStatusPrimary: true,
        showBlockers: false,
      );
    case 'revision_required':
      return EnterprisePublishedChangeDisposition(
        subtitle: '当前变更需补充后重新提交；你正在修改同一条 change request。',
        panelTitle: '变更需补充资料',
        panelBody: rejectionReason == null
            ? '当前变更已被退回补充，继续保存的是同一条 current change request。${changeRequestId == null ? '' : '\nchangeRequestId：$changeRequestId'}'
            : '当前变更已被退回补充：$rejectionReason${changeRequestId == null ? '' : '\nchangeRequestId：$changeRequestId'}',
        panelHighlighted: false,
        showSubmitAction: true,
        showViewStatusAction: true,
        viewStatusPrimary: false,
        showBlockers: true,
      );
    default:
      return EnterprisePublishedChangeDisposition(
        subtitle: (readiness?.submitReady ?? false)
            ? '当前变更内容已齐，可提交变更。'
            : '保存修改只写入 current change carrier，未完成项会在下方显示。',
        panelTitle: (readiness?.submitReady ?? false) ? '当前可提交变更' : '当前暂不能提交变更',
        panelBody: (readiness?.submitReady ?? false)
            ? '当前保存只进入 current change carrier，确认后再提交变更。'
            : '当前页不会把保存修改表述成已立即上线。',
        panelHighlighted: readiness?.submitReady == true,
        showSubmitAction: true,
        showViewStatusAction: true,
        viewStatusPrimary: false,
        showBlockers: true,
      );
  }
}

String enterprisePublishedChangeStatusLabel(String? status) {
  return switch (status?.trim()) {
    'draft' => '当前修改未提交',
    'submitted' => '当前变更已提交',
    'under_review' => '当前变更审核中',
    'revision_required' => '当前变更需补充后重新提交',
    'approved' => '当前变更已审核通过，待 apply',
    'rejected' => '当前变更未通过',
    'applied' => '当前变更已写入线上展示',
    _ => '当前变更状态待确认',
  };
}

String enterprisePublishedChangeStatusExplanation(String? status) {
  return switch (status?.trim()) {
    'approved' => 'approved 仅代表审核通过，尚未 apply 到 live listing。',
    'applied' => 'applied 才代表当前变更已写入 live listing。',
    'revision_required' => 'revision_required 返回后，继续修改的是同一条 change request。',
    'submitted' => '当前变更已进入正式审核链，线上展示暂不变化。',
    'under_review' => '当前变更正在治理审核中，线上展示仍以 liveSnapshot 为准。',
    'rejected' => '当前变更未通过审核，当前页不会把保存修改伪装成已上线。',
    _ => '当前保存修改只会写入 current change carrier，不会立即影响线上展示。',
  };
}

String enterprisePublishedEnterpriseStatusLabel(String? status) {
  return switch (status?.trim()) {
    'published' => '已发布',
    'offline' => '已下线',
    'frozen' => '已冻结',
    'unpublished' => '未发布',
    _ => '状态待确认',
  };
}

String enterprisePublishedDisplayStatusLabel(String? status) {
  return switch (status?.trim()) {
    'visible' => '对外可见',
    'hidden' => '对外隐藏',
    _ => '状态待确认',
  };
}

_SectionNoticeTone _publishedChangeSnapshotTone(String? status) {
  return switch (status?.trim()) {
    'approved' || 'applied' => _SectionNoticeTone.info,
    'revision_required' || 'rejected' => _SectionNoticeTone.warning,
    _ => _SectionNoticeTone.neutral,
  };
}
