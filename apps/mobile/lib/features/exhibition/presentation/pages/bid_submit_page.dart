part of '../exhibition_trade_pages.dart';

class BidSubmitPage extends StatefulWidget {
  const BidSubmitPage({
    super.key,
    this.projectId,
    this.mode,
    this.bidParticipationRequestId,
  });

  final String? projectId;
  final String? mode;
  final String? bidParticipationRequestId;

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
  late final List<_BidSubmitAttachmentSlotState> _attachmentSlots =
      _createBidSubmitAttachmentSlots();

  bool _guardLoading = true;
  _BidAccessGuard? _accessGuard;
  bool _resultGuardLoading = true;
  _BidAccessGuard? _resultAccessGuard;
  bool _guardInitialized = false;
  int _guardRetryCount = 0;
  bool _submitting = false;
  bool _bidAlreadySubmitted = false;
  ExhibitionActionResult? _lastResult;
  ExhibitionLoadResult? _bidResult;
  ExhibitionLoadResult? _projectDetailResult;
  ExhibitionLoadResult? _bidMaterialResult;
  final Set<String> _openingBidMaterialIds = <String>{};
  bool _resultLoading = false;
  bool _bidFlowExpanded = false;
  bool _projectReviewExpanded = false;
  bool _p0PaySubmitting = false;
  final int _p0PayQuoteValidHours = 48;
  final bool _p0PayTaxIncluded = true;
  final bool _p0PayTransportIncluded = true;
  final bool _p0PayInstallationIncluded = true;
  final bool _p0PayReadRuleConfirmed = false;
  final bool _p0PayAuthorizationAwarenessConfirmed = false;
  final bool _p0PayPublisherBreachReleaseConfirmed = false;
  final String _p0PayAuthorizationChannel = 'alipay_candidate';
  ExhibitionActionResult? _p0PayFixedPriceBidResult;
  ExhibitionActionResult? _p0PayAuthorizationResult;
  ExhibitionActionResult? _p0PayAuthorizationInitResult;
  ExhibitionLoadResult? _p0PayAuthorizationStatusResult;
  P0PayPaymentPollResult? _p0PayAuthorizationPollResult;

  bool get _isResultMode => widget.mode?.trim() == 'result';

  void _setBidAttachmentPreviewOpening(
    _BidSubmitAttachmentSlotState slot,
    bool value,
  ) {
    setState(() => slot.previewOpening = value);
  }

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
    _loadSubmitProjectDetail();
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
    if (_bidAlreadySubmitted) {
      return;
    }

    if (_guardLoading) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorRetryable,
          message: '当前正在核对竞标守卫，请稍候再试。',
        );
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
          message: '请先补充方案说明，再提交竞标。',
        );
      });
      return;
    }

    final confirmedAttachmentIds = <String>[];
    final missingAttachments = <String>[];
    for (final slot in _attachmentSlots) {
      final fileAssetId = _normalizeId(slot.fileAssetId);
      if (fileAssetId == null || !slot.isConfirmed) {
        missingAttachments.add(slot.label);
        continue;
      }
      confirmedAttachmentIds.add(fileAssetId);
    }

    if (missingAttachments.isNotEmpty) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.bidSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: '请先完成并确认附件：${missingAttachments.join('、')}，再提交竞标。',
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.submitBid(
      BidSubmitCommand(
        projectId: projectId,
        quoteAmount: quoteAmount,
        proposalSummary: proposalSummary,
        projectUnderstandingFileAssetId: confirmedAttachmentIds[0],
        quoteSheetFileAssetId: confirmedAttachmentIds[1],
        schedulePlanFileAssetId: confirmedAttachmentIds[2],
      ),
    );

    if (!mounted) {
      return;
    }
    final bidAccepted =
        result.isSuccess || _isBidDuplicateSubmissionResult(result);

    setState(() {
      _submitting = false;
      _lastResult = result;
      if (bidAccepted) {
        _bidAlreadySubmitted = true;
      }
    });

    if (bidAccepted) {
      _showBidMaterialMessage(
        _isBidDuplicateSubmissionResult(result)
            ? '竞标已提交，页面状态已同步。'
            : '竞标提交成功，资料确认待办已通知发布方。',
      );
      unawaited(
        AppShellScope.read(context).reloadShellContext().catchError((_) {}),
      );
      final projectId = _normalizeId(_projectIdController.text);
      if (projectId != null) {
        final refreshedProject = await ExhibitionConsumerLayer.instance
            .loadProjectDetail(projectId: projectId, forceRefresh: true);
        if (mounted) {
          setState(() => _projectDetailResult = refreshedProject);
        }
        await Future.wait<void>(<Future<void>>[
          ExhibitionConsumerLayer.instance.loadMyProjectList(
            forceRefresh: true,
          ),
          ExhibitionConsumerLayer.instance.loadMyBidList(forceRefresh: true),
        ]);
      }
    } else {
      _showBidMaterialMessage(result.message ?? '竞标提交失败，请稍后重试。');
    }
  }

  Future<void> _submitCurrentBidFlow() async {
    await _submit();
  }

  String? _bidSubmitFinalSubmitDisabledMessage() {
    if (!_bidFlowExpanded) {
      return null;
    }

    if (double.tryParse(_quoteAmountController.text.trim()) == null) {
      return '请先填写有效的竞标报价。';
    }

    if (_proposalSummaryController.text.trim().isEmpty) {
      return '请先填写方案说明。';
    }

    final attachmentBlocker = _bidSubmitAttachmentSubmitDisabledMessage(
      _attachmentSlots,
    );
    if (attachmentBlocker != null) {
      return attachmentBlocker;
    }

    return null;
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
    final showContinueBidFlowAction =
        routeProjectId != null &&
        !_guardLoading &&
        _accessGuard == null &&
        !_bidFlowExpanded;
    final canContinueBidFlow =
        showContinueBidFlowAction &&
        _projectDetailResult?.state == AppPageState.content;
    final bidAlreadySubmitted =
        _bidAlreadySubmitted ||
        _hasCurrentViewerBid(_projectDetailResult?.payload) ||
        _isBidDuplicateSubmissionResult(_lastResult);
    final submitDisabledMessage = bidAlreadySubmitted
        ? null
        : _bidSubmitFinalSubmitDisabledMessage();

    return _SubmissionPageFrame(
      title: '竞标提交',
      summary: '这里是当前项目下的竞标提交页，按已承接项目、查看报价依据资料、填写报价、上传方案和最终提交依次完成。',
      canonicalPath: ExhibitionCanonicalPaths.bidSubmit,
      submitting: _submitting || _p0PaySubmitting,
      lastResult: _lastResult,
      onSubmitPressed: _submitCurrentBidFlow,
      submitButtonLabel: bidAlreadySubmitted ? '已提交竞标' : '提交竞标',
      showSubmitButton:
          !_guardLoading &&
          _accessGuard == null &&
          (_bidFlowExpanded || bidAlreadySubmitted),
      submitEnabled: !bidAlreadySubmitted && submitDisabledMessage == null,
      submitDisabledMessage: submitDisabledMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showSourceNotice: false,
      showActionContainer: false,
      hideResultPanelOnSuccess: true,
      resultSectionsBuilder: (ExhibitionActionResult result) =>
          _buildBidSubmitResultSections(
            context: context,
            result: result,
            projectId: projectId,
          ),
      body: _buildBidSubmitBody(
        context: context,
        routeProjectId: routeProjectId,
        guardLoading: _guardLoading,
        accessGuard: _accessGuard,
        flowExpanded: _bidFlowExpanded,
        projectReviewExpanded: _projectReviewExpanded,
        showContinueBidFlowAction: showContinueBidFlowAction,
        canContinueBidFlow: canContinueBidFlow,
        onContinueBidFlow: _continueBidFlow,
        onToggleProjectReview: _toggleProjectReview,
        projectDetailResult: _projectDetailResult,
        bidMaterialResult: _bidMaterialResult,
        bidMaterialProjectId: projectId,
        openingBidMaterialIds: _openingBidMaterialIds,
        quoteAmountController: _quoteAmountController,
        proposalSummaryController: _proposalSummaryController,
        submitting: _submitting,
        attachmentSlots: _attachmentSlots,
        quoteAmountFieldKey: _quoteAmountFieldKey,
        proposalSummaryFieldKey: _proposalSummaryFieldKey,
        platformServiceFeeChildren:
            _buildP0PayFixedPriceBidAuthorizationFields(),
        onQuoteAmountChanged: () => setState(() {}),
        onProposalSummaryChanged: () => setState(() {}),
        onUploadAttachment: _uploadBidSubmitAttachment,
        onRetryBidMaterials: () => _loadBidMaterials(forceRefresh: true),
        onOpenBidMaterial: _openBidMaterial,
        onPreviewAttachment: (slot) =>
            _BidSubmitAttachmentPreviewActions(this).previewAttachment(slot),
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
      summary: '这里展示当前项目的竞标结果和后续处理入口，不展开完整候选比较台。',
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
                  label: '查看条件',
                  value: '查看竞标结果前，会先核对登录状态、组织身份和项目状态；最终是否可见以平台记录为准。',
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
            summary: '当前页只展示本次竞标结果和必要原因，不展开完整候选比较台。',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              const _InstanceSummaryLine(title: '当前项目', value: '已承接'),
              if (bidId != null) ...<Widget>[
                const SizedBox(height: 12),
                _InstanceSummaryLine(title: '当前竞标', value: bidId),
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
    if (mounted) {
      setState(() {
        _projectDetailResult = detailResult;
        if (_hasCurrentViewerBid(detailResult.payload)) {
          _bidAlreadySubmitted = true;
        }
      });
    }
    return _deriveBidProjectAccessGuard(
      projectId: projectId,
      detailResult: detailResult,
    );
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

  Future<void> _loadSubmitProjectDetail({bool forceRefresh = false}) async {
    final projectId = _normalizeId(_projectIdController.text);
    if (projectId == null) {
      return;
    }

    final result = await ExhibitionConsumerLayer.instance.loadProjectDetail(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _projectDetailResult = result;
      if (_hasCurrentViewerBid(result.payload)) {
        _bidAlreadySubmitted = true;
      }
    });
  }

  Future<void> _continueBidFlow() async {
    if (_bidFlowExpanded) {
      return;
    }

    setState(() {
      _bidFlowExpanded = true;
      _projectReviewExpanded = false;
      _bidMaterialResult = ExhibitionLoadResult(
        state: AppPageState.loading,
        method: 'GET',
        path: ExhibitionCanonicalPaths.projectBidMaterials,
      );
    });

    await _loadBidMaterials();
  }

  void _toggleProjectReview() {
    if (!_bidFlowExpanded) {
      return;
    }

    setState(() {
      _projectReviewExpanded = !_projectReviewExpanded;
    });
  }

  Future<void> _loadBidMaterials({bool forceRefresh = false}) async {
    final projectId = _normalizeId(_projectIdController.text);
    if (projectId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bidMaterialResult = ExhibitionLoadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ExhibitionCanonicalPaths.projectBidMaterials,
          message:
              'projectId is required from route context or page context before bid materials',
        );
      });
      return;
    }

    final result = await ExhibitionConsumerLayer.instance
        .loadProjectBidMaterials(
          projectId: projectId,
          forceRefresh: forceRefresh,
        );
    if (!mounted) {
      return;
    }

    setState(() {
      _bidMaterialResult = result;
    });
  }

  Future<void> _openBidMaterial(ProjectBidMaterialReadModel attachment) async {
    if (_openingBidMaterialIds.contains(attachment.attachmentId)) {
      return;
    }

    final projectId = _normalizeId(_projectIdController.text);
    if (projectId == null) {
      _showBidMaterialMessage('当前还没有承接到项目，暂时不能读取报价依据资料。');
      return;
    }

    setState(() => _openingBidMaterialIds.add(attachment.attachmentId));
    final result = await ExhibitionConsumerLayer.instance
        .requestProjectAttachmentAccess(
          fileAssetId: attachment.fileAssetId,
          mode: _projectAttachmentAccessMode(attachment.mimeType),
          projectId: projectId,
          accessScope: 'bid_material',
        );
    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() => _openingBidMaterialIds.remove(attachment.attachmentId));
      _showBidMaterialMessage(
        _projectAttachmentFileAccessFailureMessage(result),
      );
      return;
    }

    final access = _projectAttachmentFileAccessFromPayload(result.payload);
    if (access == null) {
      setState(() => _openingBidMaterialIds.remove(attachment.attachmentId));
      _showBidMaterialMessage('当前报价依据资料读取结果暂不可用，请稍后再试。');
      return;
    }

    if (_projectAttachmentIsImageMimeType(attachment.mimeType)) {
      final imageBytes = await _loadProjectAttachmentRemoteImageBytes(
        access.accessUrl,
      );
      if (!mounted) {
        return;
      }
      setState(() => _openingBidMaterialIds.remove(attachment.attachmentId));
      if (imageBytes != null && imageBytes.isNotEmpty) {
        await _showProjectAttachmentLocalImagePreviewDialog(
          context,
          fileName: attachment.fileName,
          bytes: imageBytes,
        );
        return;
      }
      final opened = await _openProjectAttachmentUrl(access.accessUrl);
      if (!mounted) {
        return;
      }
      _showBidMaterialMessage(opened ? '资料链接已打开。' : '当前资料暂时无法打开，请稍后再试。');
      return;
    }

    setState(() => _openingBidMaterialIds.remove(attachment.attachmentId));
    final opened = await _openProjectAttachmentUrl(access.accessUrl);
    if (!mounted) {
      return;
    }
    _showBidMaterialMessage(opened ? '资料链接已打开。' : '下载链接已生成，但当前设备未能直接打开，请稍后再试。');
  }

  void _showBidMaterialMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _uploadBidSubmitAttachment(
    _BidSubmitAttachmentSlotState slot,
  ) async {
    final projectId = _normalizeId(_projectIdController.text);
    if (projectId == null) {
      setState(() {
        slot.uploadState = null;
        slot.uploadMessage = '当前还没有承接到项目，暂时不能上传附件。';
        slot.uploadErrorCode = 'BID_PROJECT_ID_REQUIRED';
        slot.uploadPath = ExhibitionCanonicalPaths.uploadInit;
        slot.uploadDirective = null;
        slot.fileAssetId = null;
      });
      return;
    }

    final draft = await _pickBidSubmitAttachmentDraft();
    if (draft == null) {
      return;
    }

    final resolvedDraft = _resolveBidSubmitAttachmentDraft(draft);
    if (resolvedDraft == null ||
        !_bidSubmitAttachmentKindMatchesMimeType(
          slot.fileKind,
          resolvedDraft.mimeType,
        )) {
      setState(() {
        slot.draft = draft;
        slot.resolvedDraft = resolvedDraft;
        slot.uploadState = null;
        slot.uploadMessage = _bidSubmitAttachmentUnsupportedTypeMessage(
          slot.label,
        );
        slot.uploadErrorCode = 'BID_ATTACHMENT_UNSUPPORTED_TYPE';
        slot.uploadPath = ExhibitionCanonicalPaths.uploadInit;
        slot.uploadDirective = null;
        slot.fileAssetId = null;
      });
      return;
    }

    setState(() {
      slot.draft = draft;
      slot.resolvedDraft = resolvedDraft;
      slot.uploadState = AppUploadState.localValidating;
      slot.uploadMessage = '正在准备上传 ${slot.label}。';
      slot.uploadErrorCode = null;
      slot.uploadPath = ExhibitionCanonicalPaths.uploadInit;
      slot.uploadDirective = null;
      slot.fileAssetId = null;
    });

    final initResult = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: _bidSubmitAttachmentBusinessType,
        businessId: projectId,
        fileKind: slot.fileKind,
        mimeType: resolvedDraft.mimeType,
        size: resolvedDraft.sizeInBytes,
        checksum: resolvedDraft.checksum,
      ),
    );

    if (!mounted) {
      return;
    }

    if (initResult.state != AppUploadState.signedReady ||
        initResult.directive == null) {
      setState(() {
        slot.uploadState = initResult.state;
        slot.uploadMessage = initResult.message ?? '当前附件上传初始化未完成，请稍后再试。';
        slot.uploadErrorCode = initResult.errorCode;
        slot.uploadPath = initResult.path;
        slot.uploadDirective = initResult.directive;
        slot.fileAssetId = null;
      });
      return;
    }

    setState(() {
      slot.uploadState = AppUploadState.uploading;
      slot.uploadMessage = '正在直传 ${slot.label}。';
      slot.uploadErrorCode = null;
      slot.uploadPath = initResult.path;
      slot.uploadDirective = initResult.directive;
    });

    final directUploadResult = await ExhibitionConsumerLayer.instance
        .directUpload(
          directive: initResult.directive!,
          bodyBytes: resolvedDraft.bytes,
        );

    if (!mounted) {
      return;
    }

    if (directUploadResult.state != AppUploadState.uploadConfirming ||
        directUploadResult.directive == null) {
      setState(() {
        slot.uploadState = directUploadResult.state;
        slot.uploadMessage = directUploadResult.message ?? '当前附件直传未完成，请重新上传。';
        slot.uploadErrorCode = directUploadResult.errorCode;
        slot.uploadPath = directUploadResult.path;
        slot.uploadDirective = directUploadResult.directive;
        slot.fileAssetId = null;
      });
      return;
    }

    setState(() {
      slot.uploadState = AppUploadState.uploadConfirming;
      slot.uploadMessage = '正在确认 ${slot.label} 上传结果。';
      slot.uploadErrorCode = null;
      slot.uploadPath = directUploadResult.path;
      slot.uploadDirective = directUploadResult.directive;
    });

    final confirmResult = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: directUploadResult.directive!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      slot.uploadState = confirmResult.state;
      slot.uploadMessage =
          confirmResult.message ??
          (confirmResult.state == AppUploadState.uploadBound
              ? '当前文件已完成上传绑定。'
              : '当前附件确认结果未完成，请稍后再试。');
      slot.uploadErrorCode = confirmResult.errorCode;
      slot.uploadPath = confirmResult.path;
      slot.uploadDirective = directUploadResult.directive;
      slot.fileAssetId = confirmResult.fileAssetId;
    });
  }
}
