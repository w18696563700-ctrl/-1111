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

  Future<ExhibitionActionResult> submitBid(BidSubmitCommand command) {
    return _submit(ExhibitionCanonicalPaths.bidSubmit, body: command.toJson());
  }

  Future<ExhibitionActionResult> createOrder(OrderCreateCommand command) {
    return _submit(
      ExhibitionCanonicalPaths.orderCreate,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> confirmContract(
    ContractConfirmCommand command,
  ) {
    return _submit(
      ExhibitionCanonicalPaths.contractConfirm,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> amendContract(ContractAmendCommand command) {
    return _submit(
      ExhibitionCanonicalPaths.contractAmend,
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
    return _submit(
      ExhibitionCanonicalPaths.inspectionRecheck,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> submitRating(RatingSubmitCommand command) {
    return _submit(
      ExhibitionCanonicalPaths.ratingSubmit,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> openDispute(DisputeOpenCommand command) {
    return _submit(
      ExhibitionCanonicalPaths.disputeOpen,
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> withdrawDispute(
    DisputeWithdrawCommand command,
  ) {
    return _submit(
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
      return _mapActionResponse(response, canonicalPath);
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
      return _mapActionResponse(response, canonicalPath);
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
    String canonicalPath,
  ) {
    final payload = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final validation =
          canonicalPath == ExhibitionCanonicalPaths.inspectionRecheck
              ? _sanitizeAndValidateEntryPayload(canonicalPath, payload)
              : _sanitizeAndValidateSuccessPayload(canonicalPath, payload);
      if (!validation.isValid) {
        return ExhibitionActionResult(
          method: 'POST',
          path: canonicalPath,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          payload: validation.payload,
          message: validation.message,
        );
      }

      return ExhibitionActionResult(
        method: 'POST',
        path: canonicalPath,
        isSuccess: true,
        payload: validation.payload,
        message: 'canonical BFF submission succeeded',
      );
    }

    final failurePayload = _sanitizeFailurePayload(payload);

    return ExhibitionActionResult(
      method: 'POST',
      path: canonicalPath,
      isSuccess: false,
      controlledState: _mapHttpFailureState(response.statusCode),
      payload: failurePayload,
      errorCode: _extractErrorCode(failurePayload),
      message: _failureMessage(payload, 'canonical BFF submission failed'),
    );
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
