import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';

final class ProjectNameAccessCanonicalPaths {
  const ProjectNameAccessCanonicalPaths._();

  static const String request = '/api/app/project/name-access/request';
  static const String threadDetail =
      '/api/app/project/name-access/thread/detail';
  static const String pendingPattern =
      '/api/app/my/projects/{projectId}/name-access/pending';
  static const String approvePattern =
      '/api/app/my/projects/{projectId}/name-access/{requestId}/approve';
  static const String rejectPattern =
      '/api/app/my/projects/{projectId}/name-access/{requestId}/reject';
}

class ProjectNameAccessResult<T> {
  const ProjectNameAccessResult({
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

final class ProjectNameAccessRequestAcceptedView {
  const ProjectNameAccessRequestAcceptedView({
    required this.requestId,
    required this.projectId,
    required this.status,
    required this.threadId,
  });

  final String requestId;
  final String projectId;
  final String status;
  final String threadId;
}

final class ProjectNameAccessDecisionView {
  const ProjectNameAccessDecisionView({
    required this.requestId,
    required this.projectId,
    required this.status,
  });

  final String requestId;
  final String projectId;
  final String status;
}

final class ProjectNameAccessRequesterOrganizationView {
  const ProjectNameAccessRequesterOrganizationView({
    required this.organizationId,
    required this.displayName,
    required this.avatarUrl,
  });

  final String organizationId;
  final String displayName;
  final String? avatarUrl;
}

final class ProjectNameAccessPendingItemView {
  const ProjectNameAccessPendingItemView({
    required this.requestId,
    required this.requesterOrganization,
    required this.requestedAt,
    required this.status,
    required this.threadId,
  });

  final String requestId;
  final ProjectNameAccessRequesterOrganizationView requesterOrganization;
  final String requestedAt;
  final String status;
  final String threadId;
}

final class ProjectNameAccessPendingListView {
  const ProjectNameAccessPendingListView({
    required this.projectId,
    required this.items,
  });

  final String projectId;
  final List<ProjectNameAccessPendingItemView> items;
}

final class ProjectNameAccessThreadItemActionView {
  const ProjectNameAccessThreadItemActionView({
    required this.actionKey,
    required this.objectType,
    required this.canonicalPath,
    required this.label,
    required this.params,
  });

  final String actionKey;
  final String? objectType;
  final String? canonicalPath;
  final String? label;
  final Map<String, String> params;
}

final class ProjectNameAccessThreadItemView {
  const ProjectNameAccessThreadItemView({
    required this.itemId,
    required this.itemKind,
    required this.title,
    required this.summary,
    required this.createdAt,
    required this.action,
  });

  final String itemId;
  final String itemKind;
  final String title;
  final String summary;
  final String createdAt;
  final ProjectNameAccessThreadItemActionView? action;
}

final class ProjectNameAccessPrimaryReviewActionView {
  const ProjectNameAccessPrimaryReviewActionView({
    required this.actionKey,
    required this.enabled,
    required this.availableDecisions,
  });

  final String actionKey;
  final bool enabled;
  final List<String> availableDecisions;
}

final class ProjectNameAccessThreadDetailView {
  const ProjectNameAccessThreadDetailView({
    required this.threadId,
    required this.threadType,
    required this.projectId,
    required this.requestId,
    required this.requestStatus,
    required this.displayTitle,
    required this.items,
    required this.primaryReviewAction,
  });

  final String threadId;
  final String threadType;
  final String projectId;
  final String requestId;
  final String requestStatus;
  final String displayTitle;
  final List<ProjectNameAccessThreadItemView> items;
  final ProjectNameAccessPrimaryReviewActionView? primaryReviewAction;
}

class ProjectNameAccessConsumerLayer {
  ProjectNameAccessConsumerLayer._(this._client);

  factory ProjectNameAccessConsumerLayer({AppApiClient? client}) {
    return ProjectNameAccessConsumerLayer._(client ?? AppApiClient());
  }

  static ProjectNameAccessConsumerLayer _instance =
      ProjectNameAccessConsumerLayer();

  static ProjectNameAccessConsumerLayer get instance => _instance;

  static void install(ProjectNameAccessConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProjectNameAccessConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProjectNameAccessResult<ProjectNameAccessRequestAcceptedView>>
  requestAccess({required String? projectId}) {
    final normalizedProjectId = _normalize(projectId);
    if (normalizedProjectId == null) {
      return Future.value(
        const ProjectNameAccessResult<ProjectNameAccessRequestAcceptedView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: ProjectNameAccessCanonicalPaths.request,
          message:
              'projectId is required before requesting project name access',
        ),
      );
    }
    return _post(
      ProjectNameAccessCanonicalPaths.request,
      body: <String, Object?>{'projectId': normalizedProjectId},
      parser: _parseRequestAccepted,
    );
  }

  Future<ProjectNameAccessResult<ProjectNameAccessThreadDetailView>>
  loadThreadDetail({required String? threadId}) {
    final normalizedThreadId = _normalize(threadId);
    if (normalizedThreadId == null) {
      return Future.value(
        const ProjectNameAccessResult<ProjectNameAccessThreadDetailView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: ProjectNameAccessCanonicalPaths.threadDetail,
          message:
              'threadId is required before loading project name access thread',
        ),
      );
    }
    return _get(
      ProjectNameAccessCanonicalPaths.threadDetail,
      queryParameters: <String, String>{'threadId': normalizedThreadId},
      parser: _parseThreadDetail,
    );
  }

  Future<ProjectNameAccessResult<ProjectNameAccessPendingListView>>
  loadPendingRequests({required String? projectId}) {
    final normalizedProjectId = _normalize(projectId);
    if (normalizedProjectId == null) {
      return Future.value(
        const ProjectNameAccessResult<ProjectNameAccessPendingListView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: ProjectNameAccessCanonicalPaths.pendingPattern,
          message:
              'projectId is required before loading project name access pending items',
        ),
      );
    }
    return _get(
      _pendingPath(normalizedProjectId),
      queryParameters: const <String, String>{},
      parser: _parsePendingList,
    );
  }

  Future<ProjectNameAccessResult<ProjectNameAccessDecisionView>>
  approveRequest({required String? projectId, required String? requestId}) {
    return _submitDecision(
      decision: 'approve',
      projectId: projectId,
      requestId: requestId,
      successStatus: 'approved',
    );
  }

  Future<ProjectNameAccessResult<ProjectNameAccessDecisionView>> rejectRequest({
    required String? projectId,
    required String? requestId,
  }) {
    return _submitDecision(
      decision: 'reject',
      projectId: projectId,
      requestId: requestId,
      successStatus: 'rejected',
    );
  }

  Future<ProjectNameAccessResult<ProjectNameAccessDecisionView>>
  _submitDecision({
    required String decision,
    required String? projectId,
    required String? requestId,
    required String successStatus,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedRequestId = _normalize(requestId);
    final canonicalPath = _decisionPath(
      projectId: projectId,
      requestId: requestId,
      decision: decision,
    );
    if (normalizedProjectId == null || normalizedRequestId == null) {
      return Future.value(
        ProjectNameAccessResult<ProjectNameAccessDecisionView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: canonicalPath,
          message:
              'projectId and requestId are required before reviewing project name access',
        ),
      );
    }
    return _post(
      _decisionPath(
        projectId: normalizedProjectId,
        requestId: normalizedRequestId,
        decision: decision,
      ),
      body: const <String, Object?>{},
      parser: (Object? payload) =>
          _parseDecision(payload, expectedStatus: successStatus),
    );
  }

  Future<ProjectNameAccessResult<T>> _get<T>(
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
        'http error while requesting project name access',
      );
    } on StateError {
      return _transportFailure(
        canonicalPath,
        'GET',
        'current fake transport did not provide this project name access path',
      );
    } on FormatException catch (error) {
      return _formatFailure(canonicalPath, 'GET', error.message);
    }
  }

  Future<ProjectNameAccessResult<T>> _post<T>(
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
        'http error while submitting project name access',
      );
    } on StateError {
      return _transportFailure(
        canonicalPath,
        'POST',
        'current fake transport did not provide this project name access path',
      );
    } on FormatException catch (error) {
      return _formatFailure(canonicalPath, 'POST', error.message);
    }
  }

  ProjectNameAccessResult<T> _mapResponse<T>(
    AppApiResponse response,
    String canonicalPath,
    String method,
    T Function(Object? payload) parser,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProjectNameAccessResult<T>(
        state: _failureState(response.statusCode),
        method: method,
        path: canonicalPath,
        message:
            _message(response.body) ?? 'project name access request failed',
        errorCode: _errorCode(response.body),
      );
    }

    return ProjectNameAccessResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: parser(response.body),
    );
  }

  ProjectNameAccessResult<T> _transportFailure<T>(
    String path,
    String method,
    String message,
  ) {
    return ProjectNameAccessResult<T>(
      state: AppPageState.errorRetryable,
      method: method,
      path: path,
      message: message,
    );
  }

  ProjectNameAccessResult<T> _formatFailure<T>(
    String path,
    String method,
    String message,
  ) {
    return ProjectNameAccessResult<T>(
      state: AppPageState.errorNonRetryable,
      method: method,
      path: path,
      message: message,
    );
  }

  static String _pendingPath(String projectId) =>
      '/api/app/my/projects/${Uri.encodeComponent(projectId)}/name-access/pending';

  static String _decisionPath({
    required String? projectId,
    required String? requestId,
    required String decision,
  }) {
    final resolvedProjectId = Uri.encodeComponent(projectId ?? '{projectId}');
    final resolvedRequestId = Uri.encodeComponent(requestId ?? '{requestId}');
    return '/api/app/my/projects/$resolvedProjectId/name-access/$resolvedRequestId/$decision';
  }
}

ProjectNameAccessRequestAcceptedView _parseRequestAccepted(Object? payload) {
  final map = _requiredMap(payload, 'project name access request');
  final status = _enumValue(_requiredString(map, 'status'), const <String>{
    'pending',
  }, 'project name access request status');
  return ProjectNameAccessRequestAcceptedView(
    requestId: _requiredString(map, 'requestId'),
    projectId: _requiredString(map, 'projectId'),
    status: status,
    threadId: _requiredString(map, 'threadId'),
  );
}

ProjectNameAccessPendingListView _parsePendingList(Object? payload) {
  final map = _requiredMap(payload, 'project name access pending list');
  final rawItems = _requiredList(map, 'items');
  return ProjectNameAccessPendingListView(
    projectId: _requiredString(map, 'projectId'),
    items: rawItems
        .map<ProjectNameAccessPendingItemView>(_parsePendingItem)
        .toList(growable: false),
  );
}

ProjectNameAccessPendingItemView _parsePendingItem(Object? payload) {
  final map = _requiredMap(payload, 'project name access pending item');
  final requesterOrganization = _requiredMap(
    map['requesterOrganization'],
    'project name access requester organization',
  );
  return ProjectNameAccessPendingItemView(
    requestId: _requiredString(map, 'requestId'),
    requesterOrganization: ProjectNameAccessRequesterOrganizationView(
      organizationId: _requiredString(requesterOrganization, 'organizationId'),
      displayName: _requiredString(requesterOrganization, 'displayName'),
      avatarUrl: _nullableString(requesterOrganization['avatarUrl']),
    ),
    requestedAt: _requiredString(map, 'requestedAt'),
    status: _requestStatus(map['status']),
    threadId: _requiredString(map, 'threadId'),
  );
}

ProjectNameAccessDecisionView _parseDecision(
  Object? payload, {
  required String expectedStatus,
}) {
  final map = _requiredMap(payload, 'project name access decision');
  final status = _enumValue(_requiredString(map, 'status'), const <String>{
    'approved',
    'rejected',
  }, 'project name access decision status');
  if (status != expectedStatus) {
    throw FormatException(
      'project name access decision returned unsupported status "$status"',
    );
  }
  return ProjectNameAccessDecisionView(
    requestId: _requiredString(map, 'requestId'),
    projectId: _requiredString(map, 'projectId'),
    status: status,
  );
}

ProjectNameAccessThreadDetailView _parseThreadDetail(Object? payload) {
  final map = _requiredMap(payload, 'project name access thread');
  final rawItems = _requiredList(map, 'items');
  return ProjectNameAccessThreadDetailView(
    threadId: _requiredString(map, 'threadId'),
    threadType: _enumValue(_requiredString(map, 'threadType'), const <String>{
      'project_name_access_review',
    }, 'project name access thread type'),
    projectId: _requiredString(map, 'projectId'),
    requestId: _requiredString(map, 'requestId'),
    requestStatus: _requestStatus(map['requestStatus']),
    displayTitle: _requiredString(map, 'displayTitle'),
    items: rawItems
        .map<ProjectNameAccessThreadItemView>(_parseThreadItem)
        .toList(growable: false),
    primaryReviewAction: _parsePrimaryReviewAction(map['primaryReviewAction']),
  );
}

ProjectNameAccessThreadItemView _parseThreadItem(Object? payload) {
  final map = _requiredMap(payload, 'project name access thread item');
  return ProjectNameAccessThreadItemView(
    itemId: _requiredString(map, 'itemId'),
    itemKind: _enumValue(_requiredString(map, 'itemKind'), const <String>{
      'system_seed',
      'system_notice',
    }, 'project name access item kind'),
    title: _requiredString(map, 'title'),
    summary: _requiredString(map, 'summary'),
    createdAt: _requiredString(map, 'createdAt'),
    action: _parseThreadItemAction(map['action']),
  );
}

ProjectNameAccessThreadItemActionView? _parseThreadItemAction(Object? payload) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload, 'project name access thread item action');
  return ProjectNameAccessThreadItemActionView(
    actionKey: _enumValue(_requiredString(map, 'actionKey'), const <String>{
      'project_name_access.review',
      'project_name_access.refresh',
    }, 'project name access item action key'),
    objectType: _nullableString(map['objectType']),
    canonicalPath: _nullableString(map['canonicalPath']),
    label: _nullableString(map['label']),
    params: _stringMap(map['params']),
  );
}

ProjectNameAccessPrimaryReviewActionView? _parsePrimaryReviewAction(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(
    payload,
    'project name access primary review action',
  );
  final decisions = _requiredList(map, 'availableDecisions')
      .map<String>(
        (Object? item) => _enumValue(
          _requiredStringValue(item, 'availableDecisions item'),
          const <String>{'approve', 'reject'},
          'project name access review decision',
        ),
      )
      .toList(growable: false);
  return ProjectNameAccessPrimaryReviewActionView(
    actionKey: _enumValue(
      _requiredString(map, 'actionKey'),
      const <String>{'project_name_access.review'},
      'project name access primary review action key',
    ),
    enabled: _requiredBool(map, 'enabled'),
    availableDecisions: decisions,
  );
}

String _requestStatus(Object? value) => _enumValue(
  _requiredStringValue(value, 'project name access status'),
  const <String>{'pending', 'approved', 'rejected'},
  'project name access status',
);

Map<String, Object?> _requiredMap(Object? payload, String context) {
  if (payload is! Map) {
    throw FormatException('$context response must be an object');
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

List<Object?> _requiredList(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is! List) {
    throw FormatException('field "$field" must be an array');
  }
  return value.cast<Object?>();
}

String _requiredString(Map<String, Object?> payload, String field) {
  return _requiredStringValue(payload[field], field);
}

String _requiredStringValue(Object? value, String field) {
  if (value is! String) {
    throw FormatException('field "$field" must be a string');
  }
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw FormatException('field "$field" must be a non-empty string');
  }
  return normalized;
}

String _enumValue(String value, Set<String> allowed, String context) {
  if (!allowed.contains(value)) {
    throw FormatException('$context returned unsupported value "$value"');
  }
  return value;
}

Map<String, String> _stringMap(Object? payload) {
  if (payload == null) {
    return const <String, String>{};
  }
  if (payload is! Map) {
    throw const FormatException('action params must be an object');
  }
  final result = <String, String>{};
  for (final MapEntry<Object?, Object?> entry in payload.entries) {
    final key = '${entry.key}'.trim();
    final value = _requiredStringValue(entry.value, 'action params');
    if (key.isEmpty) {
      throw const FormatException('action params key must be non-empty');
    }
    result[key] = value;
  }
  return result;
}

String? _nullableString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw const FormatException('nullable field must be a string');
  }
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

bool _requiredBool(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is bool) {
    return value;
  }
  throw FormatException('field "$field" must be a bool');
}

String? _normalize(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
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
  if (payload is Map) {
    final value = payload['message'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _errorCode(Object? payload) {
  if (payload is Map) {
    final value = payload['code'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
