import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/rc/rc_release_flags.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_private_operating_system_projection.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/features/profile/presentation/profile_detail_pages.dart';
import 'package:mobile/features/profile/presentation/profile_member_management_sheet.dart';
import 'package:mobile/features/profile/presentation/profile_personal_edit_support.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shared/ui/app_visual_components.dart';
import 'package:mobile/shared/ui/app_visual_tokens.dart';

part 'profile_page_sections.dart';
part 'profile_page_support.dart';

const bool _profileHomeStatusVisible = false;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  ProfileIndexResult? _profileResult;
  ProfileCreditConstraintsResult<ProfileCreditConstraintsStatusView>?
  _creditConstraintsResult;
  ProfilePaymentBillingResult<ProfilePaymentBillingStatusView>?
  _paymentBillingResult;
  ExhibitionLoadResult? _myProjectResult;
  ForumReadResult<ForumPagedCollectionView<ForumMyPostItemView>>? _postsResult;
  ForumReadResult<ForumPagedCollectionView<ForumCommentAssetItemView>>?
  _commentsResult;
  ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>?
  _bookmarksResult;
  ForumReadResult<ForumPagedCollectionView<ForumFollowedAuthorItemView>>?
  _followsResult;
  ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>? _draftsResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ProfileConsumerLayer.instance.loadIndex(),
      ProfileCreditConstraintsConsumerLayer.instance.loadStatus(),
      ProfilePaymentBillingConsumerLayer.instance.loadStatus(),
      ExhibitionConsumerLayer.instance.loadMyProjectList(),
      ForumConsumerLayer.instance.loadMyPosts(),
      ForumConsumerLayer.instance.loadMyComments(),
      ForumConsumerLayer.instance.loadMyBookmarks(),
      ForumConsumerLayer.instance.loadMyFollows(),
      ForumConsumerLayer.instance.loadDraftList(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _profileResult = results[0] as ProfileIndexResult;
      _creditConstraintsResult =
          results[1]
              as ProfileCreditConstraintsResult<
                ProfileCreditConstraintsStatusView
              >;
      _paymentBillingResult =
          results[2]
              as ProfilePaymentBillingResult<ProfilePaymentBillingStatusView>;
      _myProjectResult = results[3] as ExhibitionLoadResult;
      _postsResult =
          results[4]
              as ForumReadResult<ForumPagedCollectionView<ForumMyPostItemView>>;
      _commentsResult =
          results[5]
              as ForumReadResult<
                ForumPagedCollectionView<ForumCommentAssetItemView>
              >;
      _bookmarksResult =
          results[6]
              as ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>;
      _followsResult =
          results[7]
              as ForumReadResult<
                ForumPagedCollectionView<ForumFollowedAuthorItemView>
              >;
      _draftsResult =
          results[8]
              as ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>;
      _loading = false;
    });
  }

  Future<void> _openRouteAndReload(String routeName) async {
    await Navigator.of(context).pushNamed(routeName);
    if (!mounted) {
      return;
    }
    await _load();
  }

  Future<void> _openDisplayEntry(EnterpriseBoardType boardType) async {
    final routeName = await _resolveDisplayEntryRoute(boardType);
    if (!mounted) {
      return;
    }
    await _openRouteAndReload(routeName);
  }

  Future<String> _resolveDisplayEntryRoute(
    EnterpriseBoardType boardType,
  ) async {
    final fallbackRoute = ExhibitionRoutes.enterpriseWorkbenchForBoard(
      boardType.contractName,
    );
    try {
      final workbenchResult = await EnterpriseHubWorkbenchConsumerLayer.instance
          .loadWorkbench(boardType: boardType);
      final workbenchData = workbenchResult.data;
      final enterpriseId = workbenchData?.enterpriseId?.trim();
      if (enterpriseId == null || enterpriseId.isEmpty) {
        return fallbackRoute;
      }
      if (!_shouldPreferPublishedChangeEntry(
        workbenchData?.latestApplication?.applicationStatus,
      )) {
        return fallbackRoute;
      }
      final statusResult = await EnterpriseHubPublishedChangeConsumerLayer
          .instance
          .loadCurrentChangeStatus(
            boardType: boardType,
            enterpriseId: enterpriseId,
          );
      if (statusResult.state != AppPageState.content ||
          statusResult.data == null) {
        return fallbackRoute;
      }
      return ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
        enterpriseId,
        boardType: boardType.contractName,
      );
    } catch (_) {
      return fallbackRoute;
    }
  }

  bool _shouldPreferPublishedChangeEntry(String? applicationStatus) {
    switch (applicationStatus?.trim()) {
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

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final hasSession = AppSessionStore.instance.hasAnySession;
    final profileData = _profileResult?.data;
    final privateOperatingSystemSurface = _resolveProfilePageSurface(
      hasSession: hasSession,
      loading: _loading,
      profileResult: _profileResult,
      shellContext: shellContext,
    );
    final certificationLabel = _profileCertificationLabel(
      hasSession: hasSession,
      profileData: profileData,
    );
    final membershipLabel = _profileMembershipLabel(
      hasSession: hasSession,
      profileData: profileData,
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppVisualTokens.pagePadding,
          18,
          AppVisualTokens.pagePadding,
          28,
        ),
        children: <Widget>[
          _ProfileHubHeader(
            hasSession: hasSession,
            shellContext: shellContext,
            certificationLabel: certificationLabel,
            membershipLabel: membershipLabel,
            activitySummary: _profileActivitySummary(
              hasSession: hasSession,
              profileData: profileData,
            ),
            onTap: () => Navigator.of(context).pushNamed(
              hasSession ? ProfileRoutes.personal : ProfileIdentityRoutes.login,
            ),
          ),
          if (_profileHomeStatusVisible) ...<Widget>[
            const SizedBox(height: 12),
            _ProfileStatusStrip(
              title: privateOperatingSystemSurface.stripTitle,
              message: privateOperatingSystemSurface.stripMessage,
              onRetry: privateOperatingSystemSurface.retryable ? _load : null,
            ),
            const SizedBox(height: 18),
          ] else
            const SizedBox(height: 18),
          Builder(
            builder: (BuildContext context) {
              final companyEntry = _ProfileEntryRow(
                icon: Icons.apartment_rounded,
                title: '我的公司',
                subtitle: _companySummary(
                  profileResult: _profileResult,
                  hasSession: hasSession,
                ),
                onTap: () => _openRouteAndReload(ProfileRoutes.company),
              );
              final memberManagementEntry = _ProfileEntryRow(
                icon: Icons.group_outlined,
                title: '成员管理',
                subtitle: _memberManagementEntrySummary(
                  hasSession: hasSession,
                  profileData: profileData,
                ),
                onTap: () => showOrganizationMembersSheet(context),
              );
              final membershipEntry = _ProfileEntryRow(
                icon: Icons.workspace_premium_outlined,
                title: '我的会员',
                subtitle: _profileHomeStatusVisible
                    ? _myMembershipEntrySummary(
                        hasSession: hasSession,
                        shellContext: shellContext,
                      )
                    : null,
                onTap: () => openProfileMembershipCurrentPage(context),
              );
              final creditEntry = _ProfileEntryRow(
                icon: Icons.shield_outlined,
                title: '我的信用与约束',
                subtitle: _profileHomeStatusVisible
                    ? _creditConstraintsEntrySummary(
                        hasSession: hasSession,
                        result: _creditConstraintsResult,
                      )
                    : null,
                onTap: () => openProfileCreditConstraintsStatusPage(context),
              );
              final reserveCreditScoringEntry = _ProfileEntryRow(
                icon: Icons.bar_chart_outlined,
                title: '组织信用评分 reserve',
                subtitle: _organizationCreditScoringEntrySummary(),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ProfileRoutes.organizationCreditScoring),
              );
              final governanceAppealsEntry = _ProfileEntryRow(
                icon: Icons.gavel_outlined,
                title: '我的申诉记录',
                subtitle: '查看当前账号的申诉记录',
                onTap: () =>
                    _openRouteAndReload(ProfileRoutes.governanceAppeals),
              );
              final paymentEntry = _ProfileEntryRow(
                icon: Icons.receipt_long_outlined,
                title: '支付与账单状态',
                subtitle: _paymentBillingEntrySummary(
                  hasSession: hasSession,
                  result: _paymentBillingResult,
                ),
                onTap: () => openProfilePaymentBillingStatusPage(context),
              );
              final projectEntry = _ProfileEntryRow(
                icon: Icons.folder_open_outlined,
                title: '我的项目',
                subtitle: _profileHomeStatusVisible
                    ? _myProjectListEntrySummary(
                        hasSession: hasSession,
                        result: _myProjectResult,
                      )
                    : null,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.myProjectList),
              );
              final forumEntry = _ProfileEntryRow(
                icon: Icons.forum_outlined,
                title: '我的论坛',
                subtitle: _forumEntrySummary(
                  postsResult: _postsResult,
                  commentsResult: _commentsResult,
                  bookmarksResult: _bookmarksResult,
                  followsResult: _followsResult,
                  draftsResult: _draftsResult,
                ),
                onTap: () =>
                    Navigator.of(context).pushNamed(ProfileRoutes.forum),
              );
              final companyDisplayEntry = _ProfileEntryRow(
                icon: Icons.design_services_outlined,
                title: '我的公司展示',
                subtitle: _enterpriseDisplayAssetEntrySummary('company'),
                onTap: () => _openDisplayEntry(EnterpriseBoardType.company),
              );
              final factoryDisplayEntry = _ProfileEntryRow(
                icon: Icons.factory_outlined,
                title: '我的工厂展示',
                subtitle: _enterpriseDisplayAssetEntrySummary('factory'),
                onTap: () => _openDisplayEntry(EnterpriseBoardType.factory),
              );
              final supplierDisplayEntry = _ProfileEntryRow(
                icon: Icons.chair_outlined,
                title: '我的供应商展示',
                subtitle: _enterpriseDisplayAssetEntrySummary('supplier'),
                onTap: () => _openDisplayEntry(EnterpriseBoardType.supplier),
              );
              final personalTeamDisplayEntry = _ProfileEntryRow(
                icon: Icons.groups_outlined,
                title: '我的个人/团队展示',
                subtitle: _enterpriseDisplayAssetEntrySummary('personal_team'),
                onTap: () => ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  const SnackBar(content: Text('个人/团队展示工作台正在接通，当前先保留选择位。')),
                ),
              );

              if (privateOperatingSystemSurface.showRegroupedSections) {
                return Column(
                  children: <Widget>[
                    _ProfileGroupedSection(
                      title: '身份与组织',
                      children: <Widget>[
                        companyEntry,
                        memberManagementEntry,
                        membershipEntry,
                        if (RcReleaseFlags.profileCreditReserveEntriesEnabled)
                          creditEntry,
                        if (RcReleaseFlags.profileCreditReserveEntriesEnabled)
                          reserveCreditScoringEntry,
                        governanceAppealsEntry,
                        if (RcReleaseFlags.profileFinancialReserveEntriesEnabled)
                          paymentEntry,
                      ],
                    ),
                    const SizedBox(height: 24),
                    _ProfileGroupedSection(
                      title: '我的资产',
                      children: <Widget>[
                        projectEntry,
                        if (RcReleaseFlags.forumPublishingEnabled) forumEntry,
                        companyDisplayEntry,
                        factoryDisplayEntry,
                        supplierDisplayEntry,
                        personalTeamDisplayEntry,
                      ],
                    ),
                  ],
                );
              }

              return _ProfileGroupedSection(
                title: '常用入口',
                children: <Widget>[
                  companyEntry,
                  memberManagementEntry,
                  membershipEntry,
                  if (RcReleaseFlags.profileCreditReserveEntriesEnabled)
                    creditEntry,
                  if (RcReleaseFlags.profileCreditReserveEntriesEnabled)
                    reserveCreditScoringEntry,
                  governanceAppealsEntry,
                  if (RcReleaseFlags.profileFinancialReserveEntriesEnabled)
                    paymentEntry,
                  projectEntry,
                  if (RcReleaseFlags.forumPublishingEnabled) forumEntry,
                  companyDisplayEntry,
                  factoryDisplayEntry,
                  supplierDisplayEntry,
                  personalTeamDisplayEntry,
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _ProfileGroupedSection(
            title: '设置',
            children: <Widget>[
              _ProfileEntryRow(
                icon: Icons.settings_outlined,
                title: '设置',
                subtitle: '账号与安全、通知、隐私与权限等',
                onTap: () =>
                    Navigator.of(context).pushNamed(ProfileRoutes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
