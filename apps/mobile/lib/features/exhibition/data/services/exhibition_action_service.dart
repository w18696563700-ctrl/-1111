part of '../exhibition_consumer_layer.dart';

class _ExhibitionActionService {
  const _ExhibitionActionService(this._client);

  final AppApiClient _client;

  Future<ExhibitionActionResult> createProject(ProjectCreateCommand command) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectCreate,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> saveProject(ProjectSaveCommand command) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectSave,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitProject(
    ProjectLifecycleActionCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectSubmit,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> publishProject(
    ProjectLifecycleActionCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectPublish,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> withdrawProject(
    ProjectLifecycleActionCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectWithdraw,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> archiveProject(
    ProjectLifecycleActionCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectArchive,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> closeProject(
    ProjectLifecycleActionCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectClose,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> deleteMyProject({
    required String projectId,
  }) async {
    final canonicalPath = ExhibitionCanonicalPaths.myProjectDetail(projectId);
    try {
      final response = await runProtectedAppRequest(
        () => _client.delete(canonicalPath),
      );
      return _mapActionResponse(
        response,
        canonicalPath,
        requestMethod: 'DELETE',
      );
    } on SocketException {
      return ExhibitionActionResult(
        method: 'DELETE',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'network error while submitting to canonical BFF path',
      );
    } on HttpException {
      return ExhibitionActionResult(
        method: 'DELETE',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'http error while submitting to canonical BFF path',
      );
    } on FormatException {
      return ExhibitionActionResult(
        method: 'DELETE',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorNonRetryable,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  Future<ExhibitionActionResult> submitExhibitionReport(
    ExhibitionReportSubmitCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.exhibitionReportSubmit,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitBid(BidSubmitCommand command) {
    return _submit(ExhibitionCanonicalPaths.bidSubmit, body: command.toJson());
  }

  Future<ExhibitionActionResult> supplementBidSubmission(
    BidSubmissionSupplementCommand command,
  ) {
    return _submit(
      ExhibitionCanonicalPaths.bidSubmissionSupplement,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> lockBidSeat({
    required String projectId,
    required String bidId,
  }) {
    return _submitProtected(
      _bidSeatLockPath,
      body: <String, Object?>{'projectId': projectId, 'bidId': bidId},
    );
  }

  Future<ExhibitionActionResult> releaseBidSeat({
    required String projectId,
    required String bidId,
  }) {
    return _submitProtected(
      _bidSeatReleasePath,
      body: <String, Object?>{'projectId': projectId, 'bidId': bidId},
    );
  }

  Future<ExhibitionActionResult> awardBid(BidAwardCommand command) {
    return _submitProtected(
      ExhibitionCanonicalPaths.bidAward,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> selectBidAndCreateOrder(
    BidSelectAndCreateOrderCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.bidSelectAndCreateOrder,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> confirmContract(
    ContractConfirmCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.contractConfirm,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> amendContract(ContractAmendCommand command) {
    return _submitProtected(
      ExhibitionCanonicalPaths.contractAmend,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> requestOrderCompletion(
    OrderCompletionRequestCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.orderCompleteRequest,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> confirmOrderCompletion(
    OrderCompletionConfirmCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.orderCompleteConfirm,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> rejectOrderCompletion(
    OrderCompletionRejectCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.orderCompleteReject,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitMilestone(
    MilestoneSubmitCommand command,
  ) {
    return _submit(
      ExhibitionCanonicalPaths.milestoneSubmit,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitInspection(
    InspectionSubmitCommand command,
  ) {
    return _submit(
      ExhibitionCanonicalPaths.inspectionSubmit,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> recheckInspection(
    InspectionRecheckCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.inspectionRecheck,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> openDispute(DisputeOpenCommand command) {
    return _submit(
      ExhibitionCanonicalPaths.disputeOpen,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitRating(RatingSubmitCommand command) {
    return _submitProtected(
      ExhibitionCanonicalPaths.ratingSubmit,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitProjectCounterpartyRating(
    ProjectCounterpartyRatingSubmitCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.projectCounterpartyRatingSubmit,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> withdrawDispute(
    DisputeWithdrawCommand command,
  ) {
    return _submitProtected(
      ExhibitionCanonicalPaths.disputeWithdraw,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> _submit(
    String canonicalPath, {
    required Object body,
  }) async {
    try {
      final response = await _client.post(canonicalPath, body: body);
      return _mapActionResponse(response, canonicalPath, requestMethod: 'POST');
    } on SocketException {
      return ExhibitionActionResult(
        method: 'POST',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'network error while submitting to canonical BFF path',
      );
    } on HttpException {
      return ExhibitionActionResult(
        method: 'POST',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'http error while submitting to canonical BFF path',
      );
    } on FormatException {
      return ExhibitionActionResult(
        method: 'POST',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorNonRetryable,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  Future<ExhibitionActionResult> _submitProtected(
    String canonicalPath, {
    required Object body,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(canonicalPath, body: body),
      );
      return _mapActionResponse(response, canonicalPath, requestMethod: 'POST');
    } on SocketException {
      return ExhibitionActionResult(
        method: 'POST',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'network error while submitting to canonical BFF path',
      );
    } on HttpException {
      return ExhibitionActionResult(
        method: 'POST',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'http error while submitting to canonical BFF path',
      );
    } on FormatException {
      return ExhibitionActionResult(
        method: 'POST',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorNonRetryable,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  ExhibitionActionResult _mapActionResponse(
    AppApiResponse response,
    String canonicalPath, {
    required String requestMethod,
  }) {
    final payload = response.body;
    if (kDebugMode) {
      final payloadPreview = switch (payload) {
        null => 'null',
        final Object value => jsonEncode(value),
      };
      debugPrint(
        '[exhibition-action] $requestMethod $canonicalPath status=${response.statusCode} payload=${payloadPreview.length > 600 ? '${payloadPreview.substring(0, 600)}...(truncated)' : payloadPreview}',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final validation = _sanitizeAndValidateSuccessPayload(
        requestMethod,
        canonicalPath,
        payload,
      );
      if (!validation.isValid) {
        if (kDebugMode) {
          debugPrint(
            '[exhibition-action] validation failed path=$canonicalPath message="${validation.message}" payload=${validation.payload}',
          );
        }
        return ExhibitionActionResult(
          method: requestMethod,
          path: canonicalPath,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          payload: validation.payload,
          message: validation.message,
        );
      }

      return ExhibitionActionResult(
        method: requestMethod,
        path: canonicalPath,
        isSuccess: true,
        payload: validation.payload,
        message: 'canonical BFF submission succeeded',
      );
    }

    final failurePayload = _sanitizeFailurePayload(payload);
    if (kDebugMode) {
      debugPrint(
        '[exhibition-action] request failed path=$canonicalPath state=${_mapHttpFailureState(response.statusCode)} errorCode=${_extractErrorCode(failurePayload)}',
      );
    }

    return ExhibitionActionResult(
      method: requestMethod,
      path: canonicalPath,
      isSuccess: false,
      controlledState: _mapHttpFailureState(response.statusCode),
      payload: failurePayload,
      errorCode: _extractErrorCode(failurePayload),
      message: _failureMessage(payload, 'canonical BFF submission failed'),
    );
  }

  String _idempotencyKey(String action) {
    return '$action-${DateTime.now().microsecondsSinceEpoch}';
  }

  AppPageState _mapHttpFailureState(int statusCode) {
    if (statusCode == 401) {
      return AppPageState.unauthorized;
    }
    if (statusCode == 403) {
      return AppPageState.forbidden;
    }
    if (statusCode == 404) {
      return AppPageState.notFound;
    }
    if (statusCode >= 500) {
      return AppPageState.errorRetryable;
    }
    return AppPageState.errorNonRetryable;
  }
}
