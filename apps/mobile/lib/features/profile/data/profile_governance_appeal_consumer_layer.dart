import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/profile/data/profile_governance_appeal_models.dart';
import 'package:mobile/features/profile/data/profile_governance_appeal_parser.dart';

export 'package:mobile/features/profile/data/profile_governance_appeal_models.dart';

class ProfileGovernanceAppealConsumerLayer {
  ProfileGovernanceAppealConsumerLayer({AppApiClient? client})
    : _client = client ?? AppApiClient();

  static ProfileGovernanceAppealConsumerLayer _instance =
      ProfileGovernanceAppealConsumerLayer();

  static ProfileGovernanceAppealConsumerLayer get instance => _instance;

  static void install(ProfileGovernanceAppealConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileGovernanceAppealConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfileGovernanceAppealResult<ProfileGovernanceAppealListView>>
  loadAppeals() {
    return _get(
      canonicalPath: ProfileGovernanceAppealCanonicalPaths.appeals,
      parser: ProfileGovernanceAppealPayloadParser.parseListView,
      isEmpty: (ProfileGovernanceAppealListView data) => data.items.isEmpty,
    );
  }

  Future<ProfileGovernanceAppealResult<ProfileGovernanceAppealDetailView>>
  loadAppealDetail({required String? appealCaseId}) {
    final resolved = _readRouteValue(appealCaseId);
    if (resolved == null) {
      return Future<
        ProfileGovernanceAppealResult<ProfileGovernanceAppealDetailView>
      >.value(
        const ProfileGovernanceAppealResult<ProfileGovernanceAppealDetailView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: ProfileGovernanceAppealCanonicalPaths.appeals,
          message: '申诉详情当前暂不可用',
        ),
      );
    }

    return _get(
      canonicalPath: ProfileGovernanceAppealCanonicalPaths.detail(resolved),
      parser: ProfileGovernanceAppealPayloadParser.parseDetailView,
      isEmpty: (_) => false,
    );
  }

  Future<ProfileGovernanceAppealResult<T>> _get<T>({
    required String canonicalPath,
    required T? Function(Object? payload) parser,
    required bool Function(T data) isEmpty,
  }) async {
    const method = 'GET';
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(canonicalPath),
      );
      return _mapResponse(
        response,
        method: method,
        canonicalPath: canonicalPath,
        parser: parser,
        isEmpty: isEmpty,
      );
    } on SocketException {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: '当前申诉记录网络异常，请稍后再试。',
      );
    } on HttpException {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: '当前申诉记录请求失败，请稍后再试。',
      );
    } on FormatException {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: '当前申诉记录响应解析失败，页面保持受控展示。',
      );
    }
  }

  ProfileGovernanceAppealResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
    required bool Function(T data) isEmpty,
  }) {
    if (response.statusCode == 401) {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceAppealPayloadParser.extractMessage(response.body) ??
            '当前申诉记录需要先登录后查看。',
        errorCode: ProfileGovernanceAppealPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode == 403) {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceAppealPayloadParser.extractMessage(response.body) ??
            '当前账号暂不能查看申诉记录。',
        errorCode: ProfileGovernanceAppealPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode == 404) {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceAppealPayloadParser.extractMessage(response.body) ??
            '当前申诉记录入口暂不可用。',
        errorCode: ProfileGovernanceAppealPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode >= 500) {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceAppealPayloadParser.extractMessage(response.body) ??
            '当前申诉记录暂时不可用，请稍后再试。',
        errorCode: ProfileGovernanceAppealPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceAppealPayloadParser.extractMessage(response.body) ??
            '当前申诉记录返回受控失败。',
        errorCode: ProfileGovernanceAppealPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return ProfileGovernanceAppealResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: '当前申诉记录响应缺少必要字段，页面保持受控展示。',
      );
    }

    return ProfileGovernanceAppealResult<T>(
      state: isEmpty(data) ? AppPageState.empty : AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }

  String? _readRouteValue(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
