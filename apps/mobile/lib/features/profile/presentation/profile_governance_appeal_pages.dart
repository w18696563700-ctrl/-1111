part of 'profile_detail_pages.dart';

class ProfileGovernanceAppealListPage extends StatefulWidget {
  const ProfileGovernanceAppealListPage({super.key});

  @override
  State<ProfileGovernanceAppealListPage> createState() =>
      _ProfileGovernanceAppealListPageState();
}

class _ProfileGovernanceAppealListPageState
    extends State<ProfileGovernanceAppealListPage> {
  bool _loading = true;
  ProfileGovernanceAppealResult<ProfileGovernanceAppealListView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileGovernanceAppealConsumerLayer.instance
        .loadAppeals();
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取我的申诉记录',
        message: '正在同步当前账号的申诉历史列表。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: _appealListStateTitle(result.state),
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '我的申诉记录列表',
        ),
        actionLabel: _appealRetryLabel(result.state),
        onAction: _appealRetryLabel(result.state) == null ? null : _load,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: '我的申诉记录',
            subtitle: '查看当前账号的申诉历史记录',
            detail: '只读回显当前 actor 的申诉记录，不开放提交、处罚中心或治理处理台。',
            avatarLabel: '诉',
          ),
          if (profileFeatureStatusVisible) ...<Widget>[
            const SizedBox(height: 18),
            const ProfileFeatureStatusCard(
              snapshot: profileGovernanceAppealsFeatureStatus,
            ),
            const SizedBox(height: 14),
          ] else
            const SizedBox(height: 18),
          _ProfileListSection(
            title: '申诉列表',
            children: data.items.isEmpty
                ? const <Widget>[
                    _ProfileValueRow(title: '当前记录', value: '当前还没有申诉记录'),
                  ]
                : data.items
                      .map(
                        (ProfileGovernanceAppealListItemView item) =>
                            _ProfileActionRow(
                              title: _appealListTitle(item),
                              subtitle: _appealListSubtitle(item),
                              onTap: () => Navigator.of(context).pushNamed(
                                ProfileRoutes.governanceAppealDetailWithCaseId(
                                  item.appealCaseId,
                                ),
                              ),
                            ),
                      )
                      .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class ProfileGovernanceAppealDetailPage extends StatefulWidget {
  const ProfileGovernanceAppealDetailPage({
    super.key,
    required this.appealCaseId,
  });

  final String appealCaseId;

  @override
  State<ProfileGovernanceAppealDetailPage> createState() =>
      _ProfileGovernanceAppealDetailPageState();
}

class _ProfileGovernanceAppealDetailPageState
    extends State<ProfileGovernanceAppealDetailPage> {
  bool _loading = true;
  ProfileGovernanceAppealResult<ProfileGovernanceAppealDetailView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileGovernanceAppealConsumerLayer.instance
        .loadAppealDetail(appealCaseId: widget.appealCaseId);
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取申诉详情',
        message: '正在同步当前申诉记录的最小详情。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: _appealDetailStateTitle(result.state),
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '申诉详情页',
        ),
        actionLabel: _appealRetryLabel(result.state),
        onAction: _appealRetryLabel(result.state) == null ? null : _load,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: '申诉详情',
            subtitle:
                '${_appealStatusLabel(data.statusLabel, data.status)} · ${_appealPenaltyTypeLabel(data.penalty)}',
            detail:
                '申诉编号：${data.appealCaseId} · 提交时间：${profileValueOrFallback(_compactAppealTime(data.submittedAt), '时间未提供')}',
            avatarLabel: '详',
            supportingText:
                '处罚状态：${_appealPenaltyStatusLabel(data.penalty)}${data.decidedAt == null ? '' : ' · 裁决时间：${_compactAppealTime(data.decidedAt)}'}',
          ),
          const SizedBox(height: 18),
          _ProfileListSection(
            title: '申诉内容',
            children: <Widget>[
              _ProfileValueRow(title: '申诉原因', value: data.appealReason),
              _ProfileValueRow(
                title: '申诉状态',
                value: _appealStatusLabel(data.statusLabel, data.status),
              ),
              _ProfileValueRow(
                title: '裁决结果',
                value: _appealDecisionLabel(data.decisionLabel, data.decision),
              ),
              _ProfileValueRow(
                title: '裁决说明',
                value: profileValueOrFallback(data.decisionNote, '当前未返回裁决说明'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '处罚摘要',
            children: <Widget>[
              _ProfileValueRow(
                title: '处罚类型',
                value: _appealPenaltyTypeLabel(data.penalty),
              ),
              _ProfileValueRow(
                title: '处罚状态',
                value: _appealPenaltyStatusLabel(data.penalty),
              ),
              _ProfileValueRow(
                title: '原因摘要',
                value: profileValueOrFallback(
                  data.penalty.reasonSummary,
                  '当前未返回原因摘要',
                ),
              ),
              _ProfileValueRow(
                title: '生效时间',
                value: _appealEffectiveWindow(data.penalty),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '证据附件标识',
            children: data.evidenceFileAssetIds.isEmpty
                ? const <Widget>[
                    _ProfileValueRow(title: '附件', value: '当前未返回证据附件标识'),
                  ]
                : data.evidenceFileAssetIds
                      .map(
                        (String fileAssetId) =>
                            _ProfileValueRow(title: '附件标识', value: fileAssetId),
                      )
                      .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

String _appealListStateTitle(AppPageState state) {
  return switch (state) {
    AppPageState.empty => '当前还没有申诉记录',
    AppPageState.unauthorized => '当前需要先登录',
    AppPageState.notFound => '申诉记录入口当前暂不可用',
    _ => '我的申诉记录当前暂不可用',
  };
}

String _appealDetailStateTitle(AppPageState state) {
  return switch (state) {
    AppPageState.unauthorized => '当前需要先登录',
    AppPageState.notFound => '当前申诉详情不可见',
    _ => '申诉详情当前暂不可用',
  };
}

String? _appealRetryLabel(AppPageState state) {
  return switch (state) {
    AppPageState.errorRetryable => '重试',
    _ => null,
  };
}

String _appealListTitle(ProfileGovernanceAppealListItemView item) {
  final summary = item.penalty.reasonSummary?.trim();
  if (summary != null && summary.isNotEmpty) {
    return summary;
  }
  return '申诉记录 ${item.appealCaseId}';
}

String _appealListSubtitle(ProfileGovernanceAppealListItemView item) {
  final decided = item.decidedAt == null
      ? '裁决时间：待更新'
      : '裁决时间：${_compactAppealTime(item.decidedAt)}';
  return '申诉状态：${_appealStatusLabel(item.statusLabel, item.status)}\n'
      '处罚类型：${_appealPenaltyTypeLabel(item.penalty)}\n'
      '处罚状态：${_appealPenaltyStatusLabel(item.penalty)}\n'
      '提交时间：${_compactAppealTime(item.submittedAt)} · $decided';
}

String _appealStatusLabel(String? label, String status) {
  final visibleLabel = label?.trim();
  if (visibleLabel != null && visibleLabel.isNotEmpty) {
    return visibleLabel;
  }
  return '状态回读：$status';
}

String _appealDecisionLabel(String? label, String? decision) {
  final visibleLabel = label?.trim();
  if (visibleLabel != null && visibleLabel.isNotEmpty) {
    return visibleLabel;
  }
  final visibleDecision = decision?.trim();
  if (visibleDecision == null || visibleDecision.isEmpty) {
    return '当前未返回裁决结果';
  }
  return '裁决回读：$visibleDecision';
}

String _appealPenaltyTypeLabel(ProfileGovernanceAppealPenaltyView penalty) {
  final visibleLabel = penalty.penaltyTypeLabel?.trim();
  if (visibleLabel != null && visibleLabel.isNotEmpty) {
    return visibleLabel;
  }
  return '处罚类型回读：${penalty.penaltyType}';
}

String _appealPenaltyStatusLabel(ProfileGovernanceAppealPenaltyView penalty) {
  final visibleLabel = penalty.penaltyStatusLabel?.trim();
  if (visibleLabel != null && visibleLabel.isNotEmpty) {
    return visibleLabel;
  }
  return '处罚状态回读：${penalty.penaltyStatus}';
}

String _compactAppealTime(String? value) {
  return profileValueOrFallback(profileDisplayTimeLabel(value), '时间未提供');
}

String _appealEffectiveWindow(ProfileGovernanceAppealPenaltyView penalty) {
  final effectiveFrom = penalty.effectiveFrom?.trim();
  final effectiveUntil = penalty.effectiveUntil?.trim();
  if ((effectiveFrom == null || effectiveFrom.isEmpty) &&
      (effectiveUntil == null || effectiveUntil.isEmpty)) {
    return '当前未返回生效时间';
  }
  return '${_compactAppealTime(effectiveFrom)} 至 ${_compactAppealTime(effectiveUntil)}';
}
