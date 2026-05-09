// ignore_for_file: invalid_use_of_protected_member

part of '../exhibition_trade_pages.dart';

const String _bidServiceFeeAuthorizationRuleVersion =
    'platform_pricing_rules_master_v1';
const String _bidServiceFeeAuthorizationRuleSnapshotHash =
    'platform_pricing_rules_master_v1';
const String _bidServiceFeeAuthorizationChannel = 'alipay_candidate';

enum _BidServiceFeeAuthorizationUiPhase {
  notStarted,
  launching,
  waiting,
  completed,
  failed,
}

extension _BidServiceFeeAuthorizationFlowSupport on _BidSubmitPageState {
  List<Widget> _buildBidServiceFeeAuthorizationActionFields({
    required String? routeProjectId,
    required String? bidParticipationRequestId,
  }) {
    final rcBlocked = !RcReleaseFlags.bidServiceFeeAuthorizationEnabled;
    final blocker = _bidServiceFeeAuthorizationBlockerMessage(
      routeProjectId: routeProjectId,
      bidParticipationRequestId: bidParticipationRequestId,
    );
    final frozen = _bidServiceFeeAuthorizationFrozen;
    final phase = _bidServiceFeeAuthorizationUiPhase(blocker);
    final visibleFailure = _bidServiceFeeAuthorizationVisibleFailureMessage();

    return <Widget>[
      const SizedBox(height: 16),
      const Divider(height: 1),
      const SizedBox(height: 16),
      _BidServiceFeeAuthorizationStatusPanel(
        phase: phase,
        title: _bidServiceFeeAuthorizationPhaseTitle(phase),
        description: _bidServiceFeeAuthorizationPhaseDescription(phase),
      ),
      const _DetailLine(
        label: '预授权额度',
        value: '4000 元竞标服务费预授权额度，不是扣款',
        highlight: true,
      ),
      const _DetailLine(
        label: '确认方式',
        value: '使用支付宝确认预授权；未收到 Server 完成状态前，不显示完成。',
      ),
      const _DetailLine(label: '发送权限', value: '未完成前项目级自由发送仍由 Server 保持锁定。'),
      const SizedBox(height: 12),
      if (visibleFailure != null) ...<Widget>[
        _StateMessage(title: '未完成原因', body: visibleFailure),
        const SizedBox(height: 12),
      ],
      if (rcBlocked) ...<Widget>[
        const _StateMessage(
          title: rcFeatureUnavailableTitle,
          body: rcFeatureUnavailableMessage,
        ),
        const SizedBox(height: 12),
      ],
      if (blocker != null) ...<Widget>[
        _StateMessage(title: '暂不能处理', body: blocker),
        const SizedBox(height: 12),
      ],
      FilledButton.icon(
        onPressed:
            !rcBlocked &&
                blocker == null &&
                !_bidServiceFeeAuthorizationSubmitting &&
                !frozen
            ? _confirmAndSubmitBidServiceFeeAuthorizationFlow
            : null,
        icon: _bidServiceFeeAuthorizationSubmitting
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.verified_user_outlined),
        label: Text(_bidServiceFeeAuthorizationPrimaryButtonLabel),
      ),
      if (_bidServiceFeeAuthorizationCanRefresh) ...<Widget>[
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _bidServiceFeeAuthorizationSubmitting
              ? null
              : _refreshBidServiceFeeAuthorizationStatus,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('刷新预授权状态'),
        ),
      ],
      const SizedBox(height: 12),
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: const Text('技术详情（排障用）'),
          subtitle: const Text('默认收起，仅用于排查通道、回调和状态回读问题。'),
          children: _buildBidServiceFeeAuthorizationResultLines(),
        ),
      ),
      const SizedBox(height: 8),
      const _StateMessage(
        title: '发送说明',
        body:
            '本页不开放聊天发送，也不本地放行消息；完成后是否能发送仍以 Server 返回的 chatAvailability.canSendMessage 为准。',
      ),
    ];
  }

  Future<void> _confirmAndSubmitBidServiceFeeAuthorizationFlow() async {
    final confirmed = await _showBidServiceFeeAuthorizationConfirmSheet(
      context,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _submitBidServiceFeeAuthorizationFlow();
  }

  Future<void> _submitBidServiceFeeAuthorizationFlow() async {
    FocusScope.of(context).unfocus();
    if (!RcReleaseFlags.bidServiceFeeAuthorizationEnabled) {
      setState(() {
        _bidServiceFeeAuthorizationCreateResult = ExhibitionActionResult(
          method: 'POST',
          path: '/api/app/project/{projectId}/bid-service-fee-authorizations',
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          errorCode: 'PLATFORM_CAPABILITY_DISABLED',
          message: rcFeatureUnavailableTitle,
        );
      });
      return;
    }
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
      _bidServiceFeeAuthorizationPollResult = null;
      _bidServiceFeeAuthorizationChannelHandoffMessage = null;
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
    if (_bidServiceFeeAuthorizationStatusFromPayload(createResult.payload) ==
        'frozen') {
      setState(() {
        _bidServiceFeeAuthorizationStatusResult = ExhibitionLoadResult(
          state: AppPageState.content,
          method: 'GET',
          path:
              ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus(
                projectId,
                authorizationId ?? '{authorizationId}',
              ),
          payload: createResult.payload,
          message: 'Server 已返回预授权完成状态。',
        );
        _bidServiceFeeAuthorizationSubmitting = false;
      });
      return;
    }
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

    final channelOpened = await _openPaymentChannelPayload(
      freezeInitResult.payload,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _bidServiceFeeAuthorizationChannelHandoffMessage =
          _bidServiceFeeAuthorizationChannelHandoffText(
            freezeInitResult.payload,
            channelOpened: channelOpened,
          );
    });
    final pollResult = await ExhibitionConsumerLayer.instance
        .pollProjectBidServiceFeeAuthorizationStatus(
          projectId: projectId,
          authorizationId: authorizationId,
          maxAttempts: 3,
          interval: const Duration(milliseconds: 300),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _bidServiceFeeAuthorizationPollResult = pollResult;
      _bidServiceFeeAuthorizationStatusResult = pollResult.result;
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
    final pollResult = _bidServiceFeeAuthorizationPollResult;
    final channelHandoffMessage =
        _bidServiceFeeAuthorizationChannelHandoffMessage;
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
        if (channelHandoffMessage != null)
          _DetailLine(
            label: '通道拉起',
            value: channelHandoffMessage,
            highlight: _bidServiceFeeAuthorizationFrozen,
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
      if (pollResult != null)
        _DetailLine(
          label: '轮询结果',
          value: _bidServiceFeeAuthorizationPollText(pollResult),
          highlight: _bidServiceFeeAuthorizationFrozen,
        ),
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
    return RcReleaseFlags.bidServiceFeeAuthorizationEnabled &&
        _currentBidServiceFeeAuthorizationId != null;
  }

  bool get _bidServiceFeeAuthorizationFrozen {
    final statusResult = _bidServiceFeeAuthorizationStatusResult;
    final status =
        _bidServiceFeeAuthorizationStatusFromPayload(
          statusResult?.state == AppPageState.content
              ? statusResult?.payload
              : null,
        ) ??
        _bidServiceFeeAuthorizationStatusFromPayload(
          _bidServiceFeeAuthorizationFreezeInitResult?.payload,
        ) ??
        _bidServiceFeeAuthorizationStatusFromPayload(
          _bidServiceFeeAuthorizationCreateResult?.payload,
        );
    return status == 'frozen';
  }

  _BidServiceFeeAuthorizationUiPhase _bidServiceFeeAuthorizationUiPhase(
    String? blocker,
  ) {
    if (_bidServiceFeeAuthorizationFrozen) {
      return _BidServiceFeeAuthorizationUiPhase.completed;
    }
    if (blocker != null) {
      return _BidServiceFeeAuthorizationUiPhase.failed;
    }
    if (_bidServiceFeeAuthorizationSubmitting) {
      return _BidServiceFeeAuthorizationUiPhase.launching;
    }
    final createResult = _bidServiceFeeAuthorizationCreateResult;
    final freezeInitResult = _bidServiceFeeAuthorizationFreezeInitResult;
    final statusResult = _bidServiceFeeAuthorizationStatusResult;
    final status = _bidServiceFeeAuthorizationStatusFromPayload(
      statusResult?.payload,
    );
    if (createResult?.isSuccess == false ||
        freezeInitResult?.isSuccess == false) {
      return _BidServiceFeeAuthorizationUiPhase.failed;
    }
    if (statusResult != null && statusResult.state != AppPageState.content) {
      return _BidServiceFeeAuthorizationUiPhase.failed;
    }
    if (status == 'failed' ||
        status == 'cancelled' ||
        status == 'expired' ||
        status == 'released') {
      return _BidServiceFeeAuthorizationUiPhase.failed;
    }
    if (createResult != null ||
        freezeInitResult != null ||
        statusResult != null) {
      return _BidServiceFeeAuthorizationUiPhase.waiting;
    }
    return _BidServiceFeeAuthorizationUiPhase.notStarted;
  }

  String _bidServiceFeeAuthorizationPhaseTitle(
    _BidServiceFeeAuthorizationUiPhase phase,
  ) {
    return switch (phase) {
      _BidServiceFeeAuthorizationUiPhase.notStarted => '待确认预授权',
      _BidServiceFeeAuthorizationUiPhase.launching => '正在打开支付宝确认',
      _BidServiceFeeAuthorizationUiPhase.waiting => '等待支付结果确认',
      _BidServiceFeeAuthorizationUiPhase.completed => '预授权已完成',
      _BidServiceFeeAuthorizationUiPhase.failed => '预授权暂未完成',
    };
  }

  String _bidServiceFeeAuthorizationPhaseDescription(
    _BidServiceFeeAuthorizationUiPhase phase,
  ) {
    return switch (phase) {
      _BidServiceFeeAuthorizationUiPhase.notStarted =>
        '点击下方按钮后，将创建 4000 元竞标服务费预授权额度并打开支付宝确认。',
      _BidServiceFeeAuthorizationUiPhase.launching =>
        '正在创建预授权记录并尝试打开支付宝，请不要重复点击。',
      _BidServiceFeeAuthorizationUiPhase.waiting =>
        '已提交预授权处理，正在等待支付结果确认；未完成前不会解锁消息发送。',
      _BidServiceFeeAuthorizationUiPhase.completed =>
        'Server 已确认预授权完成，可返回消息页刷新发送状态。',
      _BidServiceFeeAuthorizationUiPhase.failed =>
        '当前暂未完成预授权，请重新尝试或稍后刷新状态；本地不会显示成功。',
    };
  }

  String get _bidServiceFeeAuthorizationPrimaryButtonLabel {
    if (!RcReleaseFlags.bidServiceFeeAuthorizationEnabled) {
      return rcFeatureUnavailableTitle;
    }
    if (_bidServiceFeeAuthorizationFrozen) {
      return '预授权已完成';
    }
    if (_bidServiceFeeAuthorizationSubmitting) {
      return '处理中';
    }
    if (_bidServiceFeeAuthorizationCreateResult != null ||
        _bidServiceFeeAuthorizationFreezeInitResult != null ||
        _bidServiceFeeAuthorizationStatusResult != null) {
      return '重新确认预授权';
    }
    return '去支付宝确认预授权';
  }

  String? _bidServiceFeeAuthorizationVisibleFailureMessage() {
    final createResult = _bidServiceFeeAuthorizationCreateResult;
    if (createResult != null && !createResult.isSuccess) {
      return _bidServiceFeeAuthorizationUserFailureMessage(
        createResult,
        fallback: '预授权记录暂未创建成功。',
      );
    }
    final freezeInitResult = _bidServiceFeeAuthorizationFreezeInitResult;
    if (freezeInitResult != null && !freezeInitResult.isSuccess) {
      return _bidServiceFeeAuthorizationUserFailureMessage(
        freezeInitResult,
        fallback: '支付宝预授权暂未拉起成功。',
      );
    }
    final statusResult = _bidServiceFeeAuthorizationStatusResult;
    if (statusResult != null && statusResult.state != AppPageState.content) {
      return statusResult.message ?? statusResult.errorCode ?? '预授权状态暂未回读成功。';
    }
    final status = _bidServiceFeeAuthorizationStatusFromPayload(
      statusResult?.payload,
    );
    if (status == 'failed' ||
        status == 'cancelled' ||
        status == 'expired' ||
        status == 'released') {
      return '预授权暂未完成，请重新尝试或稍后刷新状态。';
    }
    return null;
  }

  String _bidServiceFeeAuthorizationUserFailureMessage(
    ExhibitionActionResult result, {
    required String fallback,
  }) {
    if (result.errorCode ==
        'BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED') {
      return result.message ?? '当前预授权状态暂不能重新拉起，请刷新状态后处理。';
    }
    if ((result.message ?? '').contains(
      'Current service fee authorization cannot be initialized',
    )) {
      return '当前预授权状态暂不能重新拉起支付宝，请刷新状态后处理。';
    }
    return result.message ?? result.errorCode ?? fallback;
  }
}

class _BidServiceFeeAuthorizationStatusPanel extends StatelessWidget {
  const _BidServiceFeeAuthorizationStatusPanel({
    required this.phase,
    required this.title,
    required this.description,
  });

  final _BidServiceFeeAuthorizationUiPhase phase;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (phase) {
      _BidServiceFeeAuthorizationUiPhase.completed => const Color(0xFF20935F),
      _BidServiceFeeAuthorizationUiPhase.failed => const Color(0xFFC24A3A),
      _BidServiceFeeAuthorizationUiPhase.launching => const Color(0xFF2B75B8),
      _BidServiceFeeAuthorizationUiPhase.waiting => const Color(0xFFB77A20),
      _BidServiceFeeAuthorizationUiPhase.notStarted => const Color(0xFFB77A20),
    };
    final background = color.withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(_bidServiceFeeAuthorizationPhaseIcon(phase), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF16151A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5E5964),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _bidServiceFeeAuthorizationPhaseIcon(
  _BidServiceFeeAuthorizationUiPhase phase,
) {
  return switch (phase) {
    _BidServiceFeeAuthorizationUiPhase.completed =>
      Icons.verified_user_outlined,
    _BidServiceFeeAuthorizationUiPhase.failed => Icons.error_outline_rounded,
    _BidServiceFeeAuthorizationUiPhase.launching => Icons.open_in_new_rounded,
    _BidServiceFeeAuthorizationUiPhase.waiting => Icons.hourglass_top_rounded,
    _BidServiceFeeAuthorizationUiPhase.notStarted => Icons.shield_outlined,
  };
}
