import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/messages/data/messages_interaction_models.dart';
import 'package:mobile/features/messages/data/messages_interaction_parser.dart';

export 'package:mobile/features/messages/data/messages_interaction_models.dart';

class MessagesConsumerLayer {
  MessagesConsumerLayer._(this._client);

  factory MessagesConsumerLayer({AppApiClient? client}) {
    return MessagesConsumerLayer._(client ?? AppApiClient());
  }

  static MessagesConsumerLayer _instance = MessagesConsumerLayer();

  static MessagesConsumerLayer get instance => _instance;

  static void install(MessagesConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = MessagesConsumerLayer();
  }

  final AppApiClient _client;

  String get configuredEnvironmentLabel =>
      _client.config.userFacingEnvironmentLabel;

  Future<MessageInteractionListResult> loadInteractions({
    String lane = 'project_communication',
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(
          MessagesCanonicalPaths.messageInteractions,
          queryParameters: <String, String>{'lane': lane},
        ),
      );
      return _mapResponse(response);
    } on SocketException {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'network error while loading message interactions',
      );
    } on HttpException {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'http error while loading message interactions',
      );
    } on StateError {
      return MessageInteractionListResult(
        state: AppPageState.empty,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'current fake transport did not provide message interactions',
      );
    } on FormatException catch (error) {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: error.message,
      );
    }
  }

  @Deprecated('Use loadInteractions() instead.')
  Future<MessageInteractionListResult> loadIndex() {
    return loadInteractions();
  }

  MessageInteractionListResult _mapResponse(AppApiResponse response) {
    if (response.statusCode == 401) {
      return MessageInteractionListResult(
        state: AppPageState.unauthorized,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message: extractMessage(response.body) ?? '当前登录态不可用，请重新登录后再试。',
      );
    }

    if (response.statusCode == 403) {
      return MessageInteractionListResult(
        state: AppPageState.forbidden,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message: extractMessage(response.body) ?? '当前账号暂无项目沟通查看权限。',
      );
    }

    if (response.statusCode == 404) {
      return MessageInteractionListResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message: extractMessage(response.body) ?? '当前项目沟通入口暂不可用，请稍后再试。',
      );
    }

    if (response.statusCode >= 500) {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            extractMessage(response.body) ??
            'message interactions temporarily unavailable',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            extractMessage(response.body) ??
            'message interactions returned a controlled failure',
      );
    }

    final parsed = parseMessageInteractionPayload(response.body);
    return MessageInteractionListResult(
      state: parsed.state,
      method: 'GET',
      path: MessagesCanonicalPaths.messageInteractions,
      lane: parsed.lane,
      items: parsed.items,
      message: parsed.message,
    );
  }
}
