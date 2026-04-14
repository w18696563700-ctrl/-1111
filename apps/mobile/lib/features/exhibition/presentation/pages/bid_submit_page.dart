part of '../exhibition_trade_pages.dart';

class BidSubmitPage extends StatefulWidget {
  const BidSubmitPage({super.key, this.projectId, this.mode});

  final String? projectId;
  final String? mode;

  @override
  State<BidSubmitPage> createState() => _BidSubmitPageState();
}

class _BidSubmitPageState extends State<BidSubmitPage> {
  late final TextEditingController _projectIdController = TextEditingController(
    text: widget.projectId ?? '',
  );
  final GlobalKey _quoteAmountFieldKey = GlobalKey();
  final GlobalKey _proposalSummaryFieldKey = GlobalKey();
  final TextEditingController _quoteAmountController = TextEditingController();
  final TextEditingController _proposalSummaryController =
      TextEditingController();

  bool _guardLoading = true;
  _BidAccessGuard? _accessGuard;
  bool _resultGuardLoading = true;
  _BidAccessGuard? _resultAccessGuard;
  bool _guardInitialized = false;
  int _guardRetryCount = 0;
  bool _submitting = false;
  bool _seatActionInFlight = false;
  ExhibitionActionResult? _lastResult;
  ExhibitionStageDataOrigin? _lastResultOrigin;
  String? _submittedBidId;
  ExhibitionLoadResult? _bidResult;
  ExhibitionLoadResult? _seatResult;
  ExhibitionLoadResult? _completenessResult;
  bool _resultLoading = false;

  bool get _isResultMode => widget.mode?.trim() == 'result';

  @override
  void initState() {
    super.initState();
    if (_projectIdController.text.trim().isEmpty) {
      if (_isResultMode) {
        _bidResult = ExhibitionLoadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ExhibitionCanonicalPaths.bidResult,
          message:
              'projectId is required from route context or page context before bid result',
        );
      } else {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          message:
              'projectId is required from route context or page context before bid submit',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_guardInitialized) {
      return;
    }
    _guardInitialized = true;
    if (_isResultMode) {
      if (_normalizeId(widget.projectId) == null) {
        _resultGuardLoading = false;
        return;
      }
      _loadBidResultAccessGuard();
      return;
    }
    _loadAccessGuard();
  }

  @override
  void dispose() {
    _projectIdController.dispose();
    _quoteAmountController.dispose();
    _proposalSummaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_guardLoading) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorRetryable,
          message: '当前正在核对竞标守卫，请稍候再试。',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    final accessGuard = _accessGuard;
    if (accessGuard != null) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: accessGuard.controlledState,
          message: accessGuard.message,
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    final projectId = _projectIdController.text.trim();
    final quoteAmount = double.tryParse(_quoteAmountController.text.trim());
    final proposalSummary = _proposalSummaryController.text.trim();

    if (projectId.isEmpty) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: '当前还没有承接到项目，暂时不能继续当前竞标。请先回到项目详情，再从当前项目继续进入。',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    if (quoteAmount == null) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: '请先填写有效的竞标报价，再继续提交。',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    if (proposalSummary.isEmpty) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: '请先补充方案说明，再继续提交竞标。',
        );
        _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
      _lastResultOrigin = null;
    });

    final result = await ExhibitionConsumerLayer.instance.submitBid(
      BidSubmitCommand(
        projectId: projectId,
        quoteAmount: quoteAmount,
        proposalSummary: proposalSummary,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _lastResult = result;
      _lastResultOrigin = ExhibitionStageDataOrigin.futureReal;
      _submittedBidId = _bidIdFromPayload(result.payload);
      if (_submittedBidId == null) {
        _seatResult = null;
        _completenessResult = null;
      }
    });

    if (result.isSuccess) {
      final projectId = _normalizeId(_projectIdController.text);
      if (projectId != null) {
        await Future.wait<void>(<Future<void>>[
          ExhibitionConsumerLayer.instance.loadProjectDetail(
            projectId: projectId,
            forceRefresh: true,
          ),
          ExhibitionConsumerLayer.instance.loadMyProjectList(
            forceRefresh: true,
          ),
        ]);
      }
      await _loadBidSeatAndCompleteness(forceRefresh: true);
    }
  }

  void _applyDemoBidResult() {
    if (_guardLoading || _accessGuard != null) {
      return;
    }

    final projectId = _projectIdController.text.trim().isEmpty
        ? ExhibitionStageDemoCatalog.demoProjectId
        : _projectIdController.text.trim();

    setState(() {
      _lastResult = ExhibitionStageDemoCatalog.bidSubmit(projectId: projectId);
      _lastResultOrigin = ExhibitionStageDataOrigin.demo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isResultMode) {
      return _buildResultMode();
    }

    return _buildSubmitMode(context);
  }

  Widget _buildSubmitMode(BuildContext context) {
    final routeProjectId = _normalizeId(widget.projectId);
    final projectId = _normalizeId(_projectIdController.text);

    return _SubmissionPageFrame(
      title: '竞标提交',
      summary: '这里是当前项目下的最小竞标继续面，只收口报价、方案说明和提交反馈，不扩到订单或后续链路。',
      canonicalPath: ExhibitionCanonicalPaths.bidSubmit,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submit,
      submitButtonLabel: '提交竞标',
      showSubmitButton: !_guardLoading && _accessGuard == null,
      sourceLabel: '当前展示方式：优先显示已接通内容',
      sourceMessage: '默认优先展示已接通结果；这一步只保留最小竞标继续动作，如需不中断演示，也可以切换到演示内容继续讲解。',
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      resultSectionsBuilder: (ExhibitionActionResult result) =>
          _buildBidSubmitResultSections(
            context: context,
            result: result,
            projectId: projectId,
            lastResultOrigin: _lastResultOrigin,
          ),
      body: _buildBidSubmitBody(
        context: context,
        routeProjectId: routeProjectId,
        guardLoading: _guardLoading,
        accessGuard: _accessGuard,
        bidId: _submittedBidId,
        seatResult: _seatResult,
        completenessResult: _completenessResult,
        quoteAmountController: _quoteAmountController,
        proposalSummaryController: _proposalSummaryController,
        submitting: _submitting,
        onApplyDemoBidResult: _applyDemoBidResult,
        quoteAmountFieldKey: _quoteAmountFieldKey,
        proposalSummaryFieldKey: _proposalSummaryFieldKey,
        onFocusQuoteAmount: _focusQuoteAmount,
        onFocusProposalSummary: _focusProposalSummary,
        onRetryBidProjection: () =>
            _loadBidSeatAndCompleteness(forceRefresh: true),
        onLockSeat: _lockSeat,
        onReleaseSeat: _releaseSeat,
        showSeatActions:
            _submittedBidId != null &&
            !_seatActionInFlight &&
            _seatResultAllowsSeatActions(_seatResult),
      ),
    );
  }

  Widget _buildResultMode() {
    final routeProjectId = _normalizeId(widget.projectId);
    final effectiveResult = _resultAccessGuard == null
        ? _bidResult
        : ExhibitionLoadResult(
            state: _resultAccessGuard!.controlledState,
            method: 'GET',
            path: ExhibitionCanonicalPaths.bidResult,
            message: _resultAccessGuard!.message,
          );

    return _LoadPageFrame(
      title: '竞标结果',
      summary:
          '这里读取当前项目下的最小竞标结果出口，只消费 bidId、state、result、reason 与 decidedAt，不扩成供应商工作台。',
      loading: _resultLoading || _resultGuardLoading,
      result: effectiveResult,
      onRetry: () {
        if (_resultAccessGuard != null) {
          _loadBidResultAccessGuard();
          return;
        }
        _loadBidResult(forceRefresh: true);
      },
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      controls: _routeOnlyControls(
        routeId: routeProjectId,
        label: 'projectId',
        onReload: () {
          if (_resultAccessGuard != null) {
            _loadBidResultAccessGuard();
            return;
          }
          _loadBidResult(forceRefresh: true);
        },
        reloadLabel: '重新读取竞标结果',
      ),
      recoveryRouteOverride: routeProjectId == null
          ? ExhibitionRoutes.showcase
          : ExhibitionRoutes.projectDetailWithProjectId(routeProjectId),
      recoveryButtonLabelOverride: routeProjectId == null ? '回到项目展示' : '回到项目详情',
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        if (_resultAccessGuard != null) {
          return <Widget>[
            const SizedBox(height: 16),
            _ActionCard(
              title: _resultAccessGuard!.title,
              summary: _resultAccessGuard!.message,
              tone: _ActionCardTone.emphasis,
              children: <Widget>[
                const _DetailLine(
                  label: '守卫说明',
                  value: '查看竞标结果前，会先检查当前登录、组织类型、双重认证和项目状态；最终业务权限仍以后端判定为准。',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    _resolveBidGuardRouteName(
                      _resultAccessGuard!,
                      projectId: routeProjectId,
                    ),
                  ),
                  child: Text(_resultAccessGuard!.actionLabel),
                ),
              ],
            ),
          ];
        }
        if (result.state != AppPageState.content || routeProjectId == null) {
          return const <Widget>[];
        }

        final payload = _payloadMap(result.payload);
        final bidId = _bidIdFromPayload(result.payload);
        final state = _stateFromPayload(result.payload);
        final outcome = _resultFromPayload(result.payload);
        final reasonCode = _normalizeId(payload?['reasonCode'] as String?);
        final reasonText = _normalizeId(payload?['reasonText'] as String?);
        final decidedAt = _normalizeId(payload?['decidedAt'] as String?);

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(
            title: '当前竞标结果',
            summary:
                '当前页只承接当前 actor 的最小 result outlet，不扩 compare board 或供应商工作台。',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              _InstanceSummaryLine(title: '当前项目 ID', value: routeProjectId),
              if (bidId != null) ...<Widget>[
                const SizedBox(height: 12),
                _InstanceSummaryLine(title: '当前竞标 ID', value: bidId),
              ],
              if (state != null) ...<Widget>[
                const SizedBox(height: 12),
                _DetailLine(
                  label: '当前状态',
                  value: _frontStageStateLabel(state),
                  highlight: true,
                ),
              ],
              if (outcome != null) ...<Widget>[
                const SizedBox(height: 12),
                _DetailLine(
                  label: '当前结果',
                  value: _frontStageStateLabel(outcome),
                  highlight: true,
                ),
              ],
              if (reasonCode != null) ...<Widget>[
                const SizedBox(height: 12),
                _DetailLine(label: '原因编码', value: reasonCode),
              ],
              if (reasonText != null) ...<Widget>[
                const SizedBox(height: 12),
                _DetailLine(label: '原因说明', value: reasonText),
              ],
              if (decidedAt != null) ...<Widget>[
                const SizedBox(height: 12),
                _DetailLine(label: '裁决时间', value: decidedAt),
              ],
              const SizedBox(height: 12),
              const _StateMessage(
                title: '当前动作',
                body: '当前结果已经回读完成；页面同时刷新了项目详情与我的项目缓存。',
              ),
            ],
          ),
        ];
      },
    );
  }

  Future<void> _loadAccessGuard() async {
    if (!AppSessionStore.instance.hasAnySession) {
      setState(() {
        _guardLoading = false;
        _accessGuard = const _BidAccessGuard(
          controlledState: AppPageState.unauthorized,
          title: '当前尚未登录',
          message: '参与竞标属于私域动作，当前需要先登录后再继续。',
          actionLabel: '进入登录入口',
          actionRouteName: ProfileIdentityRoutes.login,
        );
      });
      return;
    }

    final snapshot = AppShellScope.read(context).snapshot;
    final blockingState = snapshot.blockingState;
    if (blockingState == GlobalShellState.booting ||
        blockingState == GlobalShellState.sessionRefreshing) {
      if (_guardRetryCount >= 20) {
        setState(() {
          _guardLoading = false;
          _accessGuard = const _BidAccessGuard(
            controlledState: AppPageState.errorRetryable,
            title: '当前竞标守卫暂不可用',
            message: '当前壳层状态仍在准备中，请稍后重试。',
            actionLabel: '回到当前项目详情',
            actionRouteName: ExhibitionRoutes.showcase,
          );
        });
        return;
      }

      _guardRetryCount += 1;
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) {
          return;
        }
        _loadAccessGuard();
      });
      return;
    }

    _guardRetryCount = 0;
    final shellAccessGuard = _deriveBidAccessGuard(
      snapshot: snapshot,
      hasSession: AppSessionStore.instance.hasAnySession,
    );
    if (shellAccessGuard != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _guardLoading = false;
        _accessGuard = shellAccessGuard;
      });
      return;
    }

    final projectAccessGuard = await _loadProjectAccessGuard();
    if (!mounted) {
      return;
    }

    setState(() {
      _guardLoading = false;
      _accessGuard = projectAccessGuard;
    });
  }

  Future<_BidAccessGuard?> _loadProjectAccessGuard() async {
    final projectId = _normalizeId(_projectIdController.text);
    if (projectId == null) {
      return _bidMissingProjectGuard();
    }

    final detailResult = await ExhibitionConsumerLayer.instance
        .loadProjectDetail(projectId: projectId);
    return _deriveBidProjectAccessGuard(
      projectId: projectId,
      detailResult: detailResult,
    );
  }

  Future<void> _loadBidSeatAndCompleteness({bool forceRefresh = false}) async {
    final projectId = _normalizeId(_projectIdController.text);
    final bidId = _submittedBidId;
    if (projectId == null || bidId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _seatResult = null;
        _completenessResult = null;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _seatResult = null;
      _completenessResult = null;
    });

    final results =
        await Future.wait<ExhibitionLoadResult>(<Future<ExhibitionLoadResult>>[
          ExhibitionConsumerLayer.instance.loadBidSeatStatus(
            projectId: projectId,
            bidId: bidId,
            forceRefresh: forceRefresh,
          ),
          ExhibitionConsumerLayer.instance.loadBidPackageCompleteness(
            projectId: projectId,
            bidId: bidId,
            forceRefresh: forceRefresh,
          ),
        ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _seatResult = results[0];
      _completenessResult = results[1];
    });
  }

  bool _seatResultAllowsSeatActions(ExhibitionLoadResult? result) {
    if (result == null || result.state != AppPageState.content) {
      return false;
    }

    final state = _stateFromPayload(result.payload) ?? 'available';
    return state == 'available' || state == 'locked' || state == 'released';
  }

  Future<void> _lockSeat() async {
    await _runSeatAction(() {
      final projectId = _normalizeId(_projectIdController.text);
      final bidId = _submittedBidId;
      if (projectId == null || bidId == null) {
        return Future<ExhibitionActionResult>.value(
          ExhibitionActionResult(
            method: 'POST',
            path: '/api/app/bid/seat/lock',
            isSuccess: false,
            controlledState: AppPageState.notFound,
            message: '当前页面尚未拿到明确 bidId，暂不能锁定候选席位。',
          ),
        );
      }

      return ExhibitionConsumerLayer.instance.lockBidSeat(
        projectId: projectId,
        bidId: bidId,
      );
    });
  }

  Future<void> _releaseSeat() async {
    await _runSeatAction(() {
      final projectId = _normalizeId(_projectIdController.text);
      final bidId = _submittedBidId;
      if (projectId == null || bidId == null) {
        return Future<ExhibitionActionResult>.value(
          ExhibitionActionResult(
            method: 'POST',
            path: '/api/app/bid/seat/release',
            isSuccess: false,
            controlledState: AppPageState.notFound,
            message: '当前页面尚未拿到明确 bidId，暂不能释放候选席位。',
          ),
        );
      }

      return ExhibitionConsumerLayer.instance.releaseBidSeat(
        projectId: projectId,
        bidId: bidId,
      );
    });
  }

  Future<void> _runSeatAction(
    Future<ExhibitionActionResult> Function() action,
  ) async {
    if (_seatActionInFlight) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _seatActionInFlight = true;
    });

    try {
      final result = await action();
      if (!mounted) {
        return;
      }

      if (result.isSuccess) {
        await _loadBidSeatAndCompleteness(forceRefresh: true);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '候选席位操作失败，请稍后再试。')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _seatActionInFlight = false;
        });
      }
    }
  }

  Future<void> _loadBidResult({bool forceRefresh = false}) async {
    if (_resultAccessGuard != null) {
      return;
    }
    setState(() {
      _resultLoading = true;
    });

    final result = await ExhibitionConsumerLayer.instance.loadBidResult(
      projectId: widget.projectId,
      forceRefresh: forceRefresh,
    );

    final projectId =
        _projectIdFromPayload(result.payload) ?? _normalizeId(widget.projectId);
    if (result.state == AppPageState.content && projectId != null) {
      await Future.wait<void>(<Future<void>>[
        ExhibitionConsumerLayer.instance.loadProjectDetail(
          projectId: projectId,
          forceRefresh: true,
        ),
        ExhibitionConsumerLayer.instance.loadMyProjectList(forceRefresh: true),
      ]);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _bidResult = result;
      _seatResult = null;
      _completenessResult = null;
      _resultLoading = false;
    });
  }

  Future<void> _loadBidResultAccessGuard() async {
    final snapshot = AppShellScope.read(context).snapshot;
    final shellAccessGuard = _deriveBidAccessGuard(
      snapshot: snapshot,
      hasSession: AppSessionStore.instance.hasAnySession,
    );
    if (shellAccessGuard != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _resultGuardLoading = false;
        _resultAccessGuard = shellAccessGuard;
      });
      return;
    }

    final projectId = _normalizeId(widget.projectId);
    if (projectId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _resultGuardLoading = false;
        _resultAccessGuard = _bidMissingProjectGuard();
      });
      return;
    }

    final detailResult = await ExhibitionConsumerLayer.instance
        .loadProjectDetail(projectId: projectId);
    if (!mounted) {
      return;
    }

    setState(() {
      _resultGuardLoading = false;
      _resultAccessGuard = _deriveBidResultProjectAccessGuard(
        projectId: projectId,
        detailResult: detailResult,
      );
    });

    if (_resultAccessGuard == null) {
      await _loadBidResult();
    }
  }

  void _focusQuoteAmount() {
    final context = _quoteAmountFieldKey.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _focusProposalSummary() {
    final context = _proposalSummaryFieldKey.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }
}
