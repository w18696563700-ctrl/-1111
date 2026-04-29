part of '../exhibition_consumer_layer.dart';

extension ExhibitionP0PayConsumerActions on ExhibitionConsumerLayer {
  Future<ExhibitionActionResult> createP0PayTradeTask(
    P0PayTradeTaskCreateCommand command,
  ) {
    return _actionService.createP0PayTradeTask(command);
  }

  Future<ExhibitionActionResult> createP0PayInquiryDepositOrder({
    required String taskId,
    required P0PayInquiryDepositOrderCommand command,
  }) {
    return _actionService.createP0PayInquiryDepositOrder(
      taskId: taskId,
      command: command,
    );
  }

  Future<ExhibitionActionResult> initP0PayInquiryDepositPayment({
    required String taskId,
    required String depositOrderId,
    required P0PayPayInitCommand command,
  }) {
    return _actionService.initP0PayInquiryDepositPayment(
      taskId: taskId,
      depositOrderId: depositOrderId,
      command: command,
    );
  }

  Future<ExhibitionLoadResult> loadP0PayInquiryDepositStatus({
    required String taskId,
    required String depositOrderId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadP0PayInquiryDepositStatus(
      taskId: taskId,
      depositOrderId: depositOrderId,
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollP0PayInquiryDepositStatus({
    required String taskId,
    required String depositOrderId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _loadService.pollP0PayInquiryDepositStatus(
      taskId: taskId,
      depositOrderId: depositOrderId,
      maxAttempts: maxAttempts,
      interval: interval,
    );
  }

  Future<ExhibitionLoadResult> loadProjectPricingSummary({
    required String projectId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectPricingSummary(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionActionResult> createProjectAuthenticitySincerityOrder({
    required String projectId,
    required ProjectAuthenticitySincerityOrderCommand command,
  }) {
    return _actionService.createProjectAuthenticitySincerityOrder(
      projectId: projectId,
      command: command,
    );
  }

  Future<ExhibitionActionResult> initProjectAuthenticitySincerityPayment({
    required String projectId,
    required String orderId,
    required ProjectPricingPayInitCommand command,
  }) {
    return _actionService.initProjectAuthenticitySincerityPayment(
      projectId: projectId,
      orderId: orderId,
      command: command,
    );
  }

  Future<ExhibitionLoadResult> loadProjectAuthenticitySincerityOrderStatus({
    required String projectId,
    required String orderId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectAuthenticitySincerityOrderStatus(
      projectId: projectId,
      orderId: orderId,
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollProjectAuthenticitySincerityOrderStatus({
    required String projectId,
    required String orderId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _loadService.pollProjectAuthenticitySincerityOrderStatus(
      projectId: projectId,
      orderId: orderId,
      maxAttempts: maxAttempts,
      interval: interval,
    );
  }

  Future<ExhibitionActionResult> createProjectBidServiceFeeAuthorization({
    required String projectId,
    required BidServiceFeeAuthorizationCommand command,
  }) {
    return _actionService.createProjectBidServiceFeeAuthorization(
      projectId: projectId,
      command: command,
    );
  }

  Future<ExhibitionActionResult> initProjectBidServiceFeeAuthorizationFreeze({
    required String projectId,
    required String authorizationId,
    required ProjectPricingPayInitCommand command,
  }) {
    return _actionService.initProjectBidServiceFeeAuthorizationFreeze(
      projectId: projectId,
      authorizationId: authorizationId,
      command: command,
    );
  }

  Future<ExhibitionLoadResult> loadProjectBidServiceFeeAuthorizationStatus({
    required String projectId,
    required String authorizationId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadProjectBidServiceFeeAuthorizationStatus(
      projectId: projectId,
      authorizationId: authorizationId,
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollProjectBidServiceFeeAuthorizationStatus({
    required String projectId,
    required String authorizationId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _loadService.pollProjectBidServiceFeeAuthorizationStatus(
      projectId: projectId,
      authorizationId: authorizationId,
      maxAttempts: maxAttempts,
      interval: interval,
    );
  }

  Future<ExhibitionActionResult> submitP0PayFixedPriceBid({
    required String taskId,
    required P0PayFixedPriceBidCommand command,
  }) {
    return _actionService.submitP0PayFixedPriceBid(
      taskId: taskId,
      command: command,
    );
  }

  Future<ExhibitionActionResult> createP0PayServiceFeeAuthorization({
    required String taskId,
    required String bidId,
    required P0PayServiceFeeAuthorizationCommand command,
  }) {
    return _actionService.createP0PayServiceFeeAuthorization(
      taskId: taskId,
      bidId: bidId,
      command: command,
    );
  }

  Future<ExhibitionActionResult> initP0PayServiceFeeAuthorization({
    required String taskId,
    required String bidId,
    required String authorizationId,
    required P0PayPayInitCommand command,
  }) {
    return _actionService.initP0PayServiceFeeAuthorization(
      taskId: taskId,
      bidId: bidId,
      authorizationId: authorizationId,
      command: command,
    );
  }

  Future<ExhibitionLoadResult> loadP0PayServiceFeeAuthorizationStatus({
    required String taskId,
    required String bidId,
    required String authorizationId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadP0PayServiceFeeAuthorizationStatus(
      taskId: taskId,
      bidId: bidId,
      authorizationId: authorizationId,
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollP0PayServiceFeeAuthorizationStatus({
    required String taskId,
    required String bidId,
    required String authorizationId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _loadService.pollP0PayServiceFeeAuthorizationStatus(
      taskId: taskId,
      bidId: bidId,
      authorizationId: authorizationId,
      maxAttempts: maxAttempts,
      interval: interval,
    );
  }

  Future<ExhibitionLoadResult> loadP0PaySummary({
    required String taskId,
    bool forceRefresh = false,
  }) {
    return _loadService.loadP0PaySummary(
      taskId: taskId,
      forceRefresh: forceRefresh,
    );
  }
}

extension _ExhibitionP0PayActionService on _ExhibitionActionService {
  Future<ExhibitionActionResult> createP0PayTradeTask(
    P0PayTradeTaskCreateCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.p0PayTradeTaskCreate,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> createP0PayInquiryDepositOrder({
    required String taskId,
    required P0PayInquiryDepositOrderCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.p0PayInquiryDepositOrders(taskId),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> initP0PayInquiryDepositPayment({
    required String taskId,
    required String depositOrderId,
    required P0PayPayInitCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.p0PayInquiryDepositPayInit(
        taskId,
        depositOrderId,
      ),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> createProjectAuthenticitySincerityOrder({
    required String projectId,
    required ProjectAuthenticitySincerityOrderCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectAuthenticitySincerityOrders(projectId),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> initProjectAuthenticitySincerityPayment({
    required String projectId,
    required String orderId,
    required ProjectPricingPayInitCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectAuthenticitySincerityPayInit(
        projectId,
        orderId,
      ),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> createProjectBidServiceFeeAuthorization({
    required String projectId,
    required BidServiceFeeAuthorizationCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizations(projectId),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> initProjectBidServiceFeeAuthorizationFreeze({
    required String projectId,
    required String authorizationId,
    required ProjectPricingPayInitCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationFreezeInit(
        projectId,
        authorizationId,
      ),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitP0PayFixedPriceBid({
    required String taskId,
    required P0PayFixedPriceBidCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.p0PayFixedPriceBids(taskId),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> createP0PayServiceFeeAuthorization({
    required String taskId,
    required String bidId,
    required P0PayServiceFeeAuthorizationCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizations(taskId, bidId),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> initP0PayServiceFeeAuthorization({
    required String taskId,
    required String bidId,
    required String authorizationId,
    required P0PayPayInitCommand command,
  }) {
    return _submitProtected(
      ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizeInit(
        taskId,
        bidId,
        authorizationId,
      ),
      body: command.toJson(),
    );
  }
}

extension _ExhibitionP0PayLoadService on _ExhibitionLoadService {
  Future<ExhibitionLoadResult> loadProjectPricingSummary({
    required String projectId,
    bool forceRefresh = false,
  }) {
    return _loadGet(
      ExhibitionCanonicalPaths.projectPricingSummary(projectId),
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadProjectAuthenticitySincerityOrderStatus({
    required String projectId,
    required String orderId,
    bool forceRefresh = false,
  }) {
    return _loadGet(
      ExhibitionCanonicalPaths.projectAuthenticitySincerityOrderStatus(
        projectId,
        orderId,
      ),
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollProjectAuthenticitySincerityOrderStatus({
    required String projectId,
    required String orderId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _pollP0PayStatus(
      kind: P0PayPaymentKind.projectAuthenticitySincerity,
      maxAttempts: maxAttempts,
      interval: interval,
      loadStatus: () => loadProjectAuthenticitySincerityOrderStatus(
        projectId: projectId,
        orderId: orderId,
        forceRefresh: true,
      ),
    );
  }

  Future<ExhibitionLoadResult> loadProjectBidServiceFeeAuthorizationStatus({
    required String projectId,
    required String authorizationId,
    bool forceRefresh = false,
  }) {
    return _loadGet(
      ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus(
        projectId,
        authorizationId,
      ),
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollProjectBidServiceFeeAuthorizationStatus({
    required String projectId,
    required String authorizationId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _pollP0PayStatus(
      kind: P0PayPaymentKind.serviceFeeAuthorization,
      maxAttempts: maxAttempts,
      interval: interval,
      loadStatus: () => loadProjectBidServiceFeeAuthorizationStatus(
        projectId: projectId,
        authorizationId: authorizationId,
        forceRefresh: true,
      ),
    );
  }

  Future<ExhibitionLoadResult> loadP0PayInquiryDepositStatus({
    required String taskId,
    required String depositOrderId,
    bool forceRefresh = false,
  }) {
    return _loadGet(
      ExhibitionCanonicalPaths.p0PayInquiryDepositStatus(
        taskId,
        depositOrderId,
      ),
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollP0PayInquiryDepositStatus({
    required String taskId,
    required String depositOrderId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _pollP0PayStatus(
      kind: P0PayPaymentKind.inquiryDeposit,
      maxAttempts: maxAttempts,
      interval: interval,
      loadStatus: () => loadP0PayInquiryDepositStatus(
        taskId: taskId,
        depositOrderId: depositOrderId,
        forceRefresh: true,
      ),
    );
  }

  Future<ExhibitionLoadResult> loadP0PayServiceFeeAuthorizationStatus({
    required String taskId,
    required String bidId,
    required String authorizationId,
    bool forceRefresh = false,
  }) {
    return _loadGet(
      ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizationStatus(
        taskId,
        bidId,
        authorizationId,
      ),
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> pollP0PayServiceFeeAuthorizationStatus({
    required String taskId,
    required String bidId,
    required String authorizationId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) {
    return _pollP0PayStatus(
      kind: P0PayPaymentKind.serviceFeeAuthorization,
      maxAttempts: maxAttempts,
      interval: interval,
      loadStatus: () => loadP0PayServiceFeeAuthorizationStatus(
        taskId: taskId,
        bidId: bidId,
        authorizationId: authorizationId,
        forceRefresh: true,
      ),
    );
  }

  Future<ExhibitionLoadResult> loadP0PaySummary({
    required String taskId,
    bool forceRefresh = false,
  }) {
    return _loadGet(
      ExhibitionCanonicalPaths.p0PaySummary(taskId),
      forceRefresh: forceRefresh,
    );
  }

  Future<P0PayPaymentPollResult> _pollP0PayStatus({
    required P0PayPaymentKind kind,
    required int maxAttempts,
    required Duration interval,
    required Future<ExhibitionLoadResult> Function() loadStatus,
  }) async {
    final boundedAttempts = maxAttempts < 1 ? 1 : maxAttempts;
    ExhibitionLoadResult? lastResult;
    String? lastStatus;

    for (var attempt = 1; attempt <= boundedAttempts; attempt += 1) {
      final result = await loadStatus();
      lastResult = result;
      lastStatus = _p0PayStatusFromLoadResult(kind, result);
      final outcome = _p0PayOutcomeForStatus(kind, result, lastStatus);

      if (outcome != P0PayPaymentOutcome.pending) {
        return P0PayPaymentPollResult(
          kind: kind,
          result: result,
          outcome: outcome,
          status: lastStatus,
          attempts: attempt,
        );
      }

      if (attempt < boundedAttempts && interval > Duration.zero) {
        await Future<void>.delayed(interval);
      }
    }

    return P0PayPaymentPollResult(
      kind: kind,
      result:
          lastResult ??
          ExhibitionLoadResult(
            state: AppPageState.errorRetryable,
            method: 'GET',
            path: 'p0-pay-status',
            errorCode: _p0PayUnavailableErrorCode(kind),
            message: 'P0-Pay status polling did not return a result.',
          ),
      outcome: P0PayPaymentOutcome.timedOut,
      status: lastStatus,
      attempts: boundedAttempts,
      timedOut: true,
    );
  }
}

String? _p0PayStatusFromLoadResult(
  P0PayPaymentKind kind,
  ExhibitionLoadResult result,
) {
  if (result.state != AppPageState.content) {
    return null;
  }

  final payload = _p0PayPayloadMap(result.payload);
  if (payload == null) {
    return null;
  }

  return switch (kind) {
    P0PayPaymentKind.inquiryDeposit =>
      _p0PayReadText(payload['depositStatus']) ??
          _p0PayReadText(payload['status']) ??
          _p0PayReadText(
            _p0PayPayloadMap(payload['channelSummary'])?['status'],
          ),
    P0PayPaymentKind.projectAuthenticitySincerity =>
      _p0PayReadText(payload['orderStatus']) ??
          _p0PayReadText(payload['depositStatus']) ??
          _p0PayReadText(payload['status']) ??
          _p0PayReadText(
            _p0PayPayloadMap(payload['channelSummary'])?['status'],
          ),
    P0PayPaymentKind.serviceFeeAuthorization =>
      _p0PayReadText(payload['authorizationStatus']) ??
          _p0PayReadText(payload['status']) ??
          _p0PayReadText(
            _p0PayPayloadMap(payload['channelSummary'])?['status'],
          ),
  };
}

P0PayPaymentOutcome _p0PayOutcomeForStatus(
  P0PayPaymentKind kind,
  ExhibitionLoadResult result,
  String? status,
) {
  if (result.state != AppPageState.content) {
    return P0PayPaymentOutcome.controlledFailure;
  }

  final normalized = _p0PayReadText(status);
  if (normalized == null) {
    return P0PayPaymentOutcome.unknown;
  }

  return switch (kind) {
    P0PayPaymentKind.inquiryDeposit ||
    P0PayPaymentKind.projectAuthenticitySincerity =>
      _p0PayInquiryDepositOutcome(normalized),
    P0PayPaymentKind.serviceFeeAuthorization =>
      _p0PayServiceFeeAuthorizationOutcome(normalized),
  };
}

P0PayPaymentOutcome _p0PayInquiryDepositOutcome(String status) {
  return switch (status) {
    'pending_payment' || 'pending_user_confirm' => P0PayPaymentOutcome.pending,
    'refund_pending' => P0PayPaymentOutcome.processing,
    'paid' || 'frozen' || 'succeeded' => P0PayPaymentOutcome.success,
    'refunded' => P0PayPaymentOutcome.refunded,
    'deducted' => P0PayPaymentOutcome.deducted,
    'dispute_hold' => P0PayPaymentOutcome.held,
    'failed' => P0PayPaymentOutcome.failed,
    'cancelled' => P0PayPaymentOutcome.cancelled,
    'expired' => P0PayPaymentOutcome.expired,
    _ => P0PayPaymentOutcome.unknown,
  };
}

P0PayPaymentOutcome _p0PayServiceFeeAuthorizationOutcome(String status) {
  return switch (status) {
    'pending_authorization' ||
    'pending_user_confirm' => P0PayPaymentOutcome.pending,
    'refund_pending' || 'release_pending' => P0PayPaymentOutcome.processing,
    'authorized' ||
    'frozen' ||
    'pending_contract_confirm' ||
    'succeeded' => P0PayPaymentOutcome.success,
    'charged' => P0PayPaymentOutcome.charged,
    'authorization_released' || 'released' => P0PayPaymentOutcome.released,
    'refunded' => P0PayPaymentOutcome.refunded,
    'breach_hold' || 'dispute_hold' => P0PayPaymentOutcome.held,
    'failed' => P0PayPaymentOutcome.failed,
    'cancelled' => P0PayPaymentOutcome.cancelled,
    'expired' => P0PayPaymentOutcome.expired,
    _ => P0PayPaymentOutcome.unknown,
  };
}

String _p0PayUnavailableErrorCode(P0PayPaymentKind kind) {
  return switch (kind) {
    P0PayPaymentKind.inquiryDeposit => 'INQUIRY_DEPOSIT_RESULT_UNAVAILABLE',
    P0PayPaymentKind.projectAuthenticitySincerity =>
      'PROJECT_AUTHENTICITY_SINCERITY_RESULT_UNAVAILABLE',
    P0PayPaymentKind.serviceFeeAuthorization =>
      'SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE',
  };
}

Map<String, Object?>? _p0PayPayloadMap(Object? payload) {
  if (payload is Map) {
    return payload.map((Object? key, Object? value) => MapEntry('$key', value));
  }
  return null;
}

String? _p0PayReadText(Object? value) {
  if (value == null) {
    return null;
  }
  final normalized = '$value'.trim();
  return normalized.isEmpty ? null : normalized;
}
