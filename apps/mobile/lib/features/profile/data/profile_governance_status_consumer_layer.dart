import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/profile/data/profile_governance_status_models.dart';
import 'package:mobile/features/profile/data/profile_governance_status_parser.dart';

export 'package:mobile/features/profile/data/profile_governance_status_models.dart';

class ProfileGovernanceStatusConsumerLayer {
  ProfileGovernanceStatusConsumerLayer({AppApiClient? client})
    : _client = client ?? AppApiClient();

  static ProfileGovernanceStatusConsumerLayer _instance =
      ProfileGovernanceStatusConsumerLayer();

  static ProfileGovernanceStatusConsumerLayer get instance => _instance;

  static void install(ProfileGovernanceStatusConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileGovernanceStatusConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfileGovernanceStatusResult> loadStatus() async {
    const canonicalPath = ProfileGovernanceStatusCanonicalPaths.status;
    const method = 'GET';
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(canonicalPath),
      );
      return _mapResponse(
        response,
        method: method,
        canonicalPath: canonicalPath,
      );
    } on SocketException {
      return const ProfileGovernanceStatusResult(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: '当前累计分快照网络异常，请稍后再试。',
      );
    } on HttpException {
      return const ProfileGovernanceStatusResult(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: '当前累计分快照请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfileGovernanceStatusResult(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: '当前累计分快照响应解析失败，页面保持受控展示。',
      );
    }
  }

  ProfileGovernanceStatusResult _mapResponse(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
  }) {
    if (response.statusCode == 401) {
      return ProfileGovernanceStatusResult(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceStatusPayloadParser.extractMessage(
              response.body,
            ) ??
            '当前需要先登录后查看累计分快照。',
        errorCode: ProfileGovernanceStatusPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode == 403) {
      return ProfileGovernanceStatusResult(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceStatusPayloadParser.extractMessage(
              response.body,
            ) ??
            '当前账号暂不能查看累计分快照。',
        errorCode: ProfileGovernanceStatusPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode == 404) {
      return ProfileGovernanceStatusResult(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceStatusPayloadParser.extractMessage(
              response.body,
            ) ??
            '当前累计分快照入口暂不可用。',
        errorCode: ProfileGovernanceStatusPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode >= 500) {
      return ProfileGovernanceStatusResult(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceStatusPayloadParser.extractMessage(
              response.body,
            ) ??
            '当前累计分快照暂时不可用，请稍后再试。',
        errorCode: ProfileGovernanceStatusPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfileGovernanceStatusResult(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            ProfileGovernanceStatusPayloadParser.extractMessage(
              response.body,
            ) ??
            '当前累计分快照返回受控失败。',
        errorCode: ProfileGovernanceStatusPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }

    final data = ProfileGovernanceStatusPayloadParser.parseStatusView(
      response.body,
    );
    if (data == null) {
      return ProfileGovernanceStatusResult(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: '当前累计分快照响应缺少必要字段，页面保持受控展示。',
      );
    }

    return ProfileGovernanceStatusResult(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }
}
