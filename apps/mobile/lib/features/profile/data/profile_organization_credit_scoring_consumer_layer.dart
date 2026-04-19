import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';

final class ProfileOrganizationCreditScoringCanonicalPaths {
  const ProfileOrganizationCreditScoringCanonicalPaths._();

  static const String status =
      '/api/app/profile/organization-credit-scoring/status';
  static const String explanation =
      '/api/app/profile/organization-credit-scoring/explanation';
  static const String handoff =
      '/api/app/profile/organization-credit-scoring/handoff';
}

class OrganizationCreditScoringStatusView {
  const OrganizationCreditScoringStatusView({
    required this.score,
    required this.tierCode,
    required this.tierLabel,
    required this.sampleStatus,
    required this.riskPosture,
    required this.ratedCompletedOrderCount,
    required this.positiveRate,
    required this.negativeRate,
    required this.verySatisfiedCount,
    required this.satisfiedCount,
    required this.passableCount,
    required this.negativeCount,
    required this.actionableState,
    required this.updatedAt,
  });

  final int? score;
  final String? tierCode;
  final String? tierLabel;
  final String sampleStatus;
  final String? riskPosture;
  final int ratedCompletedOrderCount;
  final double? positiveRate;
  final double? negativeRate;
  final int verySatisfiedCount;
  final int satisfiedCount;
  final int passableCount;
  final int negativeCount;
  final String? actionableState;
  final String? updatedAt;
}

class OrganizationCreditScoringExplanationView {
  const OrganizationCreditScoringExplanationView({
    required this.reasonSummary,
    required this.reasonCodes,
    required this.sampleStatus,
    required this.riskPosture,
    required this.ratedCompletedOrderCount,
    required this.positiveRate,
    required this.negativeRate,
    required this.verySatisfiedCount,
    required this.satisfiedCount,
    required this.passableCount,
    required this.negativeCount,
    required this.updatedAt,
  });

  final String reasonSummary;
  final List<String> reasonCodes;
  final String sampleStatus;
  final String? riskPosture;
  final int ratedCompletedOrderCount;
  final double? positiveRate;
  final double? negativeRate;
  final int verySatisfiedCount;
  final int satisfiedCount;
  final int passableCount;
  final int negativeCount;
  final String? updatedAt;
}

class OrganizationCreditScoringHandoffView {
  const OrganizationCreditScoringHandoffView({
    required this.actionableState,
    required this.sampleStatus,
    required this.riskPosture,
    required this.primaryActionCode,
    required this.primaryActionLabel,
    required this.handoffMessage,
    required this.updatedAt,
  });

  final String? actionableState;
  final String sampleStatus;
  final String? riskPosture;
  final String? primaryActionCode;
  final String? primaryActionLabel;
  final String? handoffMessage;
  final String? updatedAt;
}

class ProfileOrganizationCreditScoringResult<T> {
  const ProfileOrganizationCreditScoringResult({
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
}

class ProfileOrganizationCreditScoringConsumerLayer {
  ProfileOrganizationCreditScoringConsumerLayer._(this._client);

  factory ProfileOrganizationCreditScoringConsumerLayer({
    AppApiClient? client,
  }) {
    return ProfileOrganizationCreditScoringConsumerLayer._(
      client ?? AppApiClient(),
    );
  }

  static ProfileOrganizationCreditScoringConsumerLayer _instance =
      ProfileOrganizationCreditScoringConsumerLayer();

  static ProfileOrganizationCreditScoringConsumerLayer get instance =>
      _instance;

  static void install(
    ProfileOrganizationCreditScoringConsumerLayer consumerLayer,
  ) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileOrganizationCreditScoringConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfileOrganizationCreditScoringResult<OrganizationCreditScoringStatusView>>
  loadStatus() {
    return _get(
      canonicalPath: ProfileOrganizationCreditScoringCanonicalPaths.status,
      parser: _parseStatusView,
    );
  }

  Future<
    ProfileOrganizationCreditScoringResult<
      OrganizationCreditScoringExplanationView
    >
  >
  loadExplanation() {
    return _get(
      canonicalPath: ProfileOrganizationCreditScoringCanonicalPaths.explanation,
      parser: _parseExplanationView,
    );
  }

  Future<ProfileOrganizationCreditScoringResult<OrganizationCreditScoringHandoffView>>
  loadHandoff() {
    return _get(
      canonicalPath: ProfileOrganizationCreditScoringCanonicalPaths.handoff,
      parser: _parseHandoffView,
    );
  }

  Future<ProfileOrganizationCreditScoringResult<T>> _get<T>({
    required String canonicalPath,
    required T? Function(Object? payload) parser,
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
      );
    } on SocketException {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            'network error while loading organization-credit-scoring read model',
      );
    } on HttpException {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            'http error while loading organization-credit-scoring read model',
      );
    } on FormatException {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            'response decoding failed for organization-credit-scoring read model',
      );
    }
  }

  ProfileOrganizationCreditScoringResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) {
    if (response.statusCode == 401) {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'organization-credit-scoring request unauthorized',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode == 403) {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'organization-credit-scoring request forbidden',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode == 404) {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'organization-credit-scoring route unavailable',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode >= 500) {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'organization-credit-scoring request failed',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'organization-credit-scoring request returned a controlled failure',
        errorCode: _extractErrorCode(response.body),
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return ProfileOrganizationCreditScoringResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            'organization-credit-scoring response is missing required fields',
      );
    }

    return ProfileOrganizationCreditScoringResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }

  static OrganizationCreditScoringStatusView? _parseStatusView(Object? payload) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final sampleStatus = _readRequiredString(body['sampleStatus']);
    final riskPosture = _readNullableString(body['riskPosture']);
    final ratedCompletedOrderCount = _readRequiredInt(
      body['ratedCompletedOrderCount'],
    );
    final verySatisfiedCount = _readRequiredInt(body['verySatisfiedCount']);
    final satisfiedCount = _readRequiredInt(body['satisfiedCount']);
    final passableCount = _readRequiredInt(body['passableCount']);
    final negativeCount = _readRequiredInt(body['negativeCount']);
    if (sampleStatus == null ||
        ratedCompletedOrderCount == null ||
        verySatisfiedCount == null ||
        satisfiedCount == null ||
        passableCount == null ||
        negativeCount == null) {
      return null;
    }

    return OrganizationCreditScoringStatusView(
      score: _readNullableInt(body['score']),
      tierCode: _readNullableString(body['tierCode']),
      tierLabel: _readNullableString(body['tierLabel']),
      sampleStatus: sampleStatus,
      riskPosture: riskPosture,
      ratedCompletedOrderCount: ratedCompletedOrderCount,
      positiveRate: _readNullableDouble(body['positiveRate']),
      negativeRate: _readNullableDouble(body['negativeRate']),
      verySatisfiedCount: verySatisfiedCount,
      satisfiedCount: satisfiedCount,
      passableCount: passableCount,
      negativeCount: negativeCount,
      actionableState: _readNullableString(body['actionableState']),
      updatedAt: _readNullableString(body['updatedAt']),
    );
  }

  static OrganizationCreditScoringExplanationView? _parseExplanationView(
    Object? payload,
  ) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final reasonSummary = _readRequiredString(body['reasonSummary']);
    final reasonCodes = _readRequiredStringList(body['reasonCodes']);
    final sampleStatus = _readRequiredString(body['sampleStatus']);
    final riskPosture = _readNullableString(body['riskPosture']);
    final ratedCompletedOrderCount = _readRequiredInt(
      body['ratedCompletedOrderCount'],
    );
    final verySatisfiedCount = _readRequiredInt(body['verySatisfiedCount']);
    final satisfiedCount = _readRequiredInt(body['satisfiedCount']);
    final passableCount = _readRequiredInt(body['passableCount']);
    final negativeCount = _readRequiredInt(body['negativeCount']);
    if (reasonSummary == null ||
        reasonCodes == null ||
        sampleStatus == null ||
        ratedCompletedOrderCount == null ||
        verySatisfiedCount == null ||
        satisfiedCount == null ||
        passableCount == null ||
        negativeCount == null) {
      return null;
    }
    return OrganizationCreditScoringExplanationView(
      reasonSummary: reasonSummary,
      reasonCodes: reasonCodes,
      sampleStatus: sampleStatus,
      riskPosture: riskPosture,
      ratedCompletedOrderCount: ratedCompletedOrderCount,
      positiveRate: _readNullableDouble(body['positiveRate']),
      negativeRate: _readNullableDouble(body['negativeRate']),
      verySatisfiedCount: verySatisfiedCount,
      satisfiedCount: satisfiedCount,
      passableCount: passableCount,
      negativeCount: negativeCount,
      updatedAt: _readNullableString(body['updatedAt']),
    );
  }

  static OrganizationCreditScoringHandoffView? _parseHandoffView(
    Object? payload,
  ) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final sampleStatus = _readRequiredString(body['sampleStatus']);
    final riskPosture = _readNullableString(body['riskPosture']);
    if (sampleStatus == null) {
      return null;
    }
    return OrganizationCreditScoringHandoffView(
      actionableState: _readNullableString(body['actionableState']),
      sampleStatus: sampleStatus,
      riskPosture: riskPosture,
      primaryActionCode: _readNullableString(body['primaryActionCode']),
      primaryActionLabel: _readNullableString(body['primaryActionLabel']),
      handoffMessage: _readNullableString(body['handoffMessage']),
      updatedAt: _readNullableString(body['updatedAt']),
    );
  }

  static Map<String, Object?>? _map(Object? payload) {
    if (payload is Map<String, Object?>) {
      return payload;
    }
    if (payload is Map) {
      return payload.map<String, Object?>(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  static String? _readRequiredString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _readNullableString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _readNullableInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  static int? _readRequiredInt(Object? value) {
    return _readNullableInt(value);
  }

  static double? _readNullableDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  static List<String>? _readRequiredStringList(Object? value) {
    if (value is! List) {
      return null;
    }
    final items = <String>[];
    for (final item in value) {
      final resolved = _readRequiredString(item);
      if (resolved == null) {
        return null;
      }
      items.add(resolved);
    }
    return items;
  }

  static String? _extractMessage(Object? body) {
    final map = _map(body);
    final message = map?['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    return null;
  }

  static String? _extractErrorCode(Object? body) {
    final map = _map(body);
    final code = map?['code'];
    if (code is String && code.trim().isNotEmpty) {
      return code.trim();
    }
    return null;
  }
}
