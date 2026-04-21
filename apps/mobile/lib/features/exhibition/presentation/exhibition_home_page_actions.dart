part of 'exhibition_home_page.dart';

extension _ExhibitionHomePageStateActions on _ExhibitionHomePageState {
  Future<void> _refreshWholePage({
    required bool useRefreshPath,
    bool forceDeviceRelocation = false,
  }) async {
    if (_refreshing) {
      return;
    }

    _markRefreshStarted();

    final locationContext = await _resolveRefreshLocationContext(
      forceDeviceRelocation: forceDeviceRelocation,
    );
    if (!mounted) {
      return;
    }
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

    _applyRefreshResults(results);
  }

  Future<ExhibitionHomeLocationContextRequest?> _resolveRefreshLocationContext({
    required bool forceDeviceRelocation,
  }) async {
    final manualSelection = forceDeviceRelocation ? null : _manualLocationSelection;
    if (manualSelection != null) {
      return _homeLocationContextFromSelection(
        manualSelection,
        permissionState:
            _locationSnapshot?.permissionState ??
            DeviceLocationPermissionState.unknown,
      );
    }

    final locationSnapshot = await DeviceLocationService.instance
        .resolveCurrentPosition();
    if (!mounted) {
      return null;
    }

    _applyResolvedLocation(locationSnapshot);
    return _homeLocationContextFromSnapshot(locationSnapshot);
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

    return ExhibitionHomeAggregationClient.instance.load(
      locationContext: locationContext,
    );
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
    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.projectDetailWithProjectId(projectId));
  }

  void _openForum() {
    Navigator.of(context).pushNamed(ExhibitionRoutes.forum);
  }

  void _openForumPublish() {
    if (_redirectToLoginForPrivateAction(actionLabel: '发布帖子')) {
      return;
    }
    Navigator.of(context).pushNamed(ExhibitionRoutes.forumPublish);
  }

  void _openForumPost(String postId) {
    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.forumPostWithPostId(postId));
  }

  void _openEnterpriseListItem(EnterpriseHubListItem item) {
    final routeName = switch (item.boardType) {
      EnterpriseBoardType.company =>
        ExhibitionRoutes.companyDetailWithEnterpriseId(item.enterpriseId),
      EnterpriseBoardType.factory =>
        ExhibitionRoutes.factoryDetailWithEnterpriseId(item.enterpriseId),
      EnterpriseBoardType.supplier =>
        ExhibitionRoutes.supplierDetailWithEnterpriseId(item.enterpriseId),
    };
    Navigator.of(context).pushNamed(routeName);
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
    final catalog = await ChinaRegionCatalogLoader.load();
    if (!mounted) {
      return;
    }
    final currentLocation = _homeWeatherProjectionFromResult(_homeResult);
    final currentCity = catalog.cityByName(currentLocation?.displayName);
    final picked = await showChinaCityPicker(
      context: context,
      catalog: catalog,
      title: '选择城市',
      initialProvinceCode: currentCity?.provinceCode,
      initialCityCode: currentCity?.cityCode,
    );
    final selected = picked == null
        ? null
        : ExhibitionHomeLocationSelectRequest(
            provinceCode: picked.provinceCode,
            provinceName: picked.provinceName,
            cityName: picked.cityName,
            displayName: picked.shortCityName,
          );

    if (!mounted || selected == null) {
      return;
    }
    if (_refreshing) {
      return;
    }

    _markManualLocationRefreshStarted();
    final selectionResult = await _loadSelectedLocationHomeResult(selected);
    final projectResult = await ExhibitionConsumerLayer.instance.loadProjectList(
      forceRefresh: true,
    );
    if (!mounted) {
      return;
    }

    final homeState = selectionResult.state;
    if (homeState != AppPageState.content && homeState != AppPageState.empty) {
      _applyProjectRefreshResult(projectResult);
      final message = _homeManualLocationSelectFailureMessage(selectionResult);
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    _applyManualLocationSelection(selected);
    _applyRefreshResults(<ExhibitionLoadResult>[selectionResult, projectResult]);
  }

  Future<ExhibitionLoadResult> _loadSelectedLocationHomeResult(
    ExhibitionHomeLocationSelectRequest selection,
  ) async {
    final selectResult = await ExhibitionHomeAggregationClient.instance
        .selectLocation(selection: selection);
    if (selectResult.state != AppPageState.unauthorized) {
      return selectResult;
    }

    return ExhibitionHomeAggregationClient.instance.load(
      locationContext: _homeLocationContextFromSelection(
        selection,
        permissionState:
            _locationSnapshot?.permissionState ??
            DeviceLocationPermissionState.unknown,
      ),
    );
  }

  void _openTeamPlaceholderExplanation() {
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
                  '优秀团队员工',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '当前首页已经保留了团队与员工推荐位，但这条链路还没有接到真实推荐内容。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 10),
                Text(
                  '后续一旦接通，这里会直接替换成真实推荐，不会继续停在说明态。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 18),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭说明'),
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
}
