part of 'profile_page.dart';

class _ProfilePageSurface {
  const _ProfilePageSurface({
    required this.stripTitle,
    required this.stripMessage,
    required this.showRegroupedSections,
    this.retryable = false,
  });

  final String stripTitle;
  final String stripMessage;
  final bool showRegroupedSections;
  final bool retryable;
}

_ProfilePageSurface _resolveProfilePageSurface({
  required bool hasSession,
  required bool loading,
  required ProfileIndexResult? profileResult,
  required AppShellContextData shellContext,
}) {
  final result = profileResult;
  if (!hasSession) {
    return const _ProfilePageSurface(
      stripTitle: '当前会话暂不可用',
      stripMessage: '当前没有可验证的会话，我的楼不展示伪造账号摘要或整理结果。',
      showRegroupedSections: false,
    );
  }

  if (loading || result == null) {
    return const _ProfilePageSurface(
      stripTitle: '正在同步私域整理引用',
      stripMessage: '稍候即可看到当前身份、组织与有界整理说明。',
      showRegroupedSections: false,
    );
  }

  if (result.state != AppPageState.content) {
    return _ProfilePageSurface(
      stripTitle: '账号摘要暂未完整返回',
      stripMessage: profileVisibleReadMessage(
        state: result.state,
        rawMessage: result.message,
        surfaceLabel: '我的楼',
      ),
      showRegroupedSections: false,
      retryable: result.state == AppPageState.errorRetryable,
    );
  }

  final resolvedProjection = resolveProfilePrivateOperatingSystemProjection(
    profileData: result.data,
    shellContext: shellContext,
  );
  if (resolvedProjection is String) {
    return _ProfilePageSurface(
      stripTitle: '私域整理引用当前暂不可用',
      stripMessage: '$resolvedProjection 页面保持既有入口顺序，不伪造整理结果。',
      showRegroupedSections: false,
    );
  }

  final projection =
      resolvedProjection as ProfilePrivateOperatingSystemProjectionView;
  return _ProfilePageSurface(
    stripTitle: '当前为私域整理视图',
    stripMessage: _profilePrivateOperatingSystemSurfaceMessage(projection),
    showRegroupedSections: true,
  );
}

String _companySummary({
  required ProfileIndexResult? profileResult,
  required bool hasSession,
}) {
  const summary = '查看当前公司与组织';
  if (!hasSession) {
    return summary;
  }
  if (profileResult == null || profileResult.state != AppPageState.content) {
    return summary;
  }
  return summary;
}

String _profileCertificationLabel({
  required bool hasSession,
  required ProfileIndexView? profileData,
}) {
  if (!hasSession) {
    return '会话未验证';
  }
  if (profileData == null) {
    return '状态暂不可用';
  }
  return profileDisplayCertificationStatus(profileData.certification.status);
}

String _profileMembershipLabel({
  required bool hasSession,
  required ProfileIndexView? profileData,
}) {
  if (!hasSession) {
    return '会话未验证';
  }
  if (profileData == null) {
    return '状态暂不可用';
  }
  return profileDisplayMembershipStatus(profileData.membership.status);
}

String _profileActivitySummary({
  required bool hasSession,
  required ProfileIndexView? profileData,
}) {
  const summary = '进入个人资料，查看当前资料摘要与账号信息';
  if (!hasSession) {
    return summary;
  }
  if (profileData == null) {
    return summary;
  }
  return summary;
}

String _memberManagementEntrySummary({
  required bool hasSession,
  required ProfileIndexView? profileData,
}) {
  const summary = '查看当前组织成员';
  if (!hasSession) {
    return summary;
  }
  if (profileData == null) {
    return summary;
  }
  if ((profileData.organization.organizationId ?? '').trim().isEmpty) {
    return summary;
  }
  return summary;
}

String _forumEntrySummary({
  required ForumReadResult<ForumPagedCollectionView<ForumMyPostItemView>>?
  postsResult,
  required ForumReadResult<ForumPagedCollectionView<ForumCommentAssetItemView>>?
  commentsResult,
  required ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>?
  bookmarksResult,
  required ForumReadResult<ForumPagedCollectionView<ForumTopicCardView>>?
  followsResult,
  required ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>?
  draftsResult,
}) {
  const summary = '查看帖子、评论、收藏、关注与草稿';
  if (postsResult == null ||
      commentsResult == null ||
      bookmarksResult == null ||
      followsResult == null ||
      draftsResult == null) {
    return summary;
  }
  return summary;
}

String _enterpriseDisplayAssetEntrySummary(String assetKey) {
  return switch (assetKey.trim()) {
    'company' => '设计搭建、主场服务与活动执行能力',
    'factory' => '工艺、产能、配送与交付能力',
    'supplier' => '展会物料租赁、供应品类与响应时效',
    'personal_team' => '个人设计师、团队与班组专区预留',
    _ => '',
  };
}

String _myProjectListEntrySummary({
  required bool hasSession,
  required ExhibitionLoadResult? result,
}) {
  const base = '当前组织项目列表与项目详情入口';
  if (!hasSession) {
    return base;
  }
  if (result == null || result.state != AppPageState.content) {
    return base;
  }

  final payload = result.payload;
  if (payload is! Map) {
    return base;
  }
  final ongoing = payload['ongoingProjects'];
  final historical = payload['historicalProjects'];
  if (ongoing is! List || historical is! List) {
    return base;
  }
  return '$base · 进行中 ${ongoing.length} 个 · 历史 ${historical.length} 个';
}

String _myMembershipEntrySummary({
  required bool hasSession,
  required AppShellContextData shellContext,
}) {
  const base = '当前会员状态与权益摘要';
  if (!hasSession) {
    return '部分可用：$base';
  }
  final pieces = <String>[
    profileDisplayPaidMembershipTier(shellContext.paidMembershipTier),
    ...shellContext.paidMembershipEntitlementsSummary,
    ...shellContext.paidMembershipQuotaSummary,
    if ((shellContext.paidMembershipNextRefreshAt ?? '').trim().isNotEmpty)
      '下次刷新 ${shellContext.paidMembershipNextRefreshAt!.trim()}',
  ];
  if ((shellContext.organizationId ?? '').trim().isEmpty || pieces.isEmpty) {
    return '部分可用：$base';
  }
  return '部分可用：$base · ${pieces.join(' · ')}';
}

String _creditConstraintsEntrySummary({
  required bool hasSession,
  required ProfileCreditConstraintsResult<ProfileCreditConstraintsStatusView>?
  result,
}) {
  const base = '查看信用、保证金与交易保障摘要';
  if (!hasSession) {
    return base;
  }
  if (result == null || result.state != AppPageState.content) {
    return base;
  }
  final data = result.data;
  if (data == null) {
    return base;
  }
  final pieces = <String>[
    profileDisplayCreditConstraintsSummaryStatus(
      data.privateSummary.summaryStatus,
    ),
    profileDisplayCreditConstraintStatus(
      data.privateSummary.creditConstraintStatus,
    ),
    profileDisplayDepositPostureStatus(
      data.privateSummary.depositPostureStatus,
    ),
    profileDisplayTransactionGuaranteeEligibilityStatus(
      data.privateSummary.transactionGuaranteeEligibilityStatus,
    ),
  ];
  return '当前信用、保证金与交易保障摘要 · ${pieces.join(' · ')}';
}

String _organizationCreditScoringEntrySummary() {
  return '未来主线 reserve，只读 status / explanation / handoff';
}

String _paymentBillingEntrySummary({
  required bool hasSession,
  required ProfilePaymentBillingResult<ProfilePaymentBillingStatusView>? result,
}) {
  const base = '查看支付与账单摘要';
  if (!hasSession) {
    return base;
  }
  if (result == null || result.state != AppPageState.content) {
    return base;
  }
  final data = result.data;
  if (data == null) {
    return base;
  }
  return base;
}

String _profilePrivateOperatingSystemSurfaceMessage(
  ProfilePrivateOperatingSystemProjectionView projection,
) {
  final familySummary = projection.visibleFamilyKeys
      .map(_profilePrivateOperatingSystemFamilyLabel)
      .join('、');
  final pieces = <String>[
    '保留 $familySummary 的一层存在与顺序',
    _profilePrivateOperatingSystemRegroupingHint(
      projection.regroupingExplanationKey,
    ),
    _profilePrivateOperatingSystemOrderingHint(
      projection.orderingExplanationKey,
    ),
    _profilePrivateOperatingSystemCorridorHint(
      projection.corridorExplanationKey,
    ),
    _profilePrivateOperatingSystemNavigationHint(
      projection.navigationExplanationKey,
    ),
    _profilePrivateOperatingSystemDependencyHint(
      projection.dependencyExplanationKey,
      projection.dependencyFamilyKey,
    ),
    '参考 ${projection.orderingReferenceVersion}',
  ];
  return '当前只在我的楼内做有界整理，${pieces.join('；')}。';
}

String _profilePrivateOperatingSystemRegroupingHint(String? key) {
  return switch (key?.trim()) {
    'my_building_bounded_private_regrouping' => '当前只做 bounded regrouping',
    final String other when _profilePageContainsChinese(other) => other,
    _ => '当前 regrouping 只作为引用说明',
  };
}

String _profilePrivateOperatingSystemOrderingHint(String? key) {
  return switch (key?.trim()) {
    'my_building_compact_hub_order_preserved' => '现有 first-level family 顺序继续保留',
    final String other when _profilePageContainsChinese(other) => other,
    _ => '当前顺序只作为引用说明',
  };
}

String _profilePrivateOperatingSystemCorridorHint(String? key) {
  return switch (key?.trim()) {
    'my_building_compact_hub_corridor_visible' => '当前 corridor 只在我的楼内可见',
    final String other when _profilePageContainsChinese(other) => other,
    _ => '当前 corridor 只表达有界导流',
  };
}

String _profilePrivateOperatingSystemNavigationHint(String? key) {
  return switch (key?.trim()) {
    'my_building_navigation_reference' => '当前导航只作为 bounded reference',
    final String other when _profilePageContainsChinese(other) => other,
    _ => '当前导航只保留有界说明',
  };
}

String _profilePrivateOperatingSystemDependencyHint(
  String? explanationKey,
  String? familyKey,
) {
  final familyLabel = switch (familyKey?.trim()) {
    'future_cross_building_shell_rewrite' =>
      '后续 cross-building shell rewrite 依赖',
    final String other when _profilePageContainsChinese(other) => other,
    final String other when other.isNotEmpty => other,
    _ => '后续依赖',
  };
  return switch (explanationKey?.trim()) {
    'future_cross_building_shell_rewrite_strategic_hold' =>
      '更大范围动作仍依赖 $familyLabel，当前保持战略保留',
    final String other when _profilePageContainsChinese(other) => other,
    _ => '$familyLabel 当前仍保持受控保留态',
  };
}

String _profilePrivateOperatingSystemFamilyLabel(String familyKey) {
  return switch (familyKey.trim()) {
    'my_company' => '我的公司',
    'certification_membership_status' => '公司认证与我的身份',
    'my_projects' => '我的项目',
    'my_forum' => '我的论坛',
    'settings' => '设置',
    final String other when _profilePageContainsChinese(other) => other,
    _ => familyKey,
  };
}

bool _profilePageContainsChinese(String value) {
  return RegExp(r'[\u4e00-\u9fff]').hasMatch(value);
}
