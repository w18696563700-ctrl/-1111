import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/profile/data/profile_membership_consumer_layer.dart';

import 'profile_membership_purchase_models.dart';
import 'profile_membership_purchase_parser.dart';

export 'profile_membership_purchase_models.dart';

class ProfileMembershipPurchaseConsumerLayer {
  ProfileMembershipPurchaseConsumerLayer._(this._client);

  factory ProfileMembershipPurchaseConsumerLayer({AppApiClient? client}) {
    return ProfileMembershipPurchaseConsumerLayer._(client ?? AppApiClient());
  }

  static ProfileMembershipPurchaseConsumerLayer _instance =
      ProfileMembershipPurchaseConsumerLayer();

  static ProfileMembershipPurchaseConsumerLayer get instance => _instance;

  static void install(ProfileMembershipPurchaseConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileMembershipPurchaseConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfileMembershipResult<ProfileMembershipPurchaseOffersView>>
  loadPurchaseOffers() {
    return _request(
      method: 'GET',
      canonicalPath: ProfileMembershipPurchaseCanonicalPaths.purchaseOffers,
      send: () =>
          _client.get(ProfileMembershipPurchaseCanonicalPaths.purchaseOffers),
      parser: parseMembershipPurchaseOffers,
    );
  }

  Future<ProfileMembershipResult<ProfileMembershipOrderCreateView>>
  createOrder({
    required ProfileMembershipPurchaseOfferView offer,
    String purchaseIntentType = 'new_purchase',
  }) {
    return _request(
      method: 'POST',
      canonicalPath: ProfileMembershipPurchaseCanonicalPaths.orders,
      send: () => _client.post(
        ProfileMembershipPurchaseCanonicalPaths.orders,
        body: <String, Object?>{
          'skuCode': offer.skuCode,
          'purchaseIntentType': purchaseIntentType,
          'expectedAmount': offer.priceAmount,
          'expectedCurrency': offer.currency,
          'idempotencyKey': _idempotencyKey('membership-order-create'),
        },
      ),
      parser: parseMembershipOrderCreate,
    );
  }

  Future<ProfileMembershipResult<ProfileMembershipPayInitView>> payInit({
    required String membershipOrderId,
    required String payChannel,
  }) {
    final path = ProfileMembershipPurchaseCanonicalPaths.payInit(
      membershipOrderId,
    );
    return _request(
      method: 'POST',
      canonicalPath: path,
      send: () => _client.post(
        path,
        body: <String, Object?>{
          'payChannel': payChannel,
          'clientPlatform': 'flutter',
          'idempotencyKey': _idempotencyKey('membership-pay-init'),
        },
      ),
      parser: parseMembershipPayInit,
    );
  }

  Future<ProfileMembershipResult<ProfileMembershipOrderResultView>> loadOrder(
    String membershipOrderId,
  ) {
    final path = ProfileMembershipPurchaseCanonicalPaths.order(
      membershipOrderId,
    );
    return _request(
      method: 'GET',
      canonicalPath: path,
      send: () => _client.get(path),
      parser: parseMembershipOrderResult,
    );
  }

  Future<ProfileMembershipResult<T>> _request<T>({
    required String method,
    required String canonicalPath,
    required Future<AppApiResponse> Function() send,
    required T? Function(Object? payload) parser,
  }) async {
    try {
      final response = await runProtectedAppRequest(send);
      return _mapResponse(
        response,
        method: method,
        canonicalPath: canonicalPath,
        parser: parser,
      );
    } on SocketException {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: 'network error while loading membership purchase model',
      );
    } on HttpException {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: 'http error while loading membership purchase model',
      );
    } on FormatException {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'response decoding failed for membership purchase model',
      );
    }
  }

  ProfileMembershipResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) {
    if (response.statusCode == 401) {
      return _failure(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        response: response,
        fallback: 'membership purchase unauthorized',
      );
    }
    if (response.statusCode == 403) {
      return _failure(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        response: response,
        fallback: 'membership purchase forbidden',
      );
    }
    if (response.statusCode == 404) {
      return _failure(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        response: response,
        fallback: 'membership purchase route unavailable',
      );
    }
    if (response.statusCode >= 500) {
      return _failure(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        response: response,
        fallback: 'membership purchase failed',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _failure(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        response: response,
        fallback: 'membership purchase returned a controlled failure',
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return ProfileMembershipResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'membership purchase response is missing required fields',
      );
    }

    return ProfileMembershipResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }

  ProfileMembershipResult<T> _failure<T>({
    required AppPageState state,
    required String method,
    required String path,
    required AppApiResponse response,
    required String fallback,
  }) {
    return ProfileMembershipResult<T>(
      state: state,
      method: method,
      path: path,
      message: extractMembershipPurchaseMessage(response.body) ?? fallback,
      errorCode: extractMembershipPurchaseErrorCode(response.body),
    );
  }
}

String _idempotencyKey(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}
