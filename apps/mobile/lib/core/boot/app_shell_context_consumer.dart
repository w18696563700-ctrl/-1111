import 'dart:async';
import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/core/boot/app_shell_context.dart';

final class AppShellContextCanonicalPaths {
  const AppShellContextCanonicalPaths._();

  static const String shellContext = '/api/app/shell/context';
}

class AppShellContextConsumer {
  AppShellContextConsumer._(this._client);

  static const Duration _shellContextRequestTimeout = Duration(seconds: 5);

  factory AppShellContextConsumer({AppApiClient? client}) {
    return AppShellContextConsumer._(client ?? AppApiClient());
  }

  final AppApiClient _client;

  Future<AppShellContextData?> load() async {
    final result = await loadResult();
    return result.data;
  }

  Future<AppShellContextResult> loadResult() async {
    try {
      final response =
          await runProtectedAppRequest(
            () =>
                _client.getEndpoint(AppShellContextCanonicalPaths.shellContext),
          ).timeout(
            _shellContextRequestTimeout,
            onTimeout: () =>
                throw SocketException('shell context request timed out'),
          );
      return _mapResponse(response);
    } on SocketException {
      return const AppShellContextResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message: 'shell context request timed out or network unavailable',
      );
    } on HttpException {
      return const AppShellContextResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message: 'shell context http request failed',
      );
    } on FormatException {
      return const AppShellContextResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message: 'shell context decoding failed',
      );
    }
  }

  AppShellContextResult _mapResponse(AppApiResponse response) {
    if (response.statusCode == 401) {
      return AppShellContextResult(
        state: AppPageState.unauthorized,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message:
            _readOptionalString(_readObjectMap(response.body)?['message']) ??
            'shell context unauthorized',
        errorCode: _readOptionalString(_readObjectMap(response.body)?['code']),
      );
    }

    if (response.statusCode == 403) {
      return AppShellContextResult(
        state: AppPageState.forbidden,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message:
            _readOptionalString(_readObjectMap(response.body)?['message']) ??
            'shell context forbidden',
        errorCode: _readOptionalString(_readObjectMap(response.body)?['code']),
      );
    }

    if (response.statusCode == 404) {
      return AppShellContextResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message:
            _readOptionalString(_readObjectMap(response.body)?['message']) ??
            'shell context not found',
        errorCode: _readOptionalString(_readObjectMap(response.body)?['code']),
      );
    }

    if (response.statusCode >= 500) {
      return AppShellContextResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message:
            _readOptionalString(_readObjectMap(response.body)?['message']) ??
            'shell context failed',
        errorCode: _readOptionalString(_readObjectMap(response.body)?['code']),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return AppShellContextResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message:
            _readOptionalString(_readObjectMap(response.body)?['message']) ??
            'shell context returned controlled failure',
        errorCode: _readOptionalString(_readObjectMap(response.body)?['code']),
      );
    }

    final payload = response.body;
    if (payload is! Map) {
      return const AppShellContextResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: AppShellContextCanonicalPaths.shellContext,
        message: 'shell context response must be an object',
      );
    }

    final data = AppShellContextData(
      userId: _readOptionalString(payload['userId']),
      displayName: _readOptionalString(payload['displayName']),
      avatarUrl: _readOptionalString(payload['avatarUrl']),
      organizationId: _readOptionalString(payload['organizationId']),
      organizationType: _readOptionalString(payload['organizationType']),
      roleKeys: _readStringList(payload['roleKeys']),
      certificationStatus: _readOptionalString(payload['certificationStatus']),
      personalCertificationStatus: _readOptionalString(
        payload['personalCertificationStatus'],
      ),
      personalCertificationQualified:
          payload['personalCertificationQualified'] is bool
          ? payload['personalCertificationQualified'] as bool
          : null,
      personalCertificationLockedToOtherActor:
          payload['personalCertificationLockedToOtherActor'] is bool
          ? payload['personalCertificationLockedToOtherActor'] as bool
          : null,
      membershipStatus: _readOptionalString(payload['membershipStatus']),
      projectCreateEligibility: _readProjectCreateEligibility(
        payload['projectCreateEligibility'],
      ),
      paidMembershipTier: _readOptionalString(payload['paidMembershipTier']),
      paidMembershipEntitlementsSummary: _readStringList(
        payload['paidMembershipEntitlementsSummary'],
      ),
      paidMembershipQuotaSummary: _readStringList(
        payload['paidMembershipQuotaSummary'],
      ),
      paidMembershipNextRefreshAt: _readOptionalString(
        payload['paidMembershipNextRefreshAt'],
      ),
      visibleBuildings: _readStringList(payload['visibleBuildings']),
      featureFlagsVersion: _readOptionalString(payload['featureFlagsVersion']),
      unreadSummary: _readObjectMap(payload['unreadSummary']),
      myBuildingProjection: _readObjectMap(payload['myBuildingProjection']),
    );

    return AppShellContextResult(
      state: AppPageState.content,
      method: 'GET',
      path: AppShellContextCanonicalPaths.shellContext,
      data: data,
    );
  }

  static String? _readOptionalString(Object? raw) {
    if (raw is! String) {
      return null;
    }

    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static List<String> _readStringList(Object? raw) {
    if (raw is! List) {
      return const <String>[];
    }

    return raw
        .whereType<String>()
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static Map<String, Object?>? _readObjectMap(Object? raw) {
    if (raw is! Map) {
      return null;
    }

    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  static AppProjectCreateEligibilityData? _readProjectCreateEligibility(
    Object? raw,
  ) {
    final map = _readObjectMap(raw);
    if (map == null) {
      return null;
    }
    final value = map['canCreateProject'];
    if (value is! bool) {
      throw const FormatException(
        'shell context projectCreateEligibility.canCreateProject must be boolean',
      );
    }
    return AppProjectCreateEligibilityData(canCreateProject: value);
  }
}

class AppShellContextResult {
  const AppShellContextResult({
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
  final AppShellContextData? data;
  final String? message;
  final String? errorCode;
}
