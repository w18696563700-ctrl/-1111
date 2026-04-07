import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_models.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_parser.dart';

export 'package:mobile/features/profile/data/profile_payment_billing_models.dart';

class ProfilePaymentBillingConsumerLayer {
  ProfilePaymentBillingConsumerLayer._(this._client);

  factory ProfilePaymentBillingConsumerLayer({AppApiClient? client}) {
    return ProfilePaymentBillingConsumerLayer._(client ?? AppApiClient());
  }

  static ProfilePaymentBillingConsumerLayer _instance =
      ProfilePaymentBillingConsumerLayer();

  static ProfilePaymentBillingConsumerLayer get instance => _instance;

  static void install(ProfilePaymentBillingConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfilePaymentBillingConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfilePaymentBillingResult<ProfilePaymentBillingStatusView>>
  loadStatus() {
    return _get(
      canonicalPath: ProfilePaymentBillingCanonicalPaths.status,
      parser: ProfilePaymentBillingPayloadParser.parseStatusView,
    );
  }

  Future<ProfilePaymentBillingResult<ProfilePaymentBillingExplanationView>>
  loadExplanation() {
    return _get(
      canonicalPath: ProfilePaymentBillingCanonicalPaths.explanation,
      parser: ProfilePaymentBillingPayloadParser.parseExplanationView,
    );
  }

  Future<ProfilePaymentBillingResult<ProfilePaymentBillingHandoffView>>
  loadHandoff() {
    return _get(
      canonicalPath: ProfilePaymentBillingCanonicalPaths.handoff,
      parser: ProfilePaymentBillingPayloadParser.parseHandoffView,
    );
  }

  Future<ProfilePaymentBillingResult<T>> _get<T>({
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) async {
    const method = 'GET';
    try {
      final response = await _client.get(canonicalPath);
      return _mapResponse(
        response,
        method: method,
        canonicalPath: canonicalPath,
        parser: parser,
      );
    } on SocketException {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: 'network error while loading payment-and-billing read model',
      );
    } on HttpException {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: 'http error while loading payment-and-billing read model',
      );
    } on FormatException {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'response decoding failed for payment-and-billing read model',
      );
    }
  }

  ProfilePaymentBillingResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) {
    if (response.statusCode == 401) {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        message:
            ProfilePaymentBillingPayloadParser.extractMessage(response.body) ??
            'payment-and-billing request unauthorized',
        errorCode: ProfilePaymentBillingPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode == 403) {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        message:
            ProfilePaymentBillingPayloadParser.extractMessage(response.body) ??
            'payment-and-billing request forbidden',
        errorCode: ProfilePaymentBillingPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode == 404) {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        message:
            ProfilePaymentBillingPayloadParser.extractMessage(response.body) ??
            'payment-and-billing route unavailable',
        errorCode: ProfilePaymentBillingPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode >= 500) {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message:
            ProfilePaymentBillingPayloadParser.extractMessage(response.body) ??
            'payment-and-billing request failed',
        errorCode: ProfilePaymentBillingPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message:
            ProfilePaymentBillingPayloadParser.extractMessage(response.body) ??
            'payment-and-billing request returned a controlled failure',
        errorCode: ProfilePaymentBillingPayloadParser.extractErrorCode(
          response.body,
        ),
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return ProfilePaymentBillingResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'payment-and-billing response is missing required fields',
      );
    }

    return ProfilePaymentBillingResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }
}
