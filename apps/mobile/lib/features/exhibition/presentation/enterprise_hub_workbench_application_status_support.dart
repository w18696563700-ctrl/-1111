part of 'enterprise_hub_workbench_pages.dart';

EnterpriseWorkbenchSubmitDisposition enterpriseWorkbenchSubmitDisposition({
  required EnterpriseHubWorkbenchApplication? latestApplication,
  required EnterpriseHubWorkbenchReadiness readiness,
}) {
  if (latestApplication == null) {
    return const EnterpriseWorkbenchSubmitDisposition(
      isPostSubmit: false,
      subtitle: '当前还没有申请记录，可以继续补充资料或上传图片；真正提交前会再创建申请草稿。',
      showSubmitAction: true,
      showRecreateDraftAction: false,
      showViewApplicationStatusAction: false,
      viewApplicationStatusPrimary: false,
      showBlockers: true,
    );
  }
  if (_shouldOfferDraftRecreation(latestApplication.applicationStatus)) {
    return EnterpriseWorkbenchSubmitDisposition(
      isPostSubmit: true,
      subtitle: _recreateDraftSubtitle(latestApplication.applicationStatus),
      showSubmitAction: false,
      showRecreateDraftAction: true,
      showViewApplicationStatusAction: true,
      viewApplicationStatusPrimary: false,
      showBlockers: false,
      panelTitle: _postSubmitPanelTitle(latestApplication.applicationStatus),
      panelBody: _recreateDraftPanelBody(latestApplication),
      panelHighlighted: false,
    );
  }
  if (_isPostSubmitApplicationStatus(latestApplication.applicationStatus)) {
    return EnterpriseWorkbenchSubmitDisposition(
      isPostSubmit: true,
      subtitle:
          _isApprovedApplicationStatus(latestApplication.applicationStatus)
          ? '当前申请已通过，请直接查看申请状态。'
          : '当前申请已进入正式状态流转，请直接查看申请状态。',
      showSubmitAction: false,
      showRecreateDraftAction: false,
      showViewApplicationStatusAction: true,
      viewApplicationStatusPrimary: true,
      showBlockers: false,
      panelTitle: _postSubmitPanelTitle(latestApplication.applicationStatus),
      panelBody: _postSubmitPanelBody(latestApplication),
      panelHighlighted: true,
    );
  }
  if (readiness.submitReady) {
    return const EnterpriseWorkbenchSubmitDisposition(
      isPostSubmit: false,
      subtitle: '资料已齐，可直接提交入驻申请。',
      showSubmitAction: true,
      showRecreateDraftAction: false,
      showViewApplicationStatusAction: true,
      viewApplicationStatusPrimary: false,
      showBlockers: true,
    );
  }
  return const EnterpriseWorkbenchSubmitDisposition(
    isPostSubmit: false,
    subtitle: '提交按钮置灰时，会在下方明确显示未完成项。',
    showSubmitAction: true,
    showRecreateDraftAction: false,
    showViewApplicationStatusAction: true,
    viewApplicationStatusPrimary: false,
    showBlockers: true,
  );
}

bool _isPostSubmitApplicationStatus(String? status) {
  switch (status?.trim()) {
    case 'submitted':
    case 'under_review':
    case 'approved':
    case 'revision_required':
    case 'rejected':
      return true;
    default:
      return false;
  }
}

bool _isApprovedApplicationStatus(String? status) =>
    status?.trim() == 'approved';

bool _shouldOfferDraftRecreation(String? status) {
  switch (status?.trim()) {
    case 'approved':
    case 'revision_required':
    case 'rejected':
      return true;
    default:
      return false;
  }
}

String _recreateDraftSubtitle(String? status) {
  switch (status?.trim()) {
    case 'approved':
      return '当前申请已通过；如需继续测试或准备新一轮提交，请重新创建申请草稿。';
    case 'revision_required':
      return '当前申请需补充资料；重新创建申请草稿后可继续测试并再次提交。';
    case 'rejected':
      return '当前申请未通过；重新创建申请草稿后可继续测试并再次提交。';
    default:
      return '当前申请已进入正式结果阶段，可重新创建申请草稿继续准备下一轮提交。';
  }
}

String _recreateDraftPanelBody(EnterpriseHubWorkbenchApplication application) {
  final rejectionReason = _normalizedText(application.rejectionReason);
  final reviewNote = _normalizedText(application.reviewNote);
  switch (application.applicationStatus.trim()) {
    case 'approved':
      return '当前申请已通过审核。若要继续验证修改链，请先重新创建一条新的申请草稿。';
    case 'revision_required':
      if (reviewNote != null) {
        return '当前申请已被退回补充。审核说明：$reviewNote';
      }
      return rejectionReason == null
          ? '当前申请已被退回补充。重新创建申请草稿后，可继续修改资料、案例和联系人，再重新提交。'
          : '当前申请已被退回补充：$rejectionReason。重新创建申请草稿后，可继续修改资料、案例和联系人，再重新提交。';
    case 'rejected':
      if (reviewNote != null) {
        return '当前申请未通过。审核说明：$reviewNote';
      }
      return rejectionReason == null
          ? '当前申请未通过。重新创建申请草稿后，可继续修改资料、案例和联系人，再重新提交。'
          : '当前申请未通过：$rejectionReason。重新创建申请草稿后，可继续修改资料、案例和联系人，再重新提交。';
    default:
      return _postSubmitPanelBody(application);
  }
}

String _postSubmitPanelTitle(String? status) {
  switch (status?.trim()) {
    case 'submitted':
      return '申请已提交';
    case 'under_review':
      return '申请审核中';
    case 'approved':
      return '申请已通过';
    case 'revision_required':
      return '申请需补充资料';
    case 'rejected':
      return '申请未通过';
    default:
      return '申请状态已更新';
  }
}

String _postSubmitPanelBody(EnterpriseHubWorkbenchApplication application) {
  if (_isApprovedApplicationStatus(application.applicationStatus)) {
    return '当前申请已通过审核，请直接进入申请状态查看正式结果。';
  }
  final reviewNote = _normalizedText(application.reviewNote);
  if (reviewNote != null) {
    return '当前申请状态：${enterpriseWorkbenchApplicationStatusLabel(application.applicationStatus)}。审核说明：$reviewNote';
  }
  final rejectionReason = _normalizedText(application.rejectionReason);
  if (rejectionReason != null) {
    return '当前申请已进入正式结果阶段，请先查看申请状态。驳回原因：$rejectionReason';
  }
  return '当前申请状态：${enterpriseWorkbenchApplicationStatusLabel(application.applicationStatus)}请直接进入申请状态查看正式结果。';
}
