import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

part 'exhibition_home_page_sections.dart';
part 'exhibition_home_recommendation_section.dart';
part 'exhibition_home_location_options.dart';
part 'exhibition_home_support.dart';
part 'exhibition_home_weather_card.dart';
part 'exhibition_home_weather_panels.dart';
part 'exhibition_home_weather_warning_sections.dart';
part 'exhibition_home_weather_semantics.dart';
part 'exhibition_home_widgets.dart';

class ExhibitionHomePage extends StatefulWidget {
  const ExhibitionHomePage({super.key});

  @override
  State<ExhibitionHomePage> createState() => _ExhibitionHomePageState();
}

class _ExhibitionHomePageState extends State<ExhibitionHomePage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoRefreshTimer;
  ExhibitionLoadResult? _homeResult;
  ExhibitionLoadResult? _projectResult;
  DeviceLocationSnapshot? _locationSnapshot;
  bool _refreshing = false;
  bool _locating = false;
  bool _showScrollToTop = false;
  bool _weatherExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _refreshWholePage(useRefreshPath: false);
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshWholePage(useRefreshPath: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 280;
    if (_showScrollToTop == shouldShow) {
      return;
    }

    setState(() {
      _showScrollToTop = shouldShow;
    });
  }

  Future<void> _refreshWholePage({required bool useRefreshPath}) async {
    if (_refreshing) {
      return;
    }

    setState(() {
      _refreshing = true;
      _locating = true;
    });

    final locationSnapshot = await DeviceLocationService.instance
        .resolveCurrentPosition();
    if (!mounted) {
      return;
    }

    setState(() {
      _locationSnapshot = locationSnapshot;
      _locating = false;
    });

    final locationContext = _homeLocationContextFromSnapshot(locationSnapshot);
    final homeFuture = _loadHomeResult(
      useRefreshPath: useRefreshPath,
      locationContext: locationContext,
    );
    final projectFuture = ExhibitionConsumerLayer.instance.loadProjectList(
      forceRefresh: true,
    );

    final results = await Future.wait<ExhibitionLoadResult>(
      <Future<ExhibitionLoadResult>>[homeFuture, projectFuture],
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _homeResult = results[0];
      _projectResult = results[1];
      _refreshing = false;
    });
  }

  Future<ExhibitionLoadResult> _loadHomeResult({
    required bool useRefreshPath,
    required ExhibitionHomeLocationContextRequest? locationContext,
  }) async {
    if (!useRefreshPath) {
      return ExhibitionHomeAggregationClient.instance.load(
        locationContext: locationContext,
      );
    }

    final refreshResult = await ExhibitionHomeAggregationClient.instance
        .refresh(locationContext: locationContext);
    if (refreshResult.state != AppPageState.unauthorized) {
      return refreshResult;
    }

    // Public home remains readable. If refresh requires session, immediately
    // fall back to the canonical public GET /home instead of surfacing 401.
    return ExhibitionHomeAggregationClient.instance.load(
      locationContext: locationContext,
    );
  }

  void _openWorkbench() {
    if (_redirectToLoginForPrivateAction(actionLabel: '项目工作台')) {
      return;
    }
    Navigator.of(context).pushNamed(ExhibitionRoutes.workbench);
  }

  void _openProjectCreate() {
    if (_redirectToLoginForPrivateAction(actionLabel: '发布项目')) {
      return;
    }
    Navigator.of(context).pushNamed(ExhibitionRoutes.projectCreate);
  }

  void _openShowcase() {
    Navigator.of(context).pushNamed(ExhibitionRoutes.showcase);
  }

  void _openProjectDetail(String projectId) {
    Navigator.of(context).pushNamed(
      ExhibitionRoutes.projectDetailWithProjectId(
        projectId,
        surface: ExhibitionRoutes.showcaseSurface,
      ),
    );
  }

  void _openEnterpriseBoard(EnterpriseBoardType boardType) {
    final routeName = switch (boardType) {
      EnterpriseBoardType.company => ExhibitionRoutes.companies,
      EnterpriseBoardType.factory => ExhibitionRoutes.factories,
      EnterpriseBoardType.supplier => ExhibitionRoutes.suppliers,
    };
    Navigator.of(context).pushNamed(routeName);
  }

  bool _redirectToLoginForPrivateAction({required String actionLabel}) {
    final blockingState = AppShellScope.read(context).snapshot.blockingState;
    if (blockingState != GlobalShellState.unauthenticated) {
      return false;
    }

    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text('$actionLabel 需要先登录，当前先进入登录入口。')));
    Navigator.of(context).pushNamed(ProfileIdentityRoutes.login);
    return true;
  }

  Future<void> _openManualLocationSelect() async {
    final selected =
        await showModalBottomSheet<ExhibitionHomeLocationSelectRequest>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            final theme = Theme.of(context);
            return FractionallySizedBox(
              heightFactor: 0.78,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '手动选择地区',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '选择后会更新当前首页天气与推荐内容。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _manualLocationSelectOptions
                                .map(
                                  (option) => FilledButton.tonal(
                                    onPressed: () => Navigator.of(context).pop(
                                      ExhibitionHomeLocationSelectRequest(
                                        provinceCode: option.provinceCode,
                                        provinceName: option.provinceName,
                                        cityName: option.cityName,
                                        displayName: option.displayName,
                                      ),
                                    ),
                                    child: Text(option.displayName),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '地区选择仅作用于当前使用过程，后续可随时重新调整。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

    if (!mounted || selected == null) {
      return;
    }
    if (_refreshing) {
      return;
    }

    setState(() {
      _refreshing = true;
    });

    final results =
        await Future.wait<ExhibitionLoadResult>(<Future<ExhibitionLoadResult>>[
          ExhibitionHomeAggregationClient.instance.selectLocation(
            selection: selected,
          ),
          ExhibitionConsumerLayer.instance.loadProjectList(forceRefresh: true),
        ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _homeResult = results[0];
      _projectResult = results[1];
      _refreshing = false;
    });

    final homeState = results[0].state;
    if (homeState != AppPageState.content && homeState != AppPageState.empty) {
      final message = _homeManualLocationSelectFailureMessage(results[0]);
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _openManualSelectionPlaceholder() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '手动选择地区入口',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '这里先提供地区选择说明入口；如需立即切换地区，请使用顶部天气卡里的“手动选择地区”按钮。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 10),
                Text(
                  '当前地区选择以页面实时展示为准。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 18),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭占位入口'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectItems = _homeProjectItemsFromPayload(_projectResult?.payload);
    final weatherProjection = _homeWeatherProjectionFromResult(_homeResult);
    final areaLabel = _homeRecommendationAreaLabel(weatherProjection);
    final companyModule = _homeModuleProjectionFromPayload(
      _homeResult?.payload,
      'excellent_company',
      fallbackTitle: '优秀公司',
      fallbackSummary: '本省优质展览公司入口已接入，首页只展示轻摘要并进入公司列表。',
      fallbackStatusLabel: '已接通',
      fallbackActionLabel: '进入列表',
    );
    final factoryModule = _homeModuleProjectionFromPayload(
      _homeResult?.payload,
      'excellent_factory',
      fallbackTitle: '优秀工厂',
      fallbackSummary: '本省优质工厂入口已接入，首页只展示轻摘要并进入工厂列表。',
      fallbackStatusLabel: '已接通',
      fallbackActionLabel: '进入列表',
    );
    final supplierModule = _homeModuleProjectionFromPayload(
      _homeResult?.payload,
      'excellent_supplier',
      fallbackTitle: '优秀供应商',
      fallbackSummary: '本省优质供应商入口已接入，首页只展示轻摘要并进入供应商列表。',
      fallbackStatusLabel: '已接通',
      fallbackActionLabel: '进入列表',
    );

    return Stack(
      children: <Widget>[
        ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: <Widget>[
            _HomeWeatherCard(
              expanded: _weatherExpanded,
              refreshing: _refreshing,
              locating: _locating,
              locationSnapshot: _locationSnapshot,
              homeResult: _homeResult,
              weatherProjection: weatherProjection,
              onToggleExpanded: () {
                setState(() {
                  _weatherExpanded = !_weatherExpanded;
                });
              },
              onRefreshPressed: () => _refreshWholePage(useRefreshPath: true),
              onRelocatePressed: () => _refreshWholePage(useRefreshPath: true),
              onManualSelectionPressed: _openManualLocationSelect,
            ),
            const SizedBox(height: 16),
            const _HomeSectionHeader(
              title: '六模块入口',
              summary: '首页保留六大入口，便于快速进入项目展示、论坛与后续能力模块。',
            ),
            const SizedBox(height: 12),
            _HomeModuleGrid(
              onShowcasePressed: _openShowcase,
              onForumPressed: () =>
                  Navigator.of(context).pushNamed(ExhibitionRoutes.forum),
              companyModule: companyModule,
              factoryModule: factoryModule,
              supplierModule: supplierModule,
              onCompanyPressed: () =>
                  _openEnterpriseBoard(EnterpriseBoardType.company),
              onFactoryPressed: () =>
                  _openEnterpriseBoard(EnterpriseBoardType.factory),
              onSupplierPressed: () =>
                  _openEnterpriseBoard(EnterpriseBoardType.supplier),
              onTeamPlaceholderPressed: (String title) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title 功能正在完善中，当前先展示基础入口说明。')),
                );
              },
            ),
            const SizedBox(height: 16),
            _HomePrivateEntryCard(
              onWorkbenchPressed: _openWorkbench,
              onPublishPressed: _openProjectCreate,
            ),
            const SizedBox(height: 16),
            const _HomeSectionHeader(
              title: '本省推荐',
              summary: '结合当前地区展示项目推荐，支持手动刷新获取最新公开内容。',
            ),
            const SizedBox(height: 12),
            _HomeProjectRecommendationSection(
              areaLabel: areaLabel,
              loading: _refreshing,
              result: _projectResult,
              projectItems: projectItems,
              onRetry: () => _refreshWholePage(useRefreshPath: true),
              onOpenShowcase: _openShowcase,
              onOpenWorkbench: _openWorkbench,
              onOpenProjectCreate: _openProjectCreate,
              onOpenProjectDetail: _openProjectDetail,
            ),
            const SizedBox(height: 16),
            _HomePlaceholderRecommendationSection(
              title: '2. 本省论坛热帖',
              summary: '论坛继续保持独立入口；首页这里只保留推荐区位，不把天气、论坛和项目链混成一面说明墙。',
              actionLabel: '去论坛看看',
              onPressed: () =>
                  Navigator.of(context).pushNamed(ExhibitionRoutes.forum),
            ),
            const SizedBox(height: 12),
            _HomePlaceholderRecommendationSection(
              title: '3. 本省优秀公司与工厂',
              summary: '公司与工厂推荐位持续完善中，当前先提供模块入口说明。',
              actionLabel: '查看当前说明',
              onPressed: _openManualSelectionPlaceholder,
            ),
            const SizedBox(height: 12),
            _HomePlaceholderRecommendationSection(
              title: '4. 本省优秀团队员工',
              summary: '团队与员工推荐位持续完善中，当前先提供模块入口说明。',
              actionLabel: '查看当前说明',
              onPressed: _openManualSelectionPlaceholder,
            ),
            const SizedBox(height: 16),
            const _HomeBoundaryNoteCard(),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton.small(
                heroTag: 'home-publish-fab',
                tooltip: '发布项目入口',
                onPressed: _openProjectCreate,
                child: const Icon(Icons.add_task_outlined),
              ),
              const SizedBox(height: 12),
              IgnorePointer(
                ignoring: !_showScrollToTop,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _showScrollToTop ? 1 : 0.48,
                  child: FloatingActionButton.small(
                    heroTag: 'home-scroll-top-fab',
                    tooltip: '回到顶部',
                    onPressed: _scrollToTop,
                    child: const Icon(Icons.vertical_align_top),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
