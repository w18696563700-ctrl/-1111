part of 'profile_detail_pages.dart';

class _ProfilePersonalSafetyStatusCard extends StatelessWidget {
  const _ProfilePersonalSafetyStatusCard({
    required this.fieldLabel,
    required this.currentApprovedValue,
    required this.submission,
    this.pendingValue,
  });

  final String fieldLabel;
  final String currentApprovedValue;
  final ProfilePersonalSafetySubmissionView submission;
  final String? pendingValue;

  @override
  Widget build(BuildContext context) {
    final pending = pendingValue?.trim();
    final rejectReason = submission.rejectReason?.trim();
    final lines = <String>[
      '状态：${_profilePersonalSafetyStateToken(submission.uiState)}',
      '当前公开显示仍为已通过资料：$currentApprovedValue',
      if (submission.uiState == ProfilePersonalSafetyUiState.pendingReview &&
          pending != null &&
          pending.isNotEmpty)
        '新提交内容审核中：$pending',
      if (submission.uiState == ProfilePersonalSafetyUiState.pendingReview)
        '审核通过后才会替换当前公开资料。',
      if (submission.uiState == ProfilePersonalSafetyUiState.rejected &&
          pending != null &&
          pending.isNotEmpty)
        '新提交内容未通过：$pending',
      if (submission.uiState == ProfilePersonalSafetyUiState.rejected ||
          submission.uiState == ProfilePersonalSafetyUiState.resubmittable)
        '拒绝原因：${rejectReason == null || rejectReason.isEmpty ? '未返回具体原因，请按规则提示调整后重试。' : rejectReason}',
      if (submission.uiState == ProfilePersonalSafetyUiState.rejected ||
          submission.uiState == ProfilePersonalSafetyUiState.resubmittable)
        '可重新提交。',
      if (submission.uiState == ProfilePersonalSafetyUiState.approved)
        '审核通过后以正式回读结果更新。',
    ];

    return _ProfileCompactCard(
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          title: Text(
            _profilePersonalSafetyStatusTitle(fieldLabel, submission.uiState),
          ),
          subtitle: Text(lines.join('\n')),
        ),
      ],
    );
  }
}

bool profilePersonalSafetyStateUsesApprovedReadback(
  ProfilePersonalSafetyUiState state,
) {
  return state == ProfilePersonalSafetyUiState.approved ||
      state == ProfilePersonalSafetyUiState.currentApproved;
}

String _profilePersonalSafetyStateToken(ProfilePersonalSafetyUiState state) {
  return switch (state) {
    ProfilePersonalSafetyUiState.currentApproved => 'currentApproved',
    ProfilePersonalSafetyUiState.pendingReview => 'pendingReview',
    ProfilePersonalSafetyUiState.approved => 'approved',
    ProfilePersonalSafetyUiState.rejected => 'rejected',
    ProfilePersonalSafetyUiState.resubmittable => 'resubmittable',
  };
}

String _profilePersonalSafetyStatusTitle(
  String fieldLabel,
  ProfilePersonalSafetyUiState state,
) {
  final suffix = switch (state) {
    ProfilePersonalSafetyUiState.currentApproved => '当前已通过',
    ProfilePersonalSafetyUiState.pendingReview => '审核中',
    ProfilePersonalSafetyUiState.approved => '审核已通过',
    ProfilePersonalSafetyUiState.rejected => '审核未通过',
    ProfilePersonalSafetyUiState.resubmittable => '可重新提交',
  };
  return '$fieldLabel$suffix';
}
