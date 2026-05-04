part of '../exhibition_consumer_layer.dart';

class _ExhibitionLoadService {
  _ExhibitionLoadService(this._client);

  final AppApiClient _client;
  final Map<String, ExhibitionLoadResult> _successCache =
      <String, ExhibitionLoadResult>{};
  final Map<String, Future<ExhibitionLoadResult>> _inFlightLoads =
      <String, Future<ExhibitionLoadResult>>{};

  static const Set<String> _sessionCachedPaths = <String>{
    ExhibitionCanonicalPaths.projectList,
    ExhibitionCanonicalPaths.myProjectList,
    ExhibitionCanonicalPaths.projectEditDetail,
    ExhibitionCanonicalPaths.projectDetail,
    ExhibitionCanonicalPaths.projectBidMaterials,
    ExhibitionCanonicalPaths.orderDetail,
    ExhibitionCanonicalPaths.milestoneList,
    ExhibitionCanonicalPaths.contractDetail,
    ExhibitionCanonicalPaths.inspectionDetail,
    ExhibitionCanonicalPaths.ratingEntry,
    ExhibitionCanonicalPaths.projectCounterpartyRatingEntry,
    ExhibitionCanonicalPaths.bidResult,
    ExhibitionCanonicalPaths.projectPublicResources,
  };

  Future<ExhibitionLoadResult> loadProjectList({
    bool forceRefresh = false,
    String? provinceCode,
    String? cityCode,
    String? areaBucket,
    String? budgetBucket,
  }) async {
    final queryParameters = <String, String>{
      if (_normalize(provinceCode) case final String value)
        'provinceCode': value,
      if (_normalize(cityCode) case final String value) 'cityCode': value,
      if (_normalize(areaBucket) case final String value) 'areaBucket': value,
      if (_normalize(budgetBucket) case final String value)
        'budgetBucket': value,
    };
    return _loadGet(
      ExhibitionCanonicalPaths.projectList,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadMyProjectList({
    bool forceRefresh = false,
  }) async {
    return _loadGet(
      ExhibitionCanonicalPaths.myProjectList,
      forceRefresh: forceRefresh,
    );
  }

  void invalidateMyProjectList() {
    _invalidateCachedGet(ExhibitionCanonicalPaths.myProjectList);
  }

  Future<ExhibitionLoadResult> loadProjectDetail({
    required String? projectId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.projectDetail,
        queryName: 'projectId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.projectDetail,
      queryParameters: <String, String>{'projectId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadProjectEditDetail({
    required String? projectId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.projectEditDetail,
        queryName: 'projectId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.projectEditDetail,
      queryParameters: <String, String>{'projectId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadMyProjectDetail({
    required String? projectId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.myProjectDetailPattern,
        queryName: 'projectId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.myProjectDetail(normalized),
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadOrderDetail({
    required String? orderId,
    String? projectId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(orderId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.orderDetail,
        queryName: 'orderId',
      );
    }
    final normalizedProjectId = _normalize(projectId);

    return _loadGet(
      ExhibitionCanonicalPaths.orderDetail,
      queryParameters: <String, String>{
        'orderId': normalized,
        // ignore: use_null_aware_elements
        if (normalizedProjectId != null) 'projectId': normalizedProjectId,
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadContractDetail({
    required String? orderId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(orderId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.contractDetail,
        queryName: 'orderId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.contractDetail,
      queryParameters: <String, String>{'orderId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadMilestoneList({
    required String? orderId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(orderId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.milestoneList,
        queryName: 'orderId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.milestoneList,
      queryParameters: <String, String>{'orderId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadInspectionDetail({
    required String? milestoneId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(milestoneId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.inspectionDetail,
        queryName: 'milestoneId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.inspectionDetail,
      queryParameters: <String, String>{'milestoneId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadRatingEntry({
    required String? orderId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(orderId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.ratingEntry,
        queryName: 'orderId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.ratingEntry,
      queryParameters: <String, String>{'orderId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadProjectCounterpartyRatingEntry({
    required String? orderId,
    required String? projectId,
    required String? rateeOrganizationId,
    bool forceRefresh = false,
  }) async {
    final normalizedOrderId = _normalize(orderId);
    final normalizedProjectId = _normalize(projectId);
    final normalizedRateeId = _normalize(rateeOrganizationId);
    if (normalizedOrderId == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.projectCounterpartyRatingEntry,
        queryName: 'orderId',
      );
    }
    if (normalizedProjectId == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.projectCounterpartyRatingEntry,
        queryName: 'projectId',
      );
    }
    if (normalizedRateeId == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.projectCounterpartyRatingEntry,
        queryName: 'rateeOrganizationId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.projectCounterpartyRatingEntry,
      queryParameters: <String, String>{
        'orderId': normalizedOrderId,
        'projectId': normalizedProjectId,
        'rateeOrganizationId': normalizedRateeId,
      },
      forceRefresh: forceRefresh,
    );
  }

  Future<ExhibitionLoadResult> loadBidResult({
    required String? projectId,
    bool forceRefresh = false,
  }) async {
    final normalized = _normalize(projectId);
    if (normalized == null) {
      return _missingQueryResult(
        path: ExhibitionCanonicalPaths.bidResult,
        queryName: 'projectId',
      );
    }

    return _loadGet(
      ExhibitionCanonicalPaths.bidResult,
      queryParameters: <String, String>{'projectId': normalized},
      forceRefresh: forceRefresh,
    );
  }

  void invalidateInspectionDetail({required String? milestoneId}) {
    final normalized = _normalize(milestoneId);
    if (normalized == null) {
      return;
    }

    _invalidateCachedGet(
      ExhibitionCanonicalPaths.inspectionDetail,
      queryParameters: <String, String>{'milestoneId': normalized},
    );
  }

  Future<ExhibitionLoadResult> _loadGet(
    String canonicalPath, {
    Map<String, String>? queryParameters,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKey(canonicalPath, queryParameters);
    if (_isSessionCachedPath(canonicalPath)) {
      if (forceRefresh) {
        _successCache.remove(cacheKey);
      } else {
        final cachedResult = _successCache[cacheKey];
        if (cachedResult != null) {
          return cachedResult;
        }
      }

      final inFlightResult = _inFlightLoads[cacheKey];
      if (inFlightResult != null) {
        return inFlightResult;
      }

      final future =
          _performLoadGet(canonicalPath, queryParameters: queryParameters)
              .then((ExhibitionLoadResult result) {
                if (_isCacheableSuccess(result)) {
                  _successCache[cacheKey] = result;
                } else {
                  _successCache.remove(cacheKey);
                }
                return result;
              })
              .whenComplete(() {
                _inFlightLoads.remove(cacheKey);
              });

      _inFlightLoads[cacheKey] = future;
      return future;
    }

    return _performLoadGet(canonicalPath, queryParameters: queryParameters);
  }

  bool _isSessionCachedPath(String canonicalPath) {
    return _sessionCachedPaths.contains(canonicalPath) ||
        ExhibitionCanonicalPaths.isMyProjectDetail(canonicalPath);
  }

  Future<ExhibitionLoadResult> _performLoadGet(
    String canonicalPath, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(canonicalPath, queryParameters: queryParameters),
      );
      return _mapLoadResponse(response, canonicalPath);
    } on SocketException catch (error) {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: error.message.toLowerCase().contains('request timed out')
            ? error.message
            : 'network error while requesting canonical BFF path',
      );
    } on HttpException {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'http error while requesting canonical BFF path',
      );
    } on StateError {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'current fake transport did not provide this canonical path',
      );
    } on FormatException {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  ExhibitionLoadResult _mapLoadResponse(
    AppApiResponse response,
    String canonicalPath,
  ) {
    final payload = response.body;
    final failurePayload = _sanitizeFailurePayload(payload);
    final failureCode = _extractErrorCode(failurePayload);
    final failureMessage = _failureMessage(
      payload,
      'canonical BFF request failed',
    );

    if (response.statusCode == 401) {
      return ExhibitionLoadResult(
        state: AppPageState.unauthorized,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode == 403) {
      return ExhibitionLoadResult(
        state: AppPageState.forbidden,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode == 404) {
      return ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode >= 500) {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode >= 400) {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        payload: failurePayload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }
    final validation = _sanitizeAndValidateSuccessPayload(
      'GET',
      canonicalPath,
      payload,
    );
    if (!validation.isValid) {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        payload: validation.payload,
        message: validation.message,
      );
    }

    if (_isEmptyPayload(validation.payload)) {
      return ExhibitionLoadResult(
        state: AppPageState.empty,
        method: 'GET',
        path: canonicalPath,
        payload: validation.payload,
      );
    }

    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: 'GET',
      path: canonicalPath,
      payload: validation.payload,
    );
  }

  ExhibitionLoadResult _missingQueryResult({
    required String path,
    required String queryName,
  }) {
    return ExhibitionLoadResult(
      state: AppPageState.notFound,
      method: 'GET',
      path: path,
      message:
          '$queryName is required from route context or page context before calling BFF',
    );
  }

  static bool _isCacheableSuccess(ExhibitionLoadResult result) {
    return result.state == AppPageState.content ||
        result.state == AppPageState.empty;
  }

  void _invalidateCachedGet(
    String canonicalPath, {
    Map<String, String>? queryParameters,
  }) {
    final cacheKey = _cacheKey(canonicalPath, queryParameters);
    _successCache.remove(cacheKey);
    _inFlightLoads.remove(cacheKey);
  }

  String _cacheKey(String canonicalPath, Map<String, String>? queryParameters) {
    final sessionScopeKey = _sessionScopeKey(canonicalPath);
    final queryKey = _queryCacheKey(canonicalPath, queryParameters);
    return sessionScopeKey == null ? queryKey : '$sessionScopeKey::$queryKey';
  }

  static String _queryCacheKey(
    String canonicalPath,
    Map<String, String>? queryParameters,
  ) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return canonicalPath;
    }

    final normalizedEntries = queryParameters.entries.toList()
      ..sort(
        (MapEntry<String, String> left, MapEntry<String, String> right) =>
            left.key.compareTo(right.key),
      );

    final query = normalizedEntries
        .map(
          (MapEntry<String, String> entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
    return '$canonicalPath?$query';
  }

  String? _sessionScopeKey(String canonicalPath) {
    if (!_isSessionCachedPath(canonicalPath)) {
      return null;
    }

    final snapshot = AppSessionStore.instance.snapshot;
    final accessToken = snapshot.accessToken?.trim();
    if (accessToken != null && accessToken.isNotEmpty) {
      return 'access:${accessToken.hashCode}';
    }

    final refreshToken = snapshot.refreshToken?.trim();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      return 'refresh:${refreshToken.hashCode}';
    }

    return 'anonymous';
  }
}
