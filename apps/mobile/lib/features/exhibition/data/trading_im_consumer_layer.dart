import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/exhibition/data/trading_im_models.dart';
import 'package:mobile/features/exhibition/data/trading_im_participant_card_models.dart';
import 'package:mobile/features/exhibition/data/trading_im_snapshot_models.dart';

class TradingImResult<T> {
  const TradingImResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;

  bool get isSuccess => state == AppPageState.content;
}

class TradingImConsumerLayer {
  TradingImConsumerLayer._(this._client);

  factory TradingImConsumerLayer({AppApiClient? client}) {
    return TradingImConsumerLayer._(client ?? AppApiClient());
  }

  static TradingImConsumerLayer _instance = TradingImConsumerLayer();

  static TradingImConsumerLayer get instance => _instance;

  static void install(TradingImConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = TradingImConsumerLayer();
  }

  final AppApiClient _client;

  Future<TradingImResult<ProjectClarificationListView>> loadClarifications({
    required String? projectId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    if (normalizedProjectId == null) {
      return Future<TradingImResult<ProjectClarificationListView>>.value(
        const TradingImResult<ProjectClarificationListView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: TradingImCanonicalPaths.projectClarificationList,
          message: 'projectId is required before loading project clarification',
        ),
      );
    }
    return _get(
      TradingImCanonicalPaths.projectClarificationList,
      queryParameters: <String, String>{'projectId': normalizedProjectId},
      parser: parseProjectClarificationList,
    );
  }

  Future<TradingImResult<ProjectClarificationItemView>> createClarification({
    required String? projectId,
    required String body,
    required List<String> attachmentFileAssetIds,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedBody = body.trim();
    if (normalizedProjectId == null || normalizedBody.isEmpty) {
      return Future<TradingImResult<ProjectClarificationItemView>>.value(
        const TradingImResult<ProjectClarificationItemView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: TradingImCanonicalPaths.projectClarificationCreate,
          message:
              'projectId and body are required before creating clarification',
        ),
      );
    }
    return _post(
      TradingImCanonicalPaths.projectClarificationCreate,
      body: <String, Object?>{
        'projectId': normalizedProjectId,
        'body': normalizedBody,
        'attachmentFileAssetIds': _normalizedIds(attachmentFileAssetIds),
      },
      parser: parseProjectClarificationItem,
    );
  }

  Future<TradingImResult<BidThreadDetailView>> loadBidThread({
    required String? projectId,
    required String? bidId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedBidId = _normalize(bidId);
    if (normalizedProjectId == null || normalizedBidId == null) {
      return Future<TradingImResult<BidThreadDetailView>>.value(
        const TradingImResult<BidThreadDetailView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: TradingImCanonicalPaths.bidThreadDetail,
          message: 'projectId and bidId are required before loading bid thread',
        ),
      );
    }
    return _get(
      TradingImCanonicalPaths.bidThreadDetail,
      queryParameters: <String, String>{
        'projectId': normalizedProjectId,
        'bidId': normalizedBidId,
      },
      parser: parseBidThreadDetail,
    );
  }

  Future<TradingImResult<BidSubmissionSnapshotView>> loadBidSubmissionSnapshot({
    required String? projectId,
    required String? bidId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedBidId = _normalize(bidId);
    if (normalizedProjectId == null || normalizedBidId == null) {
      return Future<TradingImResult<BidSubmissionSnapshotView>>.value(
        const TradingImResult<BidSubmissionSnapshotView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: TradingImCanonicalPaths.bidSubmissionSnapshot,
          message:
              'projectId and bidId are required before loading bid submission snapshot',
        ),
      );
    }
    return _get(
      TradingImCanonicalPaths.bidSubmissionSnapshot,
      queryParameters: <String, String>{
        'projectId': normalizedProjectId,
        'bidId': normalizedBidId,
      },
      parser: parseBidSubmissionSnapshot,
    );
  }

  Future<TradingImResult<TradingImParticipantCardView>> loadParticipantCard({
    required String? projectId,
    required String? bidId,
    required String? participantOrganizationId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedBidId = _normalize(bidId);
    final normalizedParticipantOrganizationId =
        _normalize(participantOrganizationId);
    if (normalizedProjectId == null ||
        normalizedBidId == null ||
        normalizedParticipantOrganizationId == null) {
      return Future<TradingImResult<TradingImParticipantCardView>>.value(
        const TradingImResult<TradingImParticipantCardView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: TradingImCanonicalPaths.participantCard,
          message:
              'projectId, bidId, and participantOrganizationId are required before loading participant-card',
        ),
      );
    }
    return _get(
      TradingImCanonicalPaths.participantCard,
      queryParameters: <String, String>{
        'projectId': normalizedProjectId,
        'bidId': normalizedBidId,
        'participantOrganizationId': normalizedParticipantOrganizationId,
      },
      parser: parseTradingImParticipantCard,
    );
  }

  Future<TradingImResult<BidThreadMessageView>> sendBidThreadMessage({
    required String? projectId,
    required String? bidId,
    required String body,
    required List<String> attachmentFileAssetIds,
  }) {
    final command = _threadCommand(
      projectId: projectId,
      bidId: bidId,
      body: body,
    );
    if (command == null) {
      return Future<TradingImResult<BidThreadMessageView>>.value(
        const TradingImResult<BidThreadMessageView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: TradingImCanonicalPaths.bidThreadMessageSend,
          message:
              'projectId, bidId, and body are required before thread command',
        ),
      );
    }
    return _post(
      TradingImCanonicalPaths.bidThreadMessageSend,
      body: <String, Object?>{
        ...command.toJson(),
        'attachmentFileAssetIds': _normalizedIds(attachmentFileAssetIds),
      },
      parser: parseBidThreadMessage,
    );
  }

  Future<TradingImResult<ConfirmationCardView>> createConfirmationCard({
    required String? projectId,
    required String? bidId,
    required String confirmationType,
    required String summary,
    required String sourceMessageId,
  }) {
    final command = _threadCommand(
      projectId: projectId,
      bidId: bidId,
      body: summary,
    );
    if (command == null) {
      return Future<TradingImResult<ConfirmationCardView>>.value(
        const TradingImResult<ConfirmationCardView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: TradingImCanonicalPaths.bidThreadConfirmationCreate,
          message: 'projectId, bidId, and summary are required',
        ),
      );
    }
    final normalizedType = _normalize(confirmationType);
    final normalizedSourceMessageId = _normalize(sourceMessageId);
    if (normalizedType == null || normalizedSourceMessageId == null) {
      return Future<TradingImResult<ConfirmationCardView>>.value(
        const TradingImResult<ConfirmationCardView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: TradingImCanonicalPaths.bidThreadConfirmationCreate,
          message: 'confirmationType and sourceMessageId are required',
        ),
      );
    }
    return _post(
      TradingImCanonicalPaths.bidThreadConfirmationCreate,
      body: <String, Object?>{
        ...command.toJson(),
        'confirmationType': normalizedType,
        'summary': summary.trim(),
        'sourceMessageId': normalizedSourceMessageId,
      },
      parser: parseConfirmationCard,
    );
  }

  Future<TradingImResult<T>> _get<T>(
    String canonicalPath, {
    required Map<String, String> queryParameters,
    required T Function(Object? payload) parser,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(canonicalPath, queryParameters: queryParameters),
      );
      return _mapResponse(response, canonicalPath, 'GET', parser);
    } on SocketException catch (error) {
      return _transportFailure(canonicalPath, 'GET', error.message);
    } on HttpException {
      return _transportFailure(
        canonicalPath,
        'GET',
        'http error while requesting canonical BFF path',
      );
    } on StateError {
      return _transportFailure(
        canonicalPath,
        'GET',
        'current fake transport did not provide this canonical path',
      );
    } on FormatException catch (error) {
      return _formatFailure(canonicalPath, 'GET', error.message);
    }
  }

  Future<TradingImResult<T>> _post<T>(
    String canonicalPath, {
    required Object body,
    required T Function(Object? payload) parser,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(canonicalPath, body: body),
      );
      return _mapResponse(response, canonicalPath, 'POST', parser);
    } on SocketException catch (error) {
      return _transportFailure(canonicalPath, 'POST', error.message);
    } on HttpException {
      return _transportFailure(
        canonicalPath,
        'POST',
        'http error while submitting to canonical BFF path',
      );
    } on StateError {
      return _transportFailure(
        canonicalPath,
        'POST',
        'current fake transport did not provide this canonical path',
      );
    } on FormatException catch (error) {
      return _formatFailure(canonicalPath, 'POST', error.message);
    }
  }

  TradingImResult<T> _mapResponse<T>(
    AppApiResponse response,
    String canonicalPath,
    String method,
    T Function(Object? payload) parser,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return TradingImResult<T>(
        state: _failureState(response.statusCode),
        method: method,
        path: canonicalPath,
        message: _message(response.body) ?? 'canonical BFF request failed',
        errorCode: _errorCode(response.body),
      );
    }
    return TradingImResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: parser(response.body),
    );
  }
}

class _ThreadCommand {
  const _ThreadCommand({
    required this.projectId,
    required this.bidId,
    required this.body,
  });

  final String projectId;
  final String bidId;
  final String body;

  Map<String, Object?> toJson() => <String, Object?>{
    'projectId': projectId,
    'bidId': bidId,
    'body': body,
  };
}

_ThreadCommand? _threadCommand({
  required String? projectId,
  required String? bidId,
  required String body,
}) {
  final normalizedProjectId = _normalize(projectId);
  final normalizedBidId = _normalize(bidId);
  final normalizedBody = body.trim();
  if (normalizedProjectId == null ||
      normalizedBidId == null ||
      normalizedBody.isEmpty) {
    return null;
  }
  return _ThreadCommand(
    projectId: normalizedProjectId,
    bidId: normalizedBidId,
    body: normalizedBody,
  );
}

TradingImResult<T> _transportFailure<T>(
  String path,
  String method,
  String message,
) {
  return TradingImResult<T>(
    state: AppPageState.errorRetryable,
    method: method,
    path: path,
    message: message,
  );
}

TradingImResult<T> _formatFailure<T>(
  String path,
  String method,
  String message,
) {
  return TradingImResult<T>(
    state: AppPageState.errorNonRetryable,
    method: method,
    path: path,
    message: message,
  );
}

AppPageState _failureState(int statusCode) {
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

String? _message(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  final value = '${payload['message'] ?? ''}'.trim();
  return value.isEmpty ? null : value;
}

String? _errorCode(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  final value = '${payload['code'] ?? payload['errorCode'] ?? ''}'.trim();
  return value.isEmpty ? null : value;
}

String? _normalize(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

List<String> _normalizedIds(List<String> values) {
  return values
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);
}
