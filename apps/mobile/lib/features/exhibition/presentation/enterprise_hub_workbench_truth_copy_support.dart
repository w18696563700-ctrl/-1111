part of 'enterprise_hub_workbench_pages.dart';

String _workbenchCertificationStatusLabel(String? status) {
  if (_isApprovedWorkbenchCertificationStatus(status)) {
    return '已通过';
  }
  return switch (status?.trim()) {
    'submitted' => '已提交',
    'under_review' => '审核中',
    'rejected' => '未通过',
    'pending' => '待补齐',
    _ => '待补充',
  };
}

bool _isApprovedWorkbenchCertificationStatus(String? status) {
  return switch (status?.trim()) {
    'approved' || 'verified' => true,
    _ => false,
  };
}

bool enterpriseWorkbenchShouldShowUpstreamTruthSection({
  required String? enterpriseNameTruth,
  required String? organizationCityTruth,
  required String? foundedAtTruth,
}) {
  return _normalizedText(enterpriseNameTruth) == null ||
      _normalizedText(organizationCityTruth) == null ||
      _normalizedText(foundedAtTruth) == null;
}

bool enterpriseWorkbenchShouldShowCertificationSummary({
  required String? certificationStatus,
  required String? rejectReason,
}) {
  return _normalizedText(rejectReason) != null ||
      !_isApprovedWorkbenchCertificationStatus(certificationStatus);
}

String enterpriseWorkbenchOrganizationCityTruthHelperText({
  required bool isMissing,
}) {
  if (isMissing) {
    return '当前字段来源于我的公司；当前页不能修改。当前保存仍会被这个上游真值阻断，如需继续请先去我的公司补全组织所在城市。';
  }
  return '当前字段来源于我的公司真值，当前页不单独修改；如需变更请前往我的公司维护。';
}
