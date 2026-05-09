// ignore_for_file: invalid_use_of_protected_member

part of '../exhibition_trade_pages.dart';

const String _bidServiceFeeAuthorizationRuleVersion =
    'platform_pricing_rules_master_v1';
const String _bidServiceFeeAuthorizationRuleSnapshotHash =
    'platform_pricing_rules_master_v1';
const String _bidServiceFeeAuthorizationChannel = 'other_candidate';

extension _BidServiceFeeAuthorizationFlowSupport on _BidSubmitPageState {
  List<Widget> _buildBidServiceFeeAuthorizationActionFields({
    required String? routeProjectId,
    required String? bidParticipationRequestId,
  }) {
    final blocker = _bidServiceFeeAuthorizationBlockerMessage(
      routeProjectId: routeProjectId,
      bidParticipationRequestId: bidParticipationRequestId,
    );
    final frozen = _bidServiceFeeAuthorizationFrozen;

    return <Widget>[
      const SizedBox(height: 16),
      const Divider(height: 1),
      const SizedBox(height: 16),
      _DetailLine(
        label: '执行入口',
        value: _bidServiceFeeAuthorizationSubmitting
            ? '正在按 Server/BFF 链路处理'
            : frozen
            ? '预授权已完成'
            : '待创建并拉起预授权',
        highlight: frozen,
      ),
      const _DetailLine(
        label: '预授权额度',
        value: '4000 元竞标服务费预授权额度，不是扣款',
        highlight: true,
      ),
      const _DetailLine(
        label: '测试通道',
        value: 'other_candidate / clientPlatform=flutter',
      ),
      const SizedBox(height: 12),
      ..._buildBidServiceFeeAuthorizationResultLines(),
      if (blocker != null) ...<Widget>[
        const SizedBox(height: 12),
        _StateMessage(title: '暂不能处理', body: blocker),
      ],
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed:
            blocker == null && !_bidServiceFeeAuthorizationSubmitting && !frozen
            ? _submitBidServiceFeeAuthorizationFlow
            : null,
        icon: _bidServiceFeeAuthorizationSubmitting
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.verified_user_outlined),
        label: Text(_bidServiceFeeAuthorizationSubmitting ? '处理中' : '创建并拉起预授权'),
      ),
      if (_bidServiceFeeAuthorizationCanRefresh) ...<Widget>[
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _bidServiceFeeAuthorizationSubmitting
              ? null
              : _refreshBidServiceFeeAuthorizationStatus,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('重新回读预授权状态'),
        ),
      ],
      const SizedBox(height: 8),
      const _StateMessage(
        title: '发送说明',
        body:
            '本页不开放聊天发送，也不本地放行消息；完成后是否能发送仍以 Server 返回的 chatAvailability.canSendMessage 为准。',
      ),
    ];
  }

  Future<void> _submitBidServiceFeeAuthorizationFlow() async {
    FocusScope.of(context).unfocus();
    final projectId =
        _normalizeId(widget.projectId) ??
        _normalizeId(_projectIdController.text);
    final bidParticipationRequestId = _normalizeId(
      widget.bidParticipationRequestId,
    );
    final blocker = _bidServiceFeeAuthorizationBlockerMessage(
      routeProjectId: projectId,
      bidParticipationRequestId: bidParticipationRequestId,
    );
    if (projectId == null ||
        bidParticipationRequestId == null ||
        blocker != null) {
      setState(() {
        _bidServiceFeeAuthorizationCreateResult = ExhibitionActionResult(
          method: 'POST',
          path: projectId == null
              ? '/api/app/project/{projectId}/bid-service-fee-authorizations'
              : ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizations(
                  projectId,
                ),
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: blocker ?? '当前没有完整项目或参与申请上下文，不能拉起预授权。',
        );
      });
      return;
    }

    setState(() {
      _bidServiceFeeAuthorizationSubmitting = true;
      _bidServiceFeeAuthorizationCreateResult = null;
      _bidServiceFeeAuthorizationFreezeInitResult = null;
      _bidServiceFeeAuthorizationStatusResult = null;
    });

    final createResult = await ExhibitionConsumerLayer.instance
        .createProjectBidServiceFeeAuthorization(
          projectId: projectId,
          command: BidServiceFeeAuthorizationCommand(
            bidParticipationRequestId: bidParticipationRequestId,
            ruleVersion: _bidServiceFeeAuthorizationRuleVersion,
            ruleSnapshotHash: _bidServiceFeeAuthorizationRuleSnapshotHash,
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _bidServiceFeeAuthorizationCreateResult = createResult;
    });

    final authorizationId = _projectBidServiceFeeAuthorizationIdFromPayload(
      createResult.payload,
    );
    if (!createResult.isSuccess || authorizationId == null) {
      setState(() {
        if (createResult.isSuccess && authorizationId == null) {
          _bidServiceFeeAuthorizationStatusResult = ExhibitionLoadResult(
            state: AppPageState.errorNonRetryable,
            method: 'GET',
            path:
                ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus(
                  projectId,
                  '{authorizationId}',
                ),
            message: 'BFF/Server 未返回 authorizationId，不能继续拉起预授权。',
          );
        }
        _bidServiceFeeAuthorizationSubmitting = false;
      });
      return;
    }

    final freezeInitResult = await ExhibitionConsumerLayer.instance
        .initProjectBidServiceFeeAuthorizationFreeze(
          projectId: projectId,
          authorizationId: authorizationId,
          command: ProjectPricingPayInitCommand(
            payChannel: _bidServiceFeeAuthorizationChannel,
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _bidServiceFeeAuthorizationFreezeInitResult = freezeInitResult;
    });
    if (!freezeInitResult.isSuccess) {
      setState(() {
        _bidServiceFeeAuthorizationSubmitting = false;
      });
      return;
    }

    await _openPaymentChannelPayload(freezeInitResult.payload);
    await _loadBidServiceFeeAuthorizationStatus(
      projectId: projectId,
      authorizationId: authorizationId,
    );
    if (mounted) {
      setState(() {
        _bidServiceFeeAuthorizationSubmitting = false;
      });
    }
  }

  Future<void> _refreshBidServiceFeeAuthorizationStatus() async {
    final projectId =
        _normalizeId(widget.projectId) ??
        _normalizeId(_projectIdController.text);
    final authorizationId = _currentBidServiceFeeAuthorizationId;
    if (projectId == null || authorizationId == null) {
      return;
    }
    setState(() {
      _bidServiceFeeAuthorizationSubmitting = true;
    });
    await _loadBidServiceFeeAuthorizationStatus(
      projectId: projectId,
      authorizationId: authorizationId,
    );
    if (mounted) {
      setState(() {
        _bidServiceFeeAuthorizationSubmitting = false;
      });
    }
  }

  Future<void> _loadBidServiceFeeAuthorizationStatus({
    required String projectId,
    required String authorizationId,
  }) async {
    final statusResult = await ExhibitionConsumerLayer.instance
        .loadProjectBidServiceFeeAuthorizationStatus(
          projectId: projectId,
          authorizationId: authorizationId,
          forceRefresh: true,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _bidServiceFeeAuthorizationStatusResult = statusResult;
    });
  }

  String? _bidServiceFeeAuthorizationBlockerMessage({
    required String? routeProjectId,
    required String? bidParticipationRequestId,
  }) {
    if (_guardLoading) {
      return '当前正在核对入口守卫，请稍候再试。';
    }
    if (_accessGuard != null) {
      return _accessGuard!.message;
    }
    if (_normalizeId(routeProjectId) == null) {
      return '当前没有承接到项目，不能创建预授权。';
    }
    if (_normalizeId(bidParticipationRequestId) == null) {
      return '当前没有承接到参与申请，不能创建预授权。';
    }
    return null;
  }

  List<Widget> _buildBidServiceFeeAuthorizationResultLines() {
    final createResult = _bidServiceFeeAuthorizationCreateResult;
    final freezeInitResult = _bidServiceFeeAuthorizationFreezeInitResult;
    final statusResult = _bidServiceFeeAuthorizationStatusResult;
    if (createResult == null &&
        freezeInitResult == null &&
        statusResult == null) {
      return const <Widget>[
        _DetailLine(label: '当前状态', value: '未开始'),
        _DetailLine(label: '处理提示', value: '点击后先创建预授权记录，再拉起受控通道并回读状态。'),
      ];
    }

    return <Widget>[
      if (createResult != null)
        _DetailLine(
          label: '创建预授权记录',
          value: createResult.isSuccess
              ? '已创建：${_projectBidServiceFeeAuthorizationIdFromPayload(createResult.payload) ?? '待回读'}'
              : _bidServiceFeeAuthorizationActionFailureText(createResult),
          highlight: createResult.isSuccess,
        ),
      if (freezeInitResult != null) ...<Widget>[
        _DetailLine(
          label: '拉起受控通道',
          value: freezeInitResult.isSuccess
              ? '已拉起：${_paymentReferenceIdFromPayload(freezeInitResult.payload) ?? '等待通道确认'}'
              : _bidServiceFeeAuthorizationActionFailureText(freezeInitResult),
          highlight: freezeInitResult.isSuccess,
        ),
        _DetailLine(
          label: '通道动作',
          value: _bidServiceFeeAuthorizationChannelActionText(
            freezeInitResult.payload,
          ),
          highlight: freezeInitResult.isSuccess,
        ),
        _DetailLine(
          label: '回调等待',
          value: _bidServiceFeeAuthorizationCallbackText(
            freezeInitResult.payload,
          ),
          highlight: _bidServiceFeeAuthorizationCallbackAwaiting(
            freezeInitResult.payload,
          ),
        ),
      ],
      if (statusResult != null)
        _DetailLine(
          label: '状态回读',
          value: _bidServiceFeeAuthorizationStatusText(statusResult),
          highlight: _bidServiceFeeAuthorizationFrozen,
        ),
      if (!_bidServiceFeeAuthorizationFrozen &&
          freezeInitResult?.isSuccess == true)
        const _StateMessage(
          title: '等待回调',
          body: '已完成受控通道拉起，当前等待 Server 受控回调确认；未回读 frozen 前不显示已完成。',
        ),
    ];
  }

  String? get _currentBidServiceFeeAuthorizationId {
    return _projectBidServiceFeeAuthorizationIdFromPayload(
          _bidServiceFeeAuthorizationCreateResult?.payload,
        ) ??
        _projectBidServiceFeeAuthorizationIdFromPayload(
          _bidServiceFeeAuthorizationStatusResult?.payload,
        );
  }

  bool get _bidServiceFeeAuthorizationCanRefresh {
    return _currentBidServiceFeeAuthorizationId != null;
  }

  bool get _bidServiceFeeAuthorizationFrozen {
    final statusResult = _bidServiceFeeAuthorizationStatusResult;
    if (statusResult == null || statusResult.state != AppPageState.content) {
      return false;
    }
    final status = _bidServiceFeeAuthorizationStatusFromPayload(
      statusResult.payload,
    );
    return status == 'frozen';
  }
}
