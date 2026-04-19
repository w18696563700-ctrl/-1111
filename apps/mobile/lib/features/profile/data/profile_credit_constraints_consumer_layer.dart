import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';

final class ProfileCreditConstraintsCanonicalPaths {
  const ProfileCreditConstraintsCanonicalPaths._();

  static const String status = '/api/app/profile/credit-and-constraints/status';
  static const String explanation =
      '/api/app/profile/credit-and-constraints/explanation';
  static const String handoff =
      '/api/app/profile/credit-and-constraints/handoff';
}

class CreditConstraintsPrivateSummaryView {
  const CreditConstraintsPrivateSummaryView({
    required this.entryKey,
    required this.summaryStatus,
    required this.creditConstraintStatus,
    required this.depositPostureStatus,
    required this.transactionGuaranteeEligibilityStatus,
    required this.updatedAt,
  });

  final String entryKey;
  final String summaryStatus;
  final String creditConstraintStatus;
  final String depositPostureStatus;
  final String transactionGuaranteeEligibilityStatus;
  final String updatedAt;
}

class CreditConstraintStatusView {
  const CreditConstraintStatusView({
    required this.creditConstraintStatus,
    required this.performanceConstraintStatus,
    required this.executionAvailabilityStatus,
    required this.restrictionReasonCode,
    required this.advisoryReasonCode,
    required this.updatedAt,
  });

  final String creditConstraintStatus;
  final String performanceConstraintStatus;
  final String executionAvailabilityStatus;
  final String? restrictionReasonCode;
  final String? advisoryReasonCode;
  final String updatedAt;
}

class DepositPostureView {
  const DepositPostureView({
    required this.depositRequirementStatus,
    required this.depositEligibilityStatus,
    required this.depositRestrictionStatus,
    required this.depositPostureStatus,
    required this.depositHandoffKey,
    required this.depositDependencyKey,
    required this.updatedAt,
  });

  final String depositRequirementStatus;
  final String depositEligibilityStatus;
  final String depositRestrictionStatus;
  final String depositPostureStatus;
  final String depositHandoffKey;
  final String? depositDependencyKey;
  final String updatedAt;
}

class TransactionGuaranteePostureView {
  const TransactionGuaranteePostureView({
    required this.transactionGuaranteeEligibilityStatus,
    required this.transactionGuaranteeRestrictionStatus,
    required this.transactionGuaranteeExplanationKey,
    required this.transactionGuaranteeHandoffKey,
    required this.transactionGuaranteeDependencyKey,
    required this.updatedAt,
  });

  final String transactionGuaranteeEligibilityStatus;
  final String transactionGuaranteeRestrictionStatus;
  final String transactionGuaranteeExplanationKey;
  final String transactionGuaranteeHandoffKey;
  final String? transactionGuaranteeDependencyKey;
  final String updatedAt;
}

class CreditConstraintsDependencyReferenceView {
  const CreditConstraintsDependencyReferenceView({
    required this.dependencyFamilyKey,
    required this.dependencyRequired,
    required this.dependencyExplanationKey,
    required this.dependencyHandoffKey,
  });

  final String dependencyFamilyKey;
  final bool dependencyRequired;
  final String dependencyExplanationKey;
  final String dependencyHandoffKey;
}

class ProfileCreditConstraintsStatusView {
  const ProfileCreditConstraintsStatusView({
    required this.privateSummary,
    required this.creditConstraint,
    required this.deposit,
    required this.transactionGuarantee,
    required this.dependencyReference,
  });

  final CreditConstraintsPrivateSummaryView privateSummary;
  final CreditConstraintStatusView creditConstraint;
  final DepositPostureView deposit;
  final TransactionGuaranteePostureView transactionGuarantee;
  final CreditConstraintsDependencyReferenceView? dependencyReference;
}

class CreditConstraintsExplanationBlockView {
  const CreditConstraintsExplanationBlockView({
    required this.explanationKey,
    required this.title,
    required this.body,
  });

  final String explanationKey;
  final String title;
  final String body;
}

class CreditConstraintsDependencyExplanationView {
  const CreditConstraintsDependencyExplanationView({
    required this.dependencyFamilyKey,
    required this.dependencyRequired,
    required this.dependencyExplanationKey,
    required this.title,
    required this.body,
  });

  final String dependencyFamilyKey;
  final bool dependencyRequired;
  final String dependencyExplanationKey;
  final String title;
  final String body;
}

class ProfileCreditConstraintsExplanationView {
  const ProfileCreditConstraintsExplanationView({
    required this.creditExplanation,
    required this.depositExplanation,
    required this.transactionGuaranteeExplanation,
    required this.dependencyExplanation,
    required this.disclaimer,
  });

  final CreditConstraintsExplanationBlockView creditExplanation;
  final CreditConstraintsExplanationBlockView depositExplanation;
  final CreditConstraintsExplanationBlockView transactionGuaranteeExplanation;
  final CreditConstraintsDependencyExplanationView? dependencyExplanation;
  final String disclaimer;
}

class CreditConstraintsHandoffBlockView {
  const CreditConstraintsHandoffBlockView({
    required this.handoffKey,
    required this.title,
    required this.body,
  });

  final String handoffKey;
  final String title;
  final String body;
}

class CreditConstraintsDependencyHandoffView {
  const CreditConstraintsDependencyHandoffView({
    required this.dependencyFamilyKey,
    required this.dependencyRequired,
    required this.dependencyHandoffKey,
    required this.title,
    required this.body,
  });

  final String dependencyFamilyKey;
  final bool dependencyRequired;
  final String dependencyHandoffKey;
  final String title;
  final String body;
}

class ProfileCreditConstraintsHandoffView {
  const ProfileCreditConstraintsHandoffView({
    required this.creditHandoff,
    required this.depositHandoff,
    required this.transactionGuaranteeHandoff,
    required this.dependencyHandoff,
  });

  final CreditConstraintsHandoffBlockView creditHandoff;
  final CreditConstraintsHandoffBlockView depositHandoff;
  final CreditConstraintsHandoffBlockView transactionGuaranteeHandoff;
  final CreditConstraintsDependencyHandoffView? dependencyHandoff;
}

class ProfileCreditConstraintsResult<T> {
  const ProfileCreditConstraintsResult({
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

class ProfileCreditConstraintsConsumerLayer {
  ProfileCreditConstraintsConsumerLayer._(this._client);

  factory ProfileCreditConstraintsConsumerLayer({AppApiClient? client}) {
    return ProfileCreditConstraintsConsumerLayer._(client ?? AppApiClient());
  }

  static ProfileCreditConstraintsConsumerLayer _instance =
      ProfileCreditConstraintsConsumerLayer();

  static ProfileCreditConstraintsConsumerLayer get instance => _instance;

  static void install(ProfileCreditConstraintsConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileCreditConstraintsConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfileCreditConstraintsResult<ProfileCreditConstraintsStatusView>>
  loadStatus() {
    return _get(
      canonicalPath: ProfileCreditConstraintsCanonicalPaths.status,
      parser: _parseStatusView,
    );
  }

  Future<
    ProfileCreditConstraintsResult<ProfileCreditConstraintsExplanationView>
  >
  loadExplanation() {
    return _get(
      canonicalPath: ProfileCreditConstraintsCanonicalPaths.explanation,
      parser: _parseExplanationView,
    );
  }

  Future<ProfileCreditConstraintsResult<ProfileCreditConstraintsHandoffView>>
  loadHandoff() {
    return _get(
      canonicalPath: ProfileCreditConstraintsCanonicalPaths.handoff,
      parser: _parseHandoffView,
    );
  }

  Future<ProfileCreditConstraintsResult<T>> _get<T>({
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
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            'network error while loading credit-and-constraints read model',
      );
    } on HttpException {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: 'http error while loading credit-and-constraints read model',
      );
    } on FormatException {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            'response decoding failed for credit-and-constraints read model',
      );
    }
  }

  ProfileCreditConstraintsResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) {
    if (response.statusCode == 401) {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'credit-and-constraints request unauthorized',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode == 403) {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'credit-and-constraints request forbidden',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode == 404) {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'credit-and-constraints route unavailable',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode >= 500) {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'credit-and-constraints request failed',
        errorCode: _extractErrorCode(response.body),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            _extractMessage(response.body) ??
            'credit-and-constraints request returned a controlled failure',
        errorCode: _extractErrorCode(response.body),
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return ProfileCreditConstraintsResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'credit-and-constraints response is missing required fields',
      );
    }

    return ProfileCreditConstraintsResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }

  static ProfileCreditConstraintsStatusView? _parseStatusView(Object? payload) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final privateSummary = _parsePrivateSummary(body['privateSummary']);
    final creditConstraint = _parseCreditConstraint(body['creditConstraint']);
    final deposit = _parseDeposit(body['deposit']);
    final transactionGuarantee = _parseTransactionGuarantee(
      body['transactionGuarantee'],
    );
    if (privateSummary == null ||
        creditConstraint == null ||
        deposit == null ||
        transactionGuarantee == null) {
      return null;
    }
    return ProfileCreditConstraintsStatusView(
      privateSummary: privateSummary,
      creditConstraint: creditConstraint,
      deposit: deposit,
      transactionGuarantee: transactionGuarantee,
      dependencyReference: _parseDependencyReference(
        body['dependencyReference'],
      ),
    );
  }

  static ProfileCreditConstraintsExplanationView? _parseExplanationView(
    Object? payload,
  ) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final creditExplanation = _parseExplanationBlock(body['creditExplanation']);
    final depositExplanation = _parseExplanationBlock(
      body['depositExplanation'],
    );
    final transactionGuaranteeExplanation = _parseExplanationBlock(
      body['transactionGuaranteeExplanation'],
    );
    final disclaimer = _readRequiredString(body['disclaimer']);
    if (creditExplanation == null ||
        depositExplanation == null ||
        transactionGuaranteeExplanation == null ||
        disclaimer == null) {
      return null;
    }
    return ProfileCreditConstraintsExplanationView(
      creditExplanation: creditExplanation,
      depositExplanation: depositExplanation,
      transactionGuaranteeExplanation: transactionGuaranteeExplanation,
      dependencyExplanation: _parseDependencyExplanation(
        body['dependencyExplanation'],
      ),
      disclaimer: disclaimer,
    );
  }

  static ProfileCreditConstraintsHandoffView? _parseHandoffView(
    Object? payload,
  ) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final creditHandoff = _parseHandoffBlock(body['creditHandoff']);
    final depositHandoff = _parseHandoffBlock(body['depositHandoff']);
    final transactionGuaranteeHandoff = _parseHandoffBlock(
      body['transactionGuaranteeHandoff'],
    );
    if (creditHandoff == null ||
        depositHandoff == null ||
        transactionGuaranteeHandoff == null) {
      return null;
    }
    return ProfileCreditConstraintsHandoffView(
      creditHandoff: creditHandoff,
      depositHandoff: depositHandoff,
      transactionGuaranteeHandoff: transactionGuaranteeHandoff,
      dependencyHandoff: _parseDependencyHandoff(body['dependencyHandoff']),
    );
  }

  static CreditConstraintsPrivateSummaryView? _parsePrivateSummary(
    Object? payload,
  ) {
    final body = _map(payload);
    final entryKey = _readRequiredString(body?['entryKey']);
    final summaryStatus = _readRequiredString(body?['summaryStatus']);
    final creditConstraintStatus = _readRequiredString(
      body?['creditConstraintStatus'],
    );
    final depositPostureStatus = _readRequiredString(
      body?['depositPostureStatus'],
    );
    final transactionGuaranteeEligibilityStatus = _readRequiredString(
      body?['transactionGuaranteeEligibilityStatus'],
    );
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (entryKey == null ||
        summaryStatus == null ||
        creditConstraintStatus == null ||
        depositPostureStatus == null ||
        transactionGuaranteeEligibilityStatus == null ||
        updatedAt == null) {
      return null;
    }
    return CreditConstraintsPrivateSummaryView(
      entryKey: entryKey,
      summaryStatus: summaryStatus,
      creditConstraintStatus: creditConstraintStatus,
      depositPostureStatus: depositPostureStatus,
      transactionGuaranteeEligibilityStatus:
          transactionGuaranteeEligibilityStatus,
      updatedAt: updatedAt,
    );
  }

  static CreditConstraintStatusView? _parseCreditConstraint(Object? payload) {
    final body = _map(payload);
    final creditConstraintStatus = _readRequiredString(
      body?['creditConstraintStatus'],
    );
    final performanceConstraintStatus = _readRequiredString(
      body?['performanceConstraintStatus'],
    );
    final executionAvailabilityStatus = _readRequiredString(
      body?['executionAvailabilityStatus'],
    );
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (creditConstraintStatus == null ||
        performanceConstraintStatus == null ||
        executionAvailabilityStatus == null ||
        updatedAt == null) {
      return null;
    }
    return CreditConstraintStatusView(
      creditConstraintStatus: creditConstraintStatus,
      performanceConstraintStatus: performanceConstraintStatus,
      executionAvailabilityStatus: executionAvailabilityStatus,
      restrictionReasonCode: _readNullableString(
        body?['restrictionReasonCode'],
      ),
      advisoryReasonCode: _readNullableString(body?['advisoryReasonCode']),
      updatedAt: updatedAt,
    );
  }

  static DepositPostureView? _parseDeposit(Object? payload) {
    final body = _map(payload);
    final depositRequirementStatus = _readRequiredString(
      body?['depositRequirementStatus'],
    );
    final depositEligibilityStatus = _readRequiredString(
      body?['depositEligibilityStatus'],
    );
    final depositRestrictionStatus = _readRequiredString(
      body?['depositRestrictionStatus'],
    );
    final depositPostureStatus = _readRequiredString(
      body?['depositPostureStatus'],
    );
    final depositHandoffKey = _readRequiredString(body?['depositHandoffKey']);
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (depositRequirementStatus == null ||
        depositEligibilityStatus == null ||
        depositRestrictionStatus == null ||
        depositPostureStatus == null ||
        depositHandoffKey == null ||
        updatedAt == null) {
      return null;
    }
    return DepositPostureView(
      depositRequirementStatus: depositRequirementStatus,
      depositEligibilityStatus: depositEligibilityStatus,
      depositRestrictionStatus: depositRestrictionStatus,
      depositPostureStatus: depositPostureStatus,
      depositHandoffKey: depositHandoffKey,
      depositDependencyKey: _readNullableString(body?['depositDependencyKey']),
      updatedAt: updatedAt,
    );
  }

  static TransactionGuaranteePostureView? _parseTransactionGuarantee(
    Object? payload,
  ) {
    final body = _map(payload);
    final transactionGuaranteeEligibilityStatus = _readRequiredString(
      body?['transactionGuaranteeEligibilityStatus'],
    );
    final transactionGuaranteeRestrictionStatus = _readRequiredString(
      body?['transactionGuaranteeRestrictionStatus'],
    );
    final transactionGuaranteeExplanationKey = _readRequiredString(
      body?['transactionGuaranteeExplanationKey'],
    );
    final transactionGuaranteeHandoffKey = _readRequiredString(
      body?['transactionGuaranteeHandoffKey'],
    );
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (transactionGuaranteeEligibilityStatus == null ||
        transactionGuaranteeRestrictionStatus == null ||
        transactionGuaranteeExplanationKey == null ||
        transactionGuaranteeHandoffKey == null ||
        updatedAt == null) {
      return null;
    }
    return TransactionGuaranteePostureView(
      transactionGuaranteeEligibilityStatus:
          transactionGuaranteeEligibilityStatus,
      transactionGuaranteeRestrictionStatus:
          transactionGuaranteeRestrictionStatus,
      transactionGuaranteeExplanationKey: transactionGuaranteeExplanationKey,
      transactionGuaranteeHandoffKey: transactionGuaranteeHandoffKey,
      transactionGuaranteeDependencyKey: _readNullableString(
        body?['transactionGuaranteeDependencyKey'],
      ),
      updatedAt: updatedAt,
    );
  }

  static CreditConstraintsDependencyReferenceView? _parseDependencyReference(
    Object? payload,
  ) {
    if (payload == null) {
      return null;
    }
    final body = _map(payload);
    final dependencyFamilyKey = _readRequiredString(
      body?['dependencyFamilyKey'],
    );
    final dependencyRequired = _readRequiredBool(body?['dependencyRequired']);
    final dependencyExplanationKey = _readRequiredString(
      body?['dependencyExplanationKey'],
    );
    final dependencyHandoffKey = _readRequiredString(
      body?['dependencyHandoffKey'],
    );
    if (dependencyFamilyKey == null ||
        dependencyRequired == null ||
        dependencyExplanationKey == null ||
        dependencyHandoffKey == null) {
      return null;
    }
    return CreditConstraintsDependencyReferenceView(
      dependencyFamilyKey: dependencyFamilyKey,
      dependencyRequired: dependencyRequired,
      dependencyExplanationKey: dependencyExplanationKey,
      dependencyHandoffKey: dependencyHandoffKey,
    );
  }

  static CreditConstraintsExplanationBlockView? _parseExplanationBlock(
    Object? payload,
  ) {
    final body = _map(payload);
    final explanationKey = _readRequiredString(body?['explanationKey']);
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    if (explanationKey == null || title == null || bodyText == null) {
      return null;
    }
    return CreditConstraintsExplanationBlockView(
      explanationKey: explanationKey,
      title: title,
      body: bodyText,
    );
  }

  static CreditConstraintsDependencyExplanationView?
  _parseDependencyExplanation(Object? payload) {
    if (payload == null) {
      return null;
    }
    final body = _map(payload);
    final dependencyFamilyKey = _readRequiredString(
      body?['dependencyFamilyKey'],
    );
    final dependencyRequired = _readRequiredBool(body?['dependencyRequired']);
    final dependencyExplanationKey = _readRequiredString(
      body?['dependencyExplanationKey'],
    );
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    if (dependencyFamilyKey == null ||
        dependencyRequired == null ||
        dependencyExplanationKey == null ||
        title == null ||
        bodyText == null) {
      return null;
    }
    return CreditConstraintsDependencyExplanationView(
      dependencyFamilyKey: dependencyFamilyKey,
      dependencyRequired: dependencyRequired,
      dependencyExplanationKey: dependencyExplanationKey,
      title: title,
      body: bodyText,
    );
  }

  static CreditConstraintsHandoffBlockView? _parseHandoffBlock(
    Object? payload,
  ) {
    final body = _map(payload);
    final handoffKey = _readRequiredString(body?['handoffKey']);
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    if (handoffKey == null || title == null || bodyText == null) {
      return null;
    }
    return CreditConstraintsHandoffBlockView(
      handoffKey: handoffKey,
      title: title,
      body: bodyText,
    );
  }

  static CreditConstraintsDependencyHandoffView? _parseDependencyHandoff(
    Object? payload,
  ) {
    if (payload == null) {
      return null;
    }
    final body = _map(payload);
    final dependencyFamilyKey = _readRequiredString(
      body?['dependencyFamilyKey'],
    );
    final dependencyRequired = _readRequiredBool(body?['dependencyRequired']);
    final dependencyHandoffKey = _readRequiredString(
      body?['dependencyHandoffKey'],
    );
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    if (dependencyFamilyKey == null ||
        dependencyRequired == null ||
        dependencyHandoffKey == null ||
        title == null ||
        bodyText == null) {
      return null;
    }
    return CreditConstraintsDependencyHandoffView(
      dependencyFamilyKey: dependencyFamilyKey,
      dependencyRequired: dependencyRequired,
      dependencyHandoffKey: dependencyHandoffKey,
      title: title,
      body: bodyText,
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
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String? _readNullableString(Object? value) {
    if (value == null) {
      return null;
    }
    return _readRequiredString(value);
  }

  static bool? _readRequiredBool(Object? value) {
    return value is bool ? value : null;
  }

  static String? _extractMessage(Object? body) {
    final map = _map(body);
    return _readRequiredString(map?['message']);
  }

  static String? _extractErrorCode(Object? body) {
    final map = _map(body);
    return _readRequiredString(map?['code']);
  }
}
