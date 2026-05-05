import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/core/location/china_region_picker.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_location_context_store.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_board_surface.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_shared_components.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/shared/widgets/app_page_state_view.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

part 'exhibition_home_page_sections.dart';
part 'exhibition_home_page_actions.dart';
part 'exhibition_home_recommendation_section.dart';
part 'exhibition_home_module_deck.dart';
part 'exhibition_home_module_panels.dart';
part 'exhibition_home_channel_rails.dart';
part 'exhibition_home_channel_support.dart';
part 'exhibition_home_forum_panel.dart';
part 'exhibition_home_project_forum_panels.dart';
part 'exhibition_home_enterprise_panels.dart';
part 'exhibition_home_location_options.dart';
part 'exhibition_home_support.dart';
part 'exhibition_home_weather_card.dart';
part 'exhibition_home_weather_panels.dart';
part 'exhibition_home_weather_warning_sections.dart';
part 'exhibition_home_weather_semantics.dart';
part 'exhibition_home_widgets.dart';
part 'exhibition_home_visual_tokens.dart';

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
  ExhibitionHomeLocationSelectRequest? _manualLocationSelection;
  String _sessionRefreshSignature = '';
  bool _refreshing = false;
  bool _locating = false;
  bool _showScrollToTop = false;
  bool _weatherExpanded = false;
  _HomeModuleTab _selectedModuleTab = _HomeModuleTab.project;

  @override
  void initState() {
    super.initState();
    _sessionRefreshSignature = _buildSessionRefreshSignature();
    AppSessionStore.instance.addListener(_handleSessionStateChanged);
    _scrollController.addListener(_handleScroll);
    _refreshWholePage(useRefreshPath: false);
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshWholePage(useRefreshPath: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    AppSessionStore.instance.removeListener(_handleSessionStateChanged);
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

  void _markRefreshStarted() {
    setState(() {
      _refreshing = true;
      _locating = true;
    });
  }

  void _applyResolvedLocation(DeviceLocationSnapshot locationSnapshot) {
    setState(() {
      _manualLocationSelection = null;
      _locationSnapshot = locationSnapshot;
      _locating = false;
    });
  }

  void _applyRefreshResults(List<ExhibitionLoadResult> results) {
    setState(() {
      _homeResult = results[0];
      _projectResult = results[1];
      _refreshing = false;
      _locating = false;
    });
  }

  void _applyProjectRefreshResult(ExhibitionLoadResult projectResult) {
    setState(() {
      _projectResult = projectResult;
      _refreshing = false;
      _locating = false;
    });
  }

  void _markManualLocationRefreshStarted() {
    setState(() {
      _refreshing = true;
    });
  }

  void _handleSessionStateChanged() {
    final nextSignature = _buildSessionRefreshSignature();
    if (_sessionRefreshSignature == nextSignature) {
      return;
    }

    _sessionRefreshSignature = nextSignature;
    unawaited(_refreshWholePage(useRefreshPath: true));
  }

  String _buildSessionRefreshSignature() {
    final snapshot = AppSessionStore.instance.snapshot;
    return [
      snapshot.refreshToken ?? '',
      snapshot.deviceId ?? '',
      snapshot.localLoginSource ?? '',
    ].join('|');
  }

  void _applyManualLocationSelection(
    ExhibitionHomeLocationSelectRequest selection,
  ) {
    final permissionState =
        _locationSnapshot?.permissionState ??
        ExhibitionHomeLocationContextStore.instance.lastPermissionState;
    ExhibitionHomeLocationContextStore.instance.storeManualSelection(
      selection,
      permissionState: permissionState,
    );
    setState(() {
      _manualLocationSelection = selection;
      _locationSnapshot = DeviceLocationSnapshot(
        permissionState: permissionState,
        provinceCode: selection.provinceCode,
        provinceName: selection.provinceName,
      );
      _locating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectItems = _homeProjectItemsFromPayload(_projectResult?.payload);
    final weatherProjection = _homeWeatherProjectionFromResult(_homeResult);
    final bottomClearance = 78 + 14 + MediaQuery.paddingOf(context).bottom + 24;

    return ColoredBox(
      color: ExhibitionHomeVisualTokens.pageBackground,
      child: Stack(
        children: <Widget>[
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              ExhibitionHomeVisualTokens.spacingPage,
              14,
              ExhibitionHomeVisualTokens.spacingPage,
              bottomClearance,
            ),
            children: <Widget>[
              const _HomeHeroHeader(),
              const SizedBox(height: 14),
              _HomeWeatherCard(
                expanded: _weatherExpanded,
                refreshing: _refreshing,
                locating: _locating,
                locationSnapshot: _locationSnapshot,
                manualLocationSelection: _manualLocationSelection,
                homeResult: _homeResult,
                weatherProjection: weatherProjection,
                onToggleExpanded: () {
                  setState(() {
                    _weatherExpanded = !_weatherExpanded;
                  });
                },
                onRefreshPressed: () => _refreshWholePage(useRefreshPath: true),
                onRelocatePressed: () => _refreshWholePage(
                  useRefreshPath: true,
                  forceDeviceRelocation: true,
                ),
                onManualSelectionPressed: _openManualLocationSelect,
              ),
              const SizedBox(height: 10),
              const _HomeSectionHeader(eyebrow: '公开入口', title: '推荐频道'),
              const SizedBox(height: 6),
              _HomeModuleDeck(
                selectedTab: _selectedModuleTab,
                onTabSelected: (_HomeModuleTab tab) {
                  setState(() {
                    _selectedModuleTab = tab;
                  });
                },
                loading: _refreshing,
                locationSnapshot: _locationSnapshot,
                projectResult: _projectResult,
                projectItems: projectItems,
                onRefreshHome: () => _refreshWholePage(useRefreshPath: true),
                onRelocateHome: () => _refreshWholePage(
                  useRefreshPath: true,
                  forceDeviceRelocation: true,
                ),
                onOpenProjectList: _openShowcase,
                onOpenProjectCreate: _openProjectCreate,
                onOpenProjectDetail: _openProjectDetail,
                onOpenForum: _openForum,
                onOpenForumPublish: _openForumPublish,
                onOpenForumPost: _openForumPost,
                onOpenCompanyBoard: () =>
                    _openEnterpriseBoard(EnterpriseBoardType.company),
                onOpenFactoryBoard: () =>
                    _openEnterpriseBoard(EnterpriseBoardType.factory),
                onOpenSupplierBoard: () =>
                    _openEnterpriseBoard(EnterpriseBoardType.supplier),
                onOpenEnterpriseItem: _openEnterpriseListItem,
                onOpenTeamExplanation: _openTeamPlaceholderExplanation,
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 24 + MediaQuery.paddingOf(context).bottom,
            child: IgnorePointer(
              ignoring: !_showScrollToTop,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _showScrollToTop ? 1 : 0,
                child: FloatingActionButton.small(
                  heroTag: 'home-scroll-top-fab',
                  tooltip: '回到顶部',
                  onPressed: _scrollToTop,
                  child: const Icon(Icons.vertical_align_top),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
