part of 'enterprise_hub_workbench_pages.dart';

class EnterpriseApplicationStatusPage extends StatefulWidget {
  const EnterpriseApplicationStatusPage({
    super.key,
    required this.applicationId,
    this.boardType,
  });

  final String? applicationId;
  final EnterpriseBoardType? boardType;

  @override
  State<EnterpriseApplicationStatusPage> createState() =>
      _EnterpriseApplicationStatusPageState();
}

class _EnterpriseApplicationStatusPageState
    extends State<EnterpriseApplicationStatusPage> {
  EnterpriseHubLoadResult<EnterpriseHubApplicationStatusData>? _result;
  EnterpriseHubLoadResult<EnterpriseHubPublishedChangeStatusData>?
  _publishedChangeResult;
  _EnterpriseStatusPageMode _pageMode = _EnterpriseStatusPageMode.application;
  bool _routeInitialized = false;
  String? _publishedEnterpriseId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeInitialized) {
      return;
    }
    _routeInitialized = true;
    final routeUri = _currentRouteUri();
    if (routeUri.queryParameters['mode']?.trim() ==
        _enterprisePublishedChangeRouteMode) {
      _pageMode = _EnterpriseStatusPageMode.publishedChange;
      _publishedEnterpriseId = _normalizedText(
        routeUri.queryParameters['enterpriseId'],
      );
    }
    _load();
  }

  Uri _currentRouteUri() {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == null || routeName.trim().isEmpty) {
      return Uri(path: '/');
    }
    return Uri.parse(routeName);
  }

  Future<void> _load() async {
    if (_pageMode == _EnterpriseStatusPageMode.publishedChange) {
      final enterpriseId = _publishedEnterpriseId;
      if (enterpriseId == null || enterpriseId.isEmpty) {
        setState(() {
          _publishedChangeResult =
              EnterpriseHubLoadResult<EnterpriseHubPublishedChangeStatusData>(
                state: AppPageState.errorNonRetryable,
                method: 'GET',
                path:
                    '/api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current/status',
                message: '缺少 enterpriseId，当前无法读取变更状态。',
              );
        });
        return;
      }
      final result = await EnterpriseHubPublishedChangeConsumerLayer.instance
          .loadCurrentChangeStatus(
            boardType: widget.boardType ?? EnterpriseBoardType.company,
            enterpriseId: enterpriseId,
          );
      if (!mounted) return;
      setState(() => _publishedChangeResult = result);
      return;
    }
    final applicationId = widget.applicationId?.trim();
    if (applicationId == null || applicationId.isEmpty) {
      setState(() {
        _result = EnterpriseHubLoadResult<EnterpriseHubApplicationStatusData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path:
              '/api/app/exhibition/enterprise-hub/applications/{applicationId}',
          message: '缺少 applicationId，当前无法读取申请状态。',
        );
      });
      return;
    }
    final result = await EnterpriseHubConsumerLayer.instance
        .loadApplicationStatus(
          applicationId: applicationId,
          boardType: widget.boardType,
        );
    if (!mounted) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    if (_pageMode == _EnterpriseStatusPageMode.publishedChange) {
      final data = _publishedChangeResult?.data;
      final enterpriseId = _publishedEnterpriseId;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          EnterpriseSectionCard(
            key: const ValueKey<String>(
              'enterprise-published-change-status-card',
            ),
            title: '变更状态',
            subtitle:
                '${data == null ? '当前展示：受控状态。' : '当前展示：已接通内容。'}当前只消费 board-scoped app-facing 变更状态真值。',
            actions: <Widget>[
              FilledButton.tonal(
                key: const ValueKey<String>(
                  'enterprise-published-change-status-refresh',
                ),
                onPressed: _load,
                child: const Text('刷新状态'),
              ),
              if (enterpriseId != null)
                FilledButton.tonal(
                  key: const ValueKey<String>(
                    'enterprise-published-change-status-back',
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
                      enterpriseId,
                      boardType:
                          (widget.boardType ?? EnterpriseBoardType.company)
                              .contractName,
                    ),
                  ),
                  child: const Text('返回变更工作台'),
                ),
            ],
            child: Text(
              data == null
                  ? enterprisePublishedChangeVisibleMessage(
                      state: _publishedChangeResult?.state,
                      errorCode: _publishedChangeResult?.errorCode,
                      fallbackMessage:
                          _publishedChangeResult?.message ?? '当前还没有变更状态数据。',
                    )
                  : '变更状态已读取到真实状态结果。\n企业编号：${data.enterpriseId}\nchangeRequestId：${data.changeRequestId}\n状态：${enterprisePublishedChangeStatusLabel(data.changeStatus)}\n${enterprisePublishedChangeStatusExplanation(data.changeStatus)}\n提交时间：${_displayDateLabel(data.submittedAt, fallback: '未提交')}${data.reviewedAt == null ? '' : '\n审核时间：${_displayDateLabel(data.reviewedAt, fallback: '未审核')}'}${_normalizedText(data.rejectionReason) == null ? '' : '\n退回/驳回原因：${data.rejectionReason}'}',
            ),
          ),
        ],
      );
    }
    final data = _result?.data;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        EnterpriseSectionCard(
          key: const ValueKey<String>('enterprise-application-status-card'),
          title: '申请状态',
          subtitle:
              '${data == null ? '当前展示：受控状态。' : '当前展示：已接通内容。'}当前只消费展示状态真值。',
          actions: <Widget>[
            FilledButton.tonal(
              key: const ValueKey<String>(
                'enterprise-application-status-refresh',
              ),
              onPressed: _load,
              child: const Text('刷新状态'),
            ),
            FilledButton.tonal(
              key: const ValueKey<String>('enterprise-application-status-back'),
              onPressed: () => Navigator.of(context).pushNamed(
                ExhibitionRoutes.enterpriseWorkbenchForBoard(
                  (widget.boardType ?? EnterpriseBoardType.company)
                      .contractName,
                ),
              ),
              child: const Text('返回工作台'),
            ),
          ],
          child: Text(
            data == null
                ? enterpriseApplicationVisibleErrorMessage(
                    state: _result?.state,
                    errorCode: _result?.errorCode,
                    fallbackMessage: _result?.message ?? '当前还没有状态数据。',
                  )
                : '申请已读取到真实状态结果。\n申请编号：${data.applicationId}\n企业编号：${data.enterpriseId}\n状态：${enterpriseWorkbenchApplicationStatusLabel(data.applicationStatus)}\n提交时间：${_displayDateLabel(data.submittedAt, fallback: '未提交')}${data.reviewedAt == null ? '' : '\n审核时间：${_displayDateLabel(data.reviewedAt, fallback: '未审核')}'}${_normalizedText(data.reviewNote) == null ? '' : '\n审核说明：${data.reviewNote}'}${_normalizedText(data.rejectionReason) == null ? '' : '\n驳回原因：${data.rejectionReason}'}',
          ),
        ),
      ],
    );
  }
}
