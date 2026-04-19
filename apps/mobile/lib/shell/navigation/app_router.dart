import 'package:flutter/material.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_pages.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_list_controls.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_list_pages.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_workbench_pages.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/features/profile/presentation/profile_detail_pages.dart';
import 'package:mobile/features/profile/presentation/profile_forum_pages.dart';
import 'package:mobile/features/profile/presentation/profile_identity_access_pages.dart';
import 'package:mobile/features/profile/presentation/profile_identity_legal_pages.dart';
import 'package:mobile/features/profile/presentation/profile_identity_password_pages.dart';
import 'package:mobile/features/profile/presentation/profile_organization_pages.dart';
import 'package:mobile/features/profile/presentation/profile_organization_switch_page.dart';
import 'package:mobile/shell/navigation/app_building.dart';
import 'package:mobile/shell/presentation/route_unavailable_page.dart';
import 'package:mobile/shell/presentation/app_shell_scaffold.dart';
import 'package:mobile/shell/shell_page.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeUri = _routeUri(settings.name);
    final forumRoute = _matchExhibitionForumRoute(settings);
    if (forumRoute != null) {
      return forumRoute;
    }
    final enterpriseRoute = _matchExhibitionEnterpriseHubRoute(settings);
    if (enterpriseRoute != null) {
      return enterpriseRoute;
    }
    final exhibitionRoute = _matchExhibitionTradeRoute(settings);
    if (exhibitionRoute != null) {
      return exhibitionRoute;
    }
    final profileRoute = _matchProfileRoute(settings);
    if (profileRoute != null) {
      return profileRoute;
    }
    final profileIdentityRoute = _matchProfileIdentityRoute(settings);
    if (profileIdentityRoute != null) {
      return profileIdentityRoute;
    }

    final building = appBuildingFromRoute(routeUri.path);

    if (building == null) {
      return _routeUnavailable(settings);
    }

    return MaterialPageRoute<void>(
      settings: RouteSettings(
        name: building.routePath,
        arguments: settings.arguments,
      ),
      builder: (_) => AppShellPage(currentBuilding: building),
    );
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _routeUnavailable(settings);
  }

  Route<dynamic> _routeUnavailable(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShellScaffold(
        currentBuilding: AppBuilding.exhibition,
        titleOverride: '路由不可用',
        child: RouteUnavailablePage(routeName: settings.name),
      ),
    );
  }

  Route<dynamic>? _matchExhibitionForumRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) {
      return null;
    }

    final routeUri = _routeUri(routeName);
    final routePath = routeUri.path;
    final topicId = _matchPrefixedId(routeUri, ExhibitionRoutes.forumTopics);
    final postId = _matchPrefixedId(routeUri, ExhibitionRoutes.forumPosts);
    final authorId = _matchPrefixedId(routeUri, ExhibitionRoutes.forumAuthors);
    final reportTicketId = _matchPrefixedId(
      routeUri,
      ExhibitionRoutes.forumMeReports,
    );
    final commentPostId = routeUri.queryParameters['postId'];
    final initialFeedTopicId = routeUri.queryParameters['topicId'];

    final Widget? child = switch (routePath) {
      ExhibitionRoutes.forum => ForumHubPage(
        initialTopicId: initialFeedTopicId,
      ),
      ExhibitionRoutes.forumSquare => ForumFeedPage(
        scope: ForumFeedScope.square,
        initialTopicId: initialFeedTopicId,
      ),
      ExhibitionRoutes.forumLocal => ForumFeedPage(
        scope: ForumFeedScope.local,
        initialTopicId: initialFeedTopicId,
      ),
      ExhibitionRoutes.forumFollowing => ForumFeedPage(
        scope: ForumFeedScope.following,
        initialTopicId: initialFeedTopicId,
      ),
      ExhibitionRoutes.forumTopics => const ForumTopicsPage(),
      ExhibitionRoutes.forumPublish => ForumPublishPage(
        initialDraftId: routeUri.queryParameters['draftId'],
      ),
      ExhibitionRoutes.forumDrafts => const ForumDraftsPage(),
      ExhibitionRoutes.forumSearch => ForumSearchPage(
        initialQuery: routeUri.queryParameters['q'],
      ),
      _ when authorId != null => ForumAuthorProfilePage(authorId: authorId),
      ExhibitionRoutes.forumComments => ForumCommentInteractionPage(
        postId: commentPostId,
      ),
      ExhibitionRoutes.forumMePosts => const ForumMeCollectionPage(
        scope: ForumMeScope.posts,
      ),
      ExhibitionRoutes.forumMeComments => const ForumMeCollectionPage(
        scope: ForumMeScope.comments,
      ),
      ExhibitionRoutes.forumMeBookmarks => const ForumMeCollectionPage(
        scope: ForumMeScope.bookmarks,
      ),
      ExhibitionRoutes.forumMeFollows => const ForumMeCollectionPage(
        scope: ForumMeScope.follows,
      ),
      ExhibitionRoutes.forumMeReports => const ForumMyReportListPage(),
      _ when reportTicketId != null => ForumMyReportDetailPage(
        ticketId: reportTicketId,
      ),
      _ when topicId != null => ForumTopicDetailPage(topicId: topicId),
      _ when postId != null => ForumPostDetailPage(postId: postId),
      _ => null,
    };

    if (child == null) {
      return null;
    }

    final title = switch (routePath) {
      ExhibitionRoutes.forum => '论坛',
      ExhibitionRoutes.forumSquare => '广场',
      ExhibitionRoutes.forumLocal => '本地',
      ExhibitionRoutes.forumFollowing => '关注',
      ExhibitionRoutes.forumTopics => '话题分类',
      ExhibitionRoutes.forumComments => '评论互动区',
      ExhibitionRoutes.forumPublish => '发帖',
      ExhibitionRoutes.forumDrafts => '草稿',
      ExhibitionRoutes.forumSearch => '搜索',
      _ when authorId != null => '作者主页',
      ExhibitionRoutes.forumMePosts => '我的帖子',
      ExhibitionRoutes.forumMeComments => '我的评论',
      ExhibitionRoutes.forumMeBookmarks => '我的收藏',
      ExhibitionRoutes.forumMeFollows => '我的关注',
      ExhibitionRoutes.forumMeReports => '我的举报记录',
      _ when reportTicketId != null => '举报详情',
      _ when topicId != null => '话题详情',
      _ when postId != null => '帖子详情',
      _ => '论坛',
    };
    final showForumToolActions =
        <String>{
          ExhibitionRoutes.forum,
          ExhibitionRoutes.forumSquare,
          ExhibitionRoutes.forumLocal,
          ExhibitionRoutes.forumFollowing,
          ExhibitionRoutes.forumTopics,
          ExhibitionRoutes.forumComments,
        }.contains(routePath) ||
        authorId != null ||
        topicId != null ||
        postId != null;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => AppShellScaffold(
        currentBuilding: AppBuilding.exhibition,
        titleOverride: title,
        showStageBanner: false,
        appBarActions: switch (routePath) {
          ExhibitionRoutes.forumPublish => <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(ExhibitionRoutes.forumDrafts);
              },
              child: const Text('草稿'),
            ),
          ],
          _
              when showForumToolActions &&
                  routePath != ExhibitionRoutes.forumSearch =>
            <Widget>[
              IconButton(
                tooltip: '搜索论坛内容',
                onPressed: () {
                  Navigator.of(context).pushNamed(ExhibitionRoutes.forumSearch);
                },
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          _ => const <Widget>[],
        },
        floatingActionButton:
            showForumToolActions && routePath != ExhibitionRoutes.forumPublish
            ? FloatingActionButton.small(
                tooltip: '发布帖子',
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumPublish);
                },
                child: const Icon(Icons.add_rounded),
              )
            : null,
        child: child,
      ),
    );
  }

  Route<dynamic>? _matchExhibitionEnterpriseHubRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) {
      return null;
    }

    final routeUri = _routeUri(routeName);
    final routePath = routeUri.path;
    final boardListActionController = EnterpriseBoardListActionController();

    final Widget? child = switch (routePath) {
      ExhibitionRoutes.companies => EnterpriseBoardListPage(
        boardType: EnterpriseBoardType.company,
        actionController: boardListActionController,
      ),
      ExhibitionRoutes.factories => EnterpriseBoardListPage(
        boardType: EnterpriseBoardType.factory,
        actionController: boardListActionController,
      ),
      ExhibitionRoutes.suppliers => EnterpriseBoardListPage(
        boardType: EnterpriseBoardType.supplier,
        actionController: boardListActionController,
      ),
      ExhibitionRoutes.companyDetail => EnterpriseDetailPage(
        boardType: EnterpriseBoardType.company,
        enterpriseId: routeUri.queryParameters['enterpriseId'],
      ),
      ExhibitionRoutes.factoryDetail => EnterpriseDetailPage(
        boardType: EnterpriseBoardType.factory,
        enterpriseId: routeUri.queryParameters['enterpriseId'],
      ),
      ExhibitionRoutes.supplierDetail => EnterpriseDetailPage(
        boardType: EnterpriseBoardType.supplier,
        enterpriseId: routeUri.queryParameters['enterpriseId'],
      ),
      ExhibitionRoutes.enterpriseApply => EnterpriseApplicationPage(
        initialBoardType: EnterpriseBoardType.fromRaw(
          routeUri.queryParameters['boardType'],
        ),
      ),
      ExhibitionRoutes.companyDisplayWorkbench =>
        const EnterpriseApplicationPage(
          initialBoardType: EnterpriseBoardType.company,
        ),
      ExhibitionRoutes.factoryDisplayWorkbench =>
        const EnterpriseApplicationPage(
          initialBoardType: EnterpriseBoardType.factory,
        ),
      ExhibitionRoutes.supplierDisplayWorkbench =>
        const EnterpriseApplicationPage(
          initialBoardType: EnterpriseBoardType.supplier,
        ),
      ExhibitionRoutes.enterpriseCaseEditor => EnterpriseApplicationPage(
        initialBoardType: EnterpriseBoardType.fromRaw(
          routeUri.queryParameters['boardType'],
        ),
      ),
      ExhibitionRoutes.companyDisplayCaseEditor =>
        const EnterpriseApplicationPage(
          initialBoardType: EnterpriseBoardType.company,
        ),
      ExhibitionRoutes.factoryDisplayCaseEditor =>
        const EnterpriseApplicationPage(
          initialBoardType: EnterpriseBoardType.factory,
        ),
      ExhibitionRoutes.supplierDisplayCaseEditor =>
        const EnterpriseApplicationPage(
          initialBoardType: EnterpriseBoardType.supplier,
        ),
      ExhibitionRoutes.enterpriseApplicationStatus =>
        EnterpriseApplicationStatusPage(
          applicationId: routeUri.queryParameters['applicationId'],
          boardType: EnterpriseBoardType.fromRaw(
            routeUri.queryParameters['boardType'],
          ),
        ),
      ExhibitionRoutes.companyDisplayStatus => EnterpriseApplicationStatusPage(
        applicationId: routeUri.queryParameters['applicationId'],
        boardType: EnterpriseBoardType.company,
      ),
      ExhibitionRoutes.factoryDisplayStatus => EnterpriseApplicationStatusPage(
        applicationId: routeUri.queryParameters['applicationId'],
        boardType: EnterpriseBoardType.factory,
      ),
      ExhibitionRoutes.supplierDisplayStatus => EnterpriseApplicationStatusPage(
        applicationId: routeUri.queryParameters['applicationId'],
        boardType: EnterpriseBoardType.supplier,
      ),
      _ => null,
    };

    if (child == null) {
      return null;
    }

    final title = switch (routePath) {
      ExhibitionRoutes.companies => '优秀公司',
      ExhibitionRoutes.factories => '优秀工厂',
      ExhibitionRoutes.suppliers => '优秀供应商',
      ExhibitionRoutes.companyDetail => '公司详情',
      ExhibitionRoutes.factoryDetail => '工厂详情',
      ExhibitionRoutes.supplierDetail => '供应商详情',
      ExhibitionRoutes.enterpriseApply ||
      ExhibitionRoutes.companyDisplayWorkbench ||
      ExhibitionRoutes.factoryDisplayWorkbench ||
      ExhibitionRoutes.supplierDisplayWorkbench =>
        _enterpriseWorkbenchRouteTitle(routeUri),
      ExhibitionRoutes.enterpriseCaseEditor ||
      ExhibitionRoutes.companyDisplayCaseEditor ||
      ExhibitionRoutes.factoryDisplayCaseEditor ||
      ExhibitionRoutes.supplierDisplayCaseEditor =>
        _enterpriseCaseEditorRouteTitle(routeUri),
      ExhibitionRoutes.enterpriseApplicationStatus ||
      ExhibitionRoutes.companyDisplayStatus ||
      ExhibitionRoutes.factoryDisplayStatus ||
      ExhibitionRoutes.supplierDisplayStatus => _enterpriseStatusRouteTitle(
        routeUri,
      ),
      _ => '展览',
    };

    final appBarActions = switch (routePath) {
      ExhibitionRoutes.companies ||
      ExhibitionRoutes.factories ||
      ExhibitionRoutes.suppliers => <Widget>[
        IconButton(
          onPressed: boardListActionController.triggerSearch,
          icon: const Icon(Icons.search_rounded),
        ),
      ],
      _ => const <Widget>[],
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShellScaffold(
        currentBuilding: AppBuilding.exhibition,
        titleOverride: title,
        appBarActions: appBarActions,
        child: child,
      ),
    );
  }

  Route<dynamic>? _matchExhibitionTradeRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) {
      return null;
    }

    final routeUri = _routeUri(routeName);
    final routePath = routeUri.path;

    final Widget? child = switch (routePath) {
      ExhibitionRoutes.showcase => const ProjectListPage(
        surface: ProjectListSurface.showcase,
      ),
      ExhibitionRoutes.projectList => const ProjectListPage(),
      ExhibitionRoutes.myProjectList => const MyProjectListPage(),
      ExhibitionRoutes.projectCreate => const ProjectCreatePage(),
      ExhibitionRoutes.projectEdit => ProjectCreatePage(
        projectId: routeUri.queryParameters['projectId'],
      ),
      ExhibitionRoutes.projectDetail => ProjectDetailPage(
        projectId: routeUri.queryParameters['projectId'],
      ),
      ExhibitionRoutes.myProjectDetail => MyProjectDetailPage(
        projectId: routeUri.queryParameters['projectId'],
      ),
      ExhibitionRoutes.projectClarification => ProjectClarificationPage(
        projectId: routeUri.queryParameters['projectId'],
      ),
      ExhibitionRoutes.bidThread => BidThreadPage(
        projectId: routeUri.queryParameters['projectId'],
        bidId: routeUri.queryParameters['bidId'],
      ),
      ExhibitionRoutes.bidSubmit => BidSubmitPage(
        projectId: routeUri.queryParameters['projectId'],
        mode: routeUri.queryParameters['mode'],
      ),
      ExhibitionRoutes.orderDetail => OrderDetailPage(
        orderId: routeUri.queryParameters['orderId'],
      ),
      ExhibitionRoutes.contractDetail => ContractDetailPage(
        orderId: routeUri.queryParameters['orderId'],
      ),
      ExhibitionRoutes.milestoneList => MilestoneListPage(
        orderId: routeUri.queryParameters['orderId'],
      ),
      ExhibitionRoutes.milestoneSubmit => MilestoneSubmitPage(
        milestoneId: routeUri.queryParameters['milestoneId'],
      ),
      ExhibitionRoutes.inspectionDetail => InspectionDetailPage(
        milestoneId: routeUri.queryParameters['milestoneId'],
      ),
      ExhibitionRoutes.inspectionSubmit => InspectionSubmitPage(
        milestoneId: routeUri.queryParameters['milestoneId'],
      ),
      ExhibitionRoutes.ratingEntry => RatingEntryPage(
        orderId: routeUri.queryParameters['orderId'],
      ),
      ExhibitionRoutes.disputeOpen => DisputeOpenPage(
        orderId: routeUri.queryParameters['orderId'],
      ),
      ExhibitionRoutes.disputeWithdraw => DisputeWithdrawPage(
        orderId: routeUri.queryParameters['orderId'],
      ),
      _ => null,
    };

    if (child == null) {
      return null;
    }

    final title = switch (routePath) {
      ExhibitionRoutes.showcase => '项目展示',
      ExhibitionRoutes.projectList => '项目列表',
      ExhibitionRoutes.myProjectList => '我的项目',
      ExhibitionRoutes.projectCreate => '创建项目',
      ExhibitionRoutes.projectEdit => '编辑项目',
      ExhibitionRoutes.projectDetail => '项目详情',
      ExhibitionRoutes.myProjectDetail => '我的项目详情',
      ExhibitionRoutes.projectClarification => '项目澄清',
      ExhibitionRoutes.bidThread => '沟通与投标',
      ExhibitionRoutes.bidSubmit =>
        routeUri.queryParameters['mode'] == 'result' ? '竞标结果' : '竞标提交',
      ExhibitionRoutes.orderDetail => '订单详情',
      ExhibitionRoutes.contractDetail => '合同详情',
      ExhibitionRoutes.milestoneList => '里程碑列表',
      ExhibitionRoutes.milestoneSubmit => '里程碑提交',
      ExhibitionRoutes.inspectionDetail => '验收详情',
      ExhibitionRoutes.inspectionSubmit => '验收提交',
      ExhibitionRoutes.ratingEntry => '评价入口',
      ExhibitionRoutes.disputeOpen => '争议开启入口',
      ExhibitionRoutes.disputeWithdraw => '争议撤回入口',
      _ => '展览',
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShellScaffold(
        currentBuilding: AppBuilding.exhibition,
        titleOverride: title,
        child: child,
      ),
    );
  }

  Route<dynamic>? _matchProfileRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) {
      return null;
    }

    final routeUri = _routeUri(routeName);
    final routePath = routeUri.path;
    final appealCaseId = _matchPrefixedId(
      routeUri,
      ProfileRoutes.governanceAppeals,
    );
    final Widget? child = switch (routePath) {
      ProfileRoutes.personal => const ProfilePersonalPage(),
      ProfileRoutes.company => const ProfileCompanyPage(),
      ProfileRoutes.organizationCreditScoring =>
        const ProfileOrganizationCreditScoringStatusPage(),
      ProfileRoutes.organizationCreditScoringExplanation =>
        const ProfileOrganizationCreditScoringExplanationPage(),
      ProfileRoutes.organizationCreditScoringHandoff =>
        const ProfileOrganizationCreditScoringHandoffPage(),
      ProfileRoutes.forum => const ProfileForumPage(),
      ProfileRoutes.governanceAppeals =>
        const ProfileGovernanceAppealListPage(),
      _ when appealCaseId != null => ProfileGovernanceAppealDetailPage(
        appealCaseId: appealCaseId,
      ),
      ProfileRoutes.settings => const ProfileSettingsPage(),
      _ => null,
    };

    if (child == null) {
      return null;
    }

    final title = switch (routePath) {
      ProfileRoutes.personal => '个人资料',
      ProfileRoutes.company => '我的公司',
      ProfileRoutes.organizationCreditScoring => '组织信用评分 reserve',
      ProfileRoutes.organizationCreditScoringExplanation => '组织信用评分说明',
      ProfileRoutes.organizationCreditScoringHandoff => '组织信用评分衔接',
      ProfileRoutes.forum => '我的论坛',
      ProfileRoutes.governanceAppeals => '我的申诉记录',
      _ when appealCaseId != null => '申诉详情',
      ProfileRoutes.settings => '设置',
      _ => '我的',
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShellScaffold(
        currentBuilding: AppBuilding.profile,
        titleOverride: title,
        showStageBanner: false,
        child: child,
      ),
    );
  }

  Route<dynamic>? _matchProfileIdentityRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) {
      return null;
    }

    final routePath = _routeUri(routeName).path;
    final Widget? child = switch (routePath) {
      ProfileIdentityRoutes.login => const LoginEntryPage(),
      ProfileIdentityRoutes.organizationHandoff =>
        const OrganizationHandoffPage(),
      ProfileIdentityRoutes.organizationSwitch =>
        const OrganizationSwitchPage(),
      ProfileIdentityRoutes.organizationCreate =>
        const OrganizationCreatePage(),
      ProfileIdentityRoutes.organizationJoin => const OrganizationJoinPage(),
      ProfileIdentityRoutes.certificationCurrent =>
        const CertificationStatusPage(),
      ProfileIdentityRoutes.certificationSubmit =>
        const CertificationSubmitPage(),
      ProfileIdentityRoutes.personalCertificationSubmit =>
        const PersonalCertificationSubmitPage(),
      ProfileIdentityRoutes.certificationRevalidate =>
        const CertificationRevalidatePage(),
      ProfileIdentityRoutes.certificationResubmit =>
        const CertificationResubmitPage(),
      ProfileIdentityRoutes.sessionCenter => const SessionCenterPage(),
      ProfileIdentityRoutes.userAgreement => const UserAgreementPage(),
      ProfileIdentityRoutes.privacyPolicy => const PrivacyPolicyPage(),
      ProfileIdentityRoutes.passwordReset => const PasswordResetPage(),
      ProfileIdentityRoutes.passwordSet => const SetPasswordPage(),
      _ => null,
    };

    if (child == null) {
      return null;
    }

    final title = switch (routePath) {
      ProfileIdentityRoutes.login => '登录入口',
      ProfileIdentityRoutes.organizationHandoff => '公司与组织',
      ProfileIdentityRoutes.organizationSwitch => '切换当前公司/组织',
      ProfileIdentityRoutes.organizationCreate => '组织资料',
      ProfileIdentityRoutes.organizationJoin => '加入组织',
      ProfileIdentityRoutes.certificationCurrent => '公司认证与我的身份',
      ProfileIdentityRoutes.certificationSubmit => '提交认证',
      ProfileIdentityRoutes.personalCertificationSubmit => '提交我的认证',
      ProfileIdentityRoutes.certificationRevalidate => '更正认证资料',
      ProfileIdentityRoutes.certificationResubmit => '重新提交认证',
      ProfileIdentityRoutes.sessionCenter => '会话与设备',
      ProfileIdentityRoutes.userAgreement => '用户协议',
      ProfileIdentityRoutes.privacyPolicy => '隐私政策',
      ProfileIdentityRoutes.passwordReset => '重置密码',
      ProfileIdentityRoutes.passwordSet => '设置登录密码',
      _ => '我的',
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShellScaffold(
        currentBuilding: AppBuilding.profile,
        titleOverride: title,
        child: child,
      ),
    );
  }

  Uri _routeUri(String? routeName) {
    final rawRoute = routeName == null || routeName.isEmpty ? '/' : routeName;
    return Uri.parse(rawRoute);
  }

  String _enterpriseWorkbenchRouteTitle(Uri routeUri) {
    final boardType =
        EnterpriseBoardType.fromRaw(
          ExhibitionRoutes.enterpriseBoardTypeFromPrivatePath(routeUri.path),
        ) ??
        EnterpriseBoardType.fromRaw(routeUri.queryParameters['boardType']);
    return switch (boardType) {
      EnterpriseBoardType.company => '公司展示工作台',
      EnterpriseBoardType.factory => '工厂展示工作台',
      EnterpriseBoardType.supplier => '供应商展示工作台',
      null => '企业展示工作台',
    };
  }

  String _enterpriseCaseEditorRouteTitle(Uri routeUri) {
    final boardType =
        EnterpriseBoardType.fromRaw(
          ExhibitionRoutes.enterpriseBoardTypeFromPrivatePath(routeUri.path),
        ) ??
        EnterpriseBoardType.fromRaw(routeUri.queryParameters['boardType']);
    return switch (boardType) {
      EnterpriseBoardType.company => '公司案例编辑工作台',
      EnterpriseBoardType.factory => '工厂案例编辑工作台',
      EnterpriseBoardType.supplier => '供应商案例编辑工作台',
      null => '案例编辑工作台',
    };
  }

  String _enterpriseStatusRouteTitle(Uri routeUri) {
    final boardType =
        EnterpriseBoardType.fromRaw(
          ExhibitionRoutes.enterpriseBoardTypeFromPrivatePath(routeUri.path),
        ) ??
        EnterpriseBoardType.fromRaw(routeUri.queryParameters['boardType']);
    return switch (boardType) {
      EnterpriseBoardType.company => '公司展示状态',
      EnterpriseBoardType.factory => '工厂展示状态',
      EnterpriseBoardType.supplier => '供应商展示状态',
      null => '入驻状态',
    };
  }

  String? _matchPrefixedId(Uri routeUri, String prefix) {
    final prefixUri = Uri.parse(prefix);
    final routeSegments = routeUri.pathSegments;
    final prefixSegments = prefixUri.pathSegments;
    if (routeSegments.length != prefixSegments.length + 1) {
      return null;
    }

    for (var index = 0; index < prefixSegments.length; index += 1) {
      if (routeSegments[index] != prefixSegments[index]) {
        return null;
      }
    }

    final last = routeSegments.last.trim();
    return last.isEmpty ? null : Uri.decodeComponent(last);
  }
}
